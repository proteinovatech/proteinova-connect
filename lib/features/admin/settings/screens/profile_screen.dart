import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/profile_textfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';

      // Capitalize the first letter of the role
      String role = prefs.getString('role') ?? '';
      if (role.isNotEmpty) {
        roleController.text = role[0].toUpperCase() + role.substring(1);
      }
    });
  }

  void onUploadImage() {
    debugPrint("Upload Image");
  }

  void onSaveProfile() {
    debugPrint("Save Profile");
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
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 18),

                        SizedBox(width: 6),

                        Text(
                          "Admin",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // const SizedBox(height: 24),

              // /// TOP MENU
              // Container(
              //   padding: const EdgeInsets.all(14),

              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius:
              //         BorderRadius.circular(20),

              //     border: Border.all(
              //       color: const Color(0xffE5E7EB),
              //     ),
              //   ),

              //   child: Column(
              //     children: [

              //       Container(
              //         padding:
              //             const EdgeInsets.symmetric(
              //           horizontal: 18,
              //           vertical: 18,
              //         ),

              //         decoration: BoxDecoration(
              //           color: const Color(0xffFEF3C7),
              //           borderRadius:
              //               BorderRadius.circular(
              //             16,
              //           ),
              //         ),

              //         child: const Row(
              //           children: [

              //             Icon(
              //               Icons.person_outline,
              //             ),

              //             SizedBox(width: 14),

              //             Text(
              //               "My Profile",
              //               style: TextStyle(
              //                 fontSize: 20,
              //                 fontWeight:
              //                     FontWeight.w700,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),

              //       const SizedBox(height: 14),

              //       Container(
              //         padding:
              //             const EdgeInsets.symmetric(
              //           horizontal: 18,
              //           vertical: 18,
              //         ),

              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           borderRadius:
              //               BorderRadius.circular(
              //             16,
              //           ),

              //           border: Border.all(
              //             color:
              //                 const Color(0xffE5E7EB),
              //           ),
              //         ),

              //         child: const Row(
              //           children: [

              //             Icon(
              //               Icons.admin_panel_settings_outlined,
              //             ),

              //             SizedBox(width: 14),

              //             Text(
              //               "Roles & Permissions",
              //               style: TextStyle(
              //                 fontSize: 20,
              //                 fontWeight:
              //                     FontWeight.w700,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Update your personal information and avatar.",
                      style: TextStyle(fontSize: 18, color: Color(0xff6B7280)),
                    ),

                    const SizedBox(height: 24),

                    Divider(color: Colors.grey.shade300),

                    const SizedBox(height: 30),

                    /// IMAGE
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xffFACC15),

                      child: const CircleAvatar(
                        radius: 58,
                        backgroundImage: AssetImage("assets/profile.jpg"),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// UPLOAD BUTTON
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: onUploadImage,

                      icon: const Icon(Icons.upload_outlined),

                      label: const Text(
                        "Upload Image",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    /// FIELDS
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            label: "Full Name",
                            hint: "Enter Full Name",
                            controller: nameController,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: ProfileTextField(
                            label: "Email Address",
                            hint: "user@example.com",
                            controller: emailController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            label: "Phone Number",
                            hint: "Enter Phone Number",
                            controller: phoneController,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: ProfileTextField(
                            label: "Role",
                            hint: "Role",
                            enabled: false,
                            controller: roleController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 62,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFACC15),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        onPressed: onSaveProfile,

                        icon: const Icon(
                          Icons.save_outlined,
                          color: Colors.black,
                        ),

                        label: const Text(
                          "Save Profile",
                          style: TextStyle(
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
