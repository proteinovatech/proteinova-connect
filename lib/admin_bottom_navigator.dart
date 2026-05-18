import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/settings/screens/admin_settings_screen.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_event.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/distribution_page.dart';
import 'package:proteinova_connect/features/admin/addprice/presentation/add_price.dart';
import 'package:proteinova_connect/features/admin/approval/screens/approvals_queue_screen.dart';
import 'package:proteinova_connect/features/admin/expense/screens/admin_expense_screen.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/presentation/asset_management_page.dart';
import 'package:proteinova_connect/features/admin/menu/branch_management/presentation/branch_management.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/presentation/receive_trays_screen.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_dashoard.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_dashboard.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_inventory.dart';
import 'package:proteinova_connect/features/admin/presentation/offer_price.dart';
import 'package:proteinova_connect/features/admin/supplier/screens/admin_suppliers_screen.dart';
import 'package:proteinova_connect/features/admin/presentation/Incoming_stock.dart';

import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';

class AdminBottomNavigator extends StatefulWidget {
  const AdminBottomNavigator({super.key});

  @override
  State<AdminBottomNavigator> createState() => _BranchBottomNavigatorState();
}

class _BranchBottomNavigatorState extends State<AdminBottomNavigator> {
  @override
  void initState() {
    super.initState();
    // Initialize admin notifications (request permissions & subscribe to topic)
    NotificationService.setupAdminNotifications();
  }

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
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
                (route) => false,
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

  final List<Widget> pages = [
    AdminDashboard(),
    AddPriceScreen(),
    DistributionPage(),
    ApprovalsQueueScreen(),
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
            _buildNavItem(Icons.dashboard_rounded, 0),
            _buildNavItem(Icons.currency_rupee_rounded, 1),
            _buildNavItem(Icons.local_shipping_rounded, 2),
            _buildNavItem(Icons.verified_rounded, 3),
            _buildNavItem(Icons.menu_outlined, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 4) {
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
            Text(_getLabel(index), style: AppTextStyles.bodyText14dark),
        ],
      ),
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Add Price";
      case 2:
        return "Distribution";
      case 3:
        return "Approval";
      case 4:
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

                  _menuTile(
                    Icons.agriculture,
                    "SalesDashboard",
                    SalesDashboardPage(),
                  ),

                  _menuTile(
                    Icons.store,
                    "Branch Management",
                    BranchManagement(),
                  ),

                  // _menuTile(Icons.alt_route, "Tray Return", TrayReturn()),
                  _menuTile(Icons.money, "Expenses", AdminExpenseScreen()),
                  _menuTile(
                    Icons.local_shipping_rounded,
                    "Supplier",
                    AdminSuppliersScreen(),
                  ),
                  _menuTile(
                    Icons.account_balance_wallet_outlined,
                    "Asset Management",
                    AssetManagementPage(),
                  ),

                  _menuTile(
                    Icons.inventory_2_outlined,
                    "ReceiveTrays",
                    ReceiveTraysScreen(),
                  ),

                  _menuTile(
                    Icons.warehouse_outlined,
                    "AdminInventory",
                    AdminInventory(),
                  ),
                  // _menuTile(
                  //   Icons.agriculture,
                  //   "SalesDashboard",
                  //   SalesDashboardPage(),
                  // ),
                  _menuTile(Icons.inventory, "Incoming Stock", IncomingStock()),

                  _menuTile(Icons.sell_outlined, "Offer Price", OfferPrice()),
                  // _menuTile(
                  //   Icons.report,
                  //   "Report",
                  //   AdminReportDashboardScreen(),
                  // ),
                  _menuTile(Icons.settings, "setting", AdminSettingsScreen()),
                  // _menuTile(Icons.money, "Expenses", ExpenseManagement()),
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
