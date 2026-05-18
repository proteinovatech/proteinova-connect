import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/settings/data/services/settings_service.dart';
import 'package:proteinova_connect/features/admin/settings/screens/staff_management_screen.dart';
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
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      emailController.text = prefs.getString('email') ?? '';
      String role = prefs.getString('role') ?? '';
      if (role.isNotEmpty) {
        roleController.text = role.toUpperCase();
      }
      isLoading = false;
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
      isSaving = true;
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
        isSaving = false;
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
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            /// GLOBAL HEADER
            _buildHeader(),
            const Divider(height: 1),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SIDEBAR
                  if (isWide) _buildSidebar(),
                  
                  /// MAIN CONTENT
                  Expanded(
                    child: isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _buildProfileCard(),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 8),
          const Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.amber),
                SizedBox(width: 6),
                Text("Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xffE5E7EB))),
      ),
      child: Column(
        children: [
          _sidebarItem(Icons.person_outline, "My Profile", true, () {}),
          _sidebarItem(Icons.group_outlined, "Staff Management", false, () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StaffManagementScreen()));
          }),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xffFEF3C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.amber.shade700 : Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(
              color: active ? Colors.amber.shade900 : Colors.grey.shade700,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Update your account information and credentials.", style: TextStyle(color: Colors.grey)),
          const Divider(height: 40),
          
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xffF1F5F9),
              child: Text(
                emailController.text.isNotEmpty ? emailController.text[0].toUpperCase() : "A",
                style: const TextStyle(fontSize: 32, color: Color(0xff64748B)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          Row(
            children: [
              Expanded(child: ProfileTextField(label: "Email Address", hint: "user@example.com", controller: emailController)),
              const SizedBox(width: 20),
              Expanded(child: ProfileTextField(label: "User Role", hint: "Role", enabled: false, controller: roleController)),
            ],
          ),
          const SizedBox(height: 24),
          ProfileTextField(
            label: "New Password (Leave blank to keep current)",
            hint: "••••••••",
            controller: passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isSaving ? null : onSaveProfile,
              child: Text(
                isSaving ? "Saving..." : "Save Profile",
                style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
