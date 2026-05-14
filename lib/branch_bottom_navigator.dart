import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_inventory.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/addexpense/presentation/expense_management/presentation/expense_management.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/features/branch/branch_details/presentation/branch_details.dart';
import 'package:proteinova_connect/features/branch/daily_closing/presentation/daily_closing.dart';
import 'package:proteinova_connect/features/branch/inventory/presentation/inventory.dart';
import 'package:proteinova_connect/features/branch/inventory/presentation/receivestock.dart';
import 'package:proteinova_connect/features/branch/sales/presentation/sales.dart';
import 'package:proteinova_connect/features/branch/tray_returns/presentation/tray_returns.dart';
import 'features/branch/branch_dashboard/presentation/branch_dashboard.dart';

class BranchBottomNavigator extends StatefulWidget {
  const BranchBottomNavigator({super.key});

  @override
  State<BranchBottomNavigator> createState() => _BranchBottomNavigatorState();
}

class _BranchBottomNavigatorState extends State<BranchBottomNavigator> {
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SignupScreen()),
              );
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openSideMenu() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.white,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: double.infinity,
              child: _menuContent(),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  int selectedIndex = 0;

  final List<Widget> pages = [BranchDashboard(), Sales(), DailyClosing()];

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
            _buildNavItem(Icons.shopping_cart_outlined, 1),
            // _buildNavItem(Icons.inventory_2_outlined, 2),
            _buildNavItem(Icons.receipt_long, 2),
            _buildNavItem(Icons.menu_outlined, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          _openSideMenu();
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

          if (isSelected) const SizedBox(height: 4),

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
        return "Sales";

      case 2:
        return "Daily closing";
      case 3:
        return "Menu";
      default:
        return "";
    }
  }

  Widget _menuContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/erplogo.png", height: 40, width: 150),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // _menuTile(
                  //   Icons.agriculture,
                  //   "Incoming Stock from warehouse",
                  //   Receivestock(),
                  // ),

                  // _menuTile(Icons.store, "Branches", BranchDetails()),
                  _menuTile(Icons.alt_route, "Tray Return", TrayReturn()),

                  _menuTile(Icons.money, "Expenses", ExpenseManagement()),

                  //  _menuTile(Icons.money, "Admin in", AdminInventory()),
                  const SizedBox(height: 20),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _handleLogout(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
