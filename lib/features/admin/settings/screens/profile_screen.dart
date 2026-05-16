import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/settings/data/services/settings_service.dart';
import '../widgets/profile_textfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  int? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId'); // Assuming userId is stored as int
      emailController.text = prefs.getString('email') ?? '';
      String role = prefs.getString('role') ?? '';
      if (role.isNotEmpty) {
        roleController.text = role.toUpperCase();
      }
    });
  }

  Future<void> onSaveProfile() async {
    if (emailController.text.isEmpty) {
      _showPopup("Error", "Email is required", isError: true);
      return;
    }

    if (userId == null) {
      _showPopup("Error", "User ID not found. Please log in again.", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await SettingsService().updateProfile(userId!, {
        "email": emailController.text,
        "role": roleController.text.toLowerCase(),
        "password": passwordController.text,
      });

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', emailController.text);
        
        _showPopup("Success", "Profile updated successfully!");
        passwordController.clear();
      } else {
        _showPopup("Error", "Failed to update profile", isError: true);
      }
    } catch (e) {
      _showPopup("Error", e.toString(), isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPopup(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: TextStyle(color: isError ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Settings",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xffFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 18),
                        SizedBox(width: 6),
                        Text("Admin", style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// PROFILE CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Profile",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Update your account information and credentials.",
                      style: TextStyle(fontSize: 18, color: Color(0xff6B7280)),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 30),

                    /// AVATAR SECTION
                    Center(
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: const Color(0xffF1F5F9),
                        child: Text(
                          emailController.text.isNotEmpty 
                              ? emailController.text[0].toUpperCase() 
                              : "A",
                          style: const TextStyle(fontSize: 32, color: Color(0xff64748B)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),

                    /// FIELDS
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            label: "Email Address",
                            hint: "user@example.com",
                            controller: emailController,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: ProfileTextField(
                            label: "User Role",
                            hint: "Role",
                            enabled: false,
                            controller: roleController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    ProfileTextField(
                      label: "New Password (Leave blank to keep current)",
                      hint: "••••••••",
                      controller: passwordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 34),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: isLoading ? null : onSaveProfile,
                        child: Text(
                          isLoading ? "Saving..." : "Save Profile",
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
