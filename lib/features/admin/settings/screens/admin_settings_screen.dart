import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/settings/bloc/profile/profile_bloc.dart';
import 'package:proteinova_connect/features/admin/settings/bloc/profile/profile_event.dart';
import 'package:proteinova_connect/features/admin/settings/bloc/user/user_bloc.dart';
import 'package:proteinova_connect/features/admin/settings/data/services/settings_service.dart';
import 'package:proteinova_connect/features/admin/settings/screens/profile_screen.dart';
import 'package:proteinova_connect/features/admin/settings/screens/staff_management_screen.dart';

import '../widgets/settings_option_tile.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  /// FUNCTIONS

  void onProfileTap() {
   Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (_) => ProfileBloc(
        SettingsService(),
      )..add(LoadProfileEvent()),
      child: const ProfileScreen(),
    ),
  ),
);
  }

  void onRolePermissionTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
         create: (_) => UserBloc(
          SettingsService())..add(FetchUsersEvent()),
             child: const StaffManagementScreen(),
         )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

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
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// PROFILE
              SettingsOptionTile(
                icon: Icons.person_outline,
                title: "Profile",
                subtitle: "Manage admin profile details",
                onTap: onProfileTap,
              ),

              const SizedBox(height: 18),

              /// STAFF MANAGEMENT
              SettingsOptionTile(
                icon: Icons.people_outline,
                title: "Staff Management",
                subtitle: "Manage your staff members and access",
                onTap: onRolePermissionTap, // Reusing this for staff management
              ),

              const SizedBox(height: 18),

              /// ROLE & PERMISSION (Optional, keeping as placeholder or for future)
              // SettingsOptionTile(
              //   icon: Icons.admin_panel_settings_outlined,
              //   title: "Roles & Permissions",
              //   subtitle: "Manage roles and access permissions",
              //   onTap: () {
              //     // This could lead to a screen like CreateRole.jsx
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

}
