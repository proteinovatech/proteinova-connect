import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_event.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/features/purchase/supplier/supplier_screen.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/presentation/purchase_dashboard.dart';


class PurchaseBottomNavigator extends StatefulWidget {
  const PurchaseBottomNavigator({super.key});

  @override
  State<PurchaseBottomNavigator> createState() =>
      _PurchasebottomnavigatorState();
}

class _PurchasebottomnavigatorState extends State<PurchaseBottomNavigator> {
  int selectedIndex = 0;

  //   void _showProfileOptions(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title:  Text("Profile",style: AppTextStyles.headingText20,),
  //         content: Text("Do you want to logout?",style: AppTextStyles.bodyText14,),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // close dialog
  //             },
  //             child:  Text("Cancel",style: AppTextStyles.browntext,),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.pop(context);
  //               final prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();

  //   Navigator.pushNamedAndRemoveUntil(
  //     context,
  //     "/signup",
  //     (route) => false,); // 🔥

  //             },
  //             child: const Text("Logout",style: AppTextStyles.browntext,),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //profile
  void _showProfileOptions(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Profile",
      barrierColor: Colors.black54,

      transitionDuration: const Duration(milliseconds: 300),

      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,

          child: Material(
            color: Colors.transparent,

            child: Container(
              width: MediaQuery.of(context).size.width * 0.77,
              height: double.infinity,

              decoration: const BoxDecoration(
                color: Color(0xfff5f6fa),

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
              ),

              child: SafeArea(
                child: Column(
                  children: [
                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.all(16),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Profile",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        child: Column(
                          children: [
                            /// PROFILE CARD
                            // Container(
                            //   width: double.infinity,
                            //   padding: const EdgeInsets.all(20),

                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(18),

                            //     border: Border.all(color: Colors.grey.shade200),
                            //   ),

                            //   child: Column(
                            //     children: [
                            //       Container(
                            //         height: 100,
                            //         width: 100,

                            //         decoration: BoxDecoration(
                            //           color: const Color(0xfffacc15),

                            //           borderRadius: BorderRadius.circular(100),
                            //         ),

                            //         child: const Icon(
                            //           Icons.person,
                            //           size: 55,
                            //           color: Colors.black,
                            //         ),
                            //       ),

                            //       const SizedBox(height: 16),

                            //       const Text(
                            //         "ABIN Raj",
                            //         style: TextStyle(
                            //           fontSize: 24,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),

                            //       const SizedBox(height: 5),

                            //       Text(
                            //         "Branch Manager",
                            //         style: TextStyle(
                            //           color: Colors.grey.shade600,
                            //           fontSize: 15,
                            //         ),
                            //       ),

                            //       const SizedBox(height: 24),

                            //       Divider(color: Colors.grey.shade200),

                            //       const SizedBox(height: 20),

                            //       _buildProfileTile(
                            //         icon: Icons.email_outlined,
                            //         title: "Email",
                            //         value: "abinraj@proteinova.com",
                            //       ),

                            //       const SizedBox(height: 18),

                            //       _buildProfileTile(
                            //         icon: Icons.phone_outlined,
                            //         title: "Phone",
                            //         value: "+91 9876543210",
                            //       ),

                            //       const SizedBox(height: 18),

                            //       _buildProfileTile(
                            //         icon: Icons.location_on_outlined,
                            //         title: "Location",
                            //         value: "Tamil Nadu, India",
                            //       ),

                            //       const SizedBox(height: 18),

                            //       _buildProfileTile(
                            //         icon: Icons.badge_outlined,
                            //         title: "Employee ID",
                            //         value: "EMP-1024",
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // const SizedBox(height: 20),

                            /// SETTINGS
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),

                                border: Border.all(color: Colors.grey.shade200),
                              ),

                              child: Column(
                                children: [
                                  // _buildSettingTile(
                                  //   icon: Icons.lock_outline,
                                  //   title: "Change Password",
                                  // ),

                                  // Divider(color: Colors.grey.shade200),

                                  // _buildSettingTile(
                                  //   icon: Icons.notifications_none,
                                  //   title: "Notifications",
                                  // ),

                                  // Divider(color: Colors.grey.shade200),

                                  // _buildSettingTile(
                                  //   icon: Icons.language,
                                  //   title: "Language",
                                  // ),
                                  // Divider(color: Colors.grey.shade200),

                                  _buildSettingTile(
                                    icon: Icons.logout,
                                    title: "Logout",
                                    isLogout: true,

                                    onTap: () async {
                                      Navigator.pop(context);

                                      context.read<AuthBloc>().add(
                                        LogoutRequested(),
                                      );

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  
                  ],
                ),
              ),
            ),
          ),
        );
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),

          child: child,
        );
      },
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xfff8fafc),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black87),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xfff8fafc),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Icon(icon, color: isLogout ? Colors.red : Colors.black87),
      ),

      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),

      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

      onTap: onTap,
    );
  }

  final List<Widget> pages = [
    PurchaseDashboard(),
    SuppliersScreen(),
    const Center(child: Text("Notifications Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: AppColors.textSecondary, blurRadius: 1)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view, 0),
            _buildNavItem(Icons.local_shipping_outlined, 1),
            _buildNavItem(Icons.person_outline, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 2) {
          _showProfileOptions(context);
        } else {
          setState(() {
            selectedIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.amber600 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.dark : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          // ✅ Show text ONLY when selected
          if (isSelected)
            Text(_getLabel(index), style: AppTextStyles.bodyText16),
        ],
      ),
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Supplier";
      case 2:
        return "Profile";
      default:
        return "";
    }
  }
}
