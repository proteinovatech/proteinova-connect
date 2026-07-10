import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_event.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/addexpense/presentation/expense_management/presentation/expense_management.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/features/branch/customer_trays/presentation/customer_trays.dart';
import 'package:proteinova_connect/features/branch/daily_closing/presentation/daily_closing.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_bloc.dart';
import 'package:proteinova_connect/features/branch/damage_entry/bloc/damage_event.dart';
import 'package:proteinova_connect/features/branch/damage_entry/data/repository/damage_repository.dart';
import 'package:proteinova_connect/features/branch/damage_entry/presentations/damage_entry_screen.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_bloc.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_event.dart';
import 'package:proteinova_connect/features/branch/inventory/presentation/inventory.dart';
import 'package:proteinova_connect/features/branch/ledger/bloc/ledger_bloc.dart';
import 'package:proteinova_connect/features/branch/ledger/presentation/ledger_screen.dart';
import 'package:proteinova_connect/features/branch/report/bloc/report_bloc.dart';
import 'package:proteinova_connect/features/branch/report/bloc/report_event.dart';
import 'package:proteinova_connect/features/branch/report/presentation/expense_report.dart';
import 'package:proteinova_connect/features/branch/report/presentation/report_screen.dart';
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
              width: MediaQuery.of(context).size.width > 600
                  ? 320
                  : MediaQuery.of(context).size.width * 0.6,
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
    BranchDashboard(),
    Sales(),

    BlocProvider(
      create: (_) => InventoryBloc()..add(FetchInventoryEvent()),

      child: Inventory(),
    ),
    DailyClosing(),
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
            _buildNavItem(Icons.shopping_cart_outlined, 1),
            _buildNavItem(Icons.local_shipping_outlined, 2),
            _buildNavItem(Icons.receipt_long, 3),
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
        return "Stock Receive";
      case 3:
        return "Daily closing";
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Image.asset(
              "assets/erplogo.png",
              height: 40,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          const Divider(height: 1),
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
                  _menuTile(
                    Icons.account_balance_wallet,
                    "Ledger",
                    BlocProvider(
                      create: (_) => LedgerBloc(),
                      child: LedgerScreen(),
                    ),
                  ),
                  _menuTile(Icons.alt_route, "Tray Return", TrayReturn()),

                  _menuTile(Icons.money, "Expenses Overview", ExpenseManagement()),
                  _menuTile(
                    Icons.inventory_2_outlined,
                    "Customer trays",
                    CustomerTrays(),
                  ),

                  _menuTile(
                    Icons.error_outline_rounded,
                    "Damage Entry",
                    BlocProvider(
                      create: (_) =>
                          DamageBloc(DamageRepository(DioClient().dio))
                            ..add(FetchDamageCategoriesEvent(branchId: 11)),
                      child: const DamageEntryScreen(),
                    ),
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text(
                      "Report",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.only(left: 30),
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.receipt_long_outlined,
                          size: 20,
                        ),
                        title: const Text("Branch Expense Report"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => ReportBloc()
                                  ..add(FetchBranchReportEvent(branchId: 11)),
                                child: ExpenseReport(),
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.bar_chart_outlined, size: 20),
                        title: const Text("Branch Sales Report"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => ReportBloc(),
                                child: const ReportScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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

  Widget _menuTile(
    IconData icon,
    String title,
    Widget? page, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap:
          onTap ??
          () {
            if (page != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            }
          },
    );
  }
}

// Widget _sectionTitle(String title) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     child: Text(
//       title,
//       style: const TextStyle(
//         color: Colors.grey,
//         fontSize: 12,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   );
// }
