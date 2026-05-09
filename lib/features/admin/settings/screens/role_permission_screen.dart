import 'package:flutter/material.dart';

import '../widgets/role_textfield.dart';

class RolePermissionScreen extends StatefulWidget {
  const RolePermissionScreen({super.key});

  @override
  State<RolePermissionScreen> createState() => _RolePermissionScreenState();
}

class _RolePermissionScreenState extends State<RolePermissionScreen> {
  void onCancel() {
    Navigator.pop(context);
  }

  void onSave() {
    debugPrint("Role Saved");
  }

  void onProfileTap() {
    Navigator.pop(context);
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
              /// BACK
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },

                child: const Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(Icons.arrow_back_ios_new, size: 20),

                    SizedBox(width: 10),

                    Text(
                      "Back to Roles",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// TITLE + BUTTONS
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Create New Role",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: onCancel,

                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,

                      backgroundColor: const Color(0xffFACC15),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: onSave,

                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// TOP MENU
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

              //       InkWell(
              //         borderRadius:
              //             BorderRadius.circular(
              //           16,
              //         ),

              //         onTap: onProfileTap,

              //         child: Container(
              //           padding:
              //               const EdgeInsets.symmetric(
              //             horizontal: 18,
              //             vertical: 18,
              //           ),

              //           decoration: BoxDecoration(
              //             color: Colors.white,

              //             borderRadius:
              //                 BorderRadius.circular(
              //               16,
              //             ),
              //           ),

              //           child: const Row(
              //             children: [

              //               Icon(
              //                 Icons.person_outline,
              //               ),

              //               SizedBox(width: 14),

              //               Expanded(
              //                 child: Text(
              //                   "My Profile",
              //                   style: TextStyle(
              //                     fontSize: 20,
              //                     fontWeight:
              //                         FontWeight
              //                             .w700,
              //                   ),
              //                 ),
              //               ),

              //               Icon(
              //                 Icons
              //                     .arrow_forward_ios,
              //                 size: 18,
              //               ),
              //             ],
              //           ),
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
              //           color: const Color(
              //             0xffFEF9C3,
              //           ),

              //           borderRadius:
              //               BorderRadius.circular(
              //             16,
              //           ),
              //         ),

              //         child: const Row(
              //           children: [

              //             Icon(
              //               Icons
              //                   .admin_panel_settings_outlined,
              //               color: Color(
              //                 0xffCA8A04,
              //               ),
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

              /// ROLE DETAILS CARD
              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Role Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const RoleTextField(
                      label: "Role Name",
                      hint: "e.g. Finance Manager, Quality Inspector",
                    ),

                    const SizedBox(height: 30),

                    const RoleTextField(
                      label: "Description",
                      hint:
                          "Describe the responsibilities and access level of this role...",
                      maxLines: 6,
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
