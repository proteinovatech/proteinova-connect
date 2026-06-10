import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/admin%20Damage%20Entry/presentation/admin_damage_entry.dart';
import 'package:proteinova_connect/features/admin/admin%20customertrays/presentation/admin_customer_trays.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_bloc.dart';
import 'package:proteinova_connect/features/admin/expense/data/repository/expense_repository.dart';
import 'package:proteinova_connect/features/admin/expense/screens/admin_addexpence_screen.dart';
import 'package:proteinova_connect/features/admin/inventory/presentation/admin_inventory.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/bloc/asset_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/data/asset_repository.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/bloc/tray_receive_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/bloc/tray_receive_event.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/data/services/tray_receive_service.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';

import 'package:proteinova_connect/features/admin/tray_management/screen/tray_management.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_event.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/distribution_page.dart';
import 'package:proteinova_connect/features/admin/expense/screens/admin_expense_screen.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/presentation/asset_management_page.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/presentation/receive_trays_screen.dart';
import 'package:proteinova_connect/features/admin/presentation/offer_price.dart';
import 'package:proteinova_connect/features/admin/presentation/Incoming_stock.dart';
import 'package:proteinova_connect/features/admin/menu/item/presentation/item.dart';
import 'package:proteinova_connect/features/admin/menu/item/bloc/item_bloc.dart';
import 'package:proteinova_connect/features/admin/inventory/data/inventory_repository.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/screens/purchase_expense_screen.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/bloc/purchase_bloc.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/data/repository/purchase_expense_repository.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/features/branch/addexpense/presentation/addexpense.dart';

class WarehouseBottomNavigator extends StatefulWidget {
  const WarehouseBottomNavigator({super.key});

  @override
  State<WarehouseBottomNavigator> createState() =>
      _WarehouseBottomNavigatorState();
}

class _WarehouseBottomNavigatorState extends State<WarehouseBottomNavigator> {
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
    AdminInventory(role: "warehouse"),

    IncomingStock(role: "warehouse"),

    // BlocProvider(
    //   create: (_) => BranchExpenseBloc(ExpenseRepository()),
    //   child: const AdminExpenseScreen(),
    // ),
    DistributionPage(),

    BlocProvider(
      create: (_) => PurchaseExpenseBloc(PurchaseExpenseRepository()),
      child: const PurchaseExpenseScreen(),
    ),
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
            _buildNavItem(Icons.inventory_2, 0),
            _buildNavItem(Icons.move_to_inbox_rounded, 1),
            _buildNavItem(Icons.local_shipping_rounded, 2),
            _buildNavItem(Icons.account_balance_wallet_outlined, 3),
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
        return "Inventory";
      case 1:
        return "Incoming";
      case 2:
        return "Sales";
      case 3:
        return "Expenses";
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
                  const SizedBox(height: 10),

                  ///Warehouse
                  _sectionTitle("Warehouse"),

                  //Inventory
                  // _menuTile(
                  //   Icons.store,
                  //   "Branch Management",
                  //   BlocProvider(
                  //     create: (_) =>
                  //         BranchBloc(BranchService())..add(LoadBranchesEvent()),

                  //     child: BranchManagement(),
                  //   ),
                  // ),

                  // _menuTile(Icons.alt_route, "Tray Return", TrayReturn()),
                  // _menuTile(Icons.money, "Expenses", AdminExpenseScreen()),
                  // _menuTile(
                  //   Icons.local_shipping_rounded,
                  //   "Supplier",
                  //   AdminSuppliersScreen(),
                  // ),
                  // _menuTile(
                  //   Icons.account_balance_wallet_outlined,
                  //   "Asset Management",
                  //   BlocProvider(
                  //     create: (_) =>
                  //         AssetBloc(AssetRepository())..add(FetchAssetsEvent()),

                  //     child: AssetManagementPage(),
                  //   ),
                  // ),

                  //Items
                  _menuTile(
                    Icons.category_outlined,
                    "Items",
                    BlocProvider(
                      create: (_) => ItemBloc(
                        inventoryRepository: InventoryRepository(),
                        assetRepository: AssetRepository(),
                      ),
                      child: const ItemScreen(),
                    ),
                  ),

                  //Expenses
                  _menuTile(
                    Icons.pie_chart_outline,
                    "Expenses Overview",
                    BlocProvider(
                      create: (_) => BranchExpenseBloc(ExpenseRepository()),
                      child: const AdminExpenseScreen(),
                    ),
                  ),

                  _menuTile(
                    Icons.add_circle_outline,
                    "Add Expense",
                    AdminAddExpenseScreen(),
                  ),

                  //Purchase Expenses
                  _menuTile(
                    Icons.receipt_long,
                    "Purchase Expenses",
                    BlocProvider(
                      create: (_) =>
                          PurchaseExpenseBloc(PurchaseExpenseRepository()),
                      child: const PurchaseExpenseScreen(),
                    ),
                  ),

                  //Offers & Prices
                  _menuTile(
                    Icons.sell_outlined,
                    "Offers & Prices",
                    OfferPrice(),
                  ),

                  //Incoming Stock
                  _menuTile(
                    Icons.move_to_inbox_rounded,
                    "Incoming Stock",
                    IncomingStock(role: "warehouse"),
                  ),

                  //ReceiveTrays
                  _menuTile(
                    Icons.reply,
                    "ReceiveTrays",
                    BlocProvider(
                      create: (_) =>
                          TrayReceiveBloc(TrayReceiveService())
                            ..add(FetchTrayReceiveNotes()),

                      child: const ReceiveTraysScreen(),
                    ),
                  ),

                  //TrayManagement
                  _menuTile(
                    Icons.layers_outlined,
                    "TrayManagement",
                    TrayManagementScreen(),
                  ),
                  _menuTile(
                    Icons.people_outline,
                    "Customer trays",
                    AdminCustomerTrays(),
                  ),
                  // _menuTile(
                  //   Icons.broken_image_outlined,
                  //   "Damage entry",
                  //   AdminDamageEntryPage(),
                  // ),

                  // //Purchase
                  // _menuTile(
                  //   Icons.local_shipping_outlined,
                  //   "Purchase",
                  //   BlocProvider(
                  //     create: (_) => PurchaseBloc(
                  //       admin_supplier.SupplierRepository(DioClient().dio),
                  //       PurchaseRepository(
                  //         DioClient().dio,
                  //         PurchaseCacheService(),
                  //       ),
                  //       PurchaseCacheService(),
                  //     )..add(FetchPurchaseInitData()),
                  //     child: const Purchase(),
                  //   ),
                  // ),

                  //Supplier
                  // _menuTile(
                  //   Icons.groups_outlined,
                  //   "Supplier",
                  //   BlocProvider(
                  //     create: (_) =>
                  //         SupplierBloc(SupplierService())
                  //           ..add(FetchSuppliersEvent()),
                  //     child: const AdminSuppliersScreen(),
                  //   ),
                  // ),

                  ///Branch Section
                  // _sectionTitle("Branch Section"),

                  //Sales
                  // _menuTile(
                  //   Icons.shopping_cart_outlined,
                  //   "Sales",
                  //   BlocProvider(
                  //     create: (_) =>
                  //         SalesDashboardBloc(SalesRemoteDatasource())
                  //           ..add(FetchSalesDashboard()),

                  //     child: const SalesDashboardPage(),
                  //   ),
                  // ),

                  //ReceivingBranchScreen
                  // _menuTile(
                  //   Icons.groups_outlined,
                  //   "Receiving From Branch",
                  //   ReceivingBranchScreen(),
                  // ),

                  //Branch Management
                  // _menuTile(
                  //   Icons.store,
                  //   "Branch Management",
                  //   BlocProvider(
                  //     create: (_) =>
                  //         BranchBloc(BranchService())..add(LoadBranchesEvent()),

                  //     child: BranchManagement(),
                  //   ),
                  // ),

                  // _menuTile(Icons.alt_route, "Tray Return", TrayReturn()),

                  // _menuTile(
                  //   Icons.agriculture,
                  //   "SalesDashboard",
                  //   SalesDashboardPage(),
                  // ),
                  // _menuTile(Icons.inventory, "Incoming Stock", IncomingStock()),
                  // _menuTile(Icons.sell, "Purchase", AdminSuppliersScreen()),
                  // _menuTile(
                  //   Icons.account_balance_wallet,
                  //   "Purchase Expenses",
                  //   const PurchaseExpenseScreen(),
                  // ),

                  // _menuTile(
                  //   Icons.sell_outlined,

                  //   "Offers & Prices",
                  //   OfferPrice(),
                  // ),
                  // _menuTile(
                  //   Icons.storefront_outlined,
                  //   "Daily Closing",
                  //   DailyClosingScreen(),
                  // ),

                  // //Tray Return
                  // _menuTile(Icons.reply, "Tray Return", TrayReturn()),

                  // ///ADMINISTRATION
                  // _sectionTitle("ADMINISTRATION"),

                  // _menuTile(
                  //   Icons.report,
                  //   "Report",
                  //   AdminReportDashboardScreen(),
                  // ),
                  // _menuTile(Icons.settings, "setting", AdminSettingsScreen()),
                  // _menuTile(Icons.money, "Expenses", ExpenseManagement()),
                  // const SizedBox(height: 20),

                  ///ADMINISTRATION
                  _sectionTitle("ADMINISTRATION"),
                  _menuTile(
                    Icons.pie_chart_outline_outlined,
                    "Reports",
                    AdminReportDashboardScreen(),
                  ),

                  //Report
                  // _menuTile(
                  //   Icons.report,
                  //   "Report",
                  //   AdminReportDashboardScreen(),
                  // ),
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
      dense: true, // reduce height
      minVerticalPadding: 0,
      horizontalTitleGap: 8, // icon ↔ text gap reduce
      minLeadingWidth: 20, // icon width reduce

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),

      leading: Icon(icon, size: 18, color: Colors.black87),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,

          height: 1, // text line spacing reduce
        ),
      ),

      visualDensity: const VisualDensity(
        horizontal: 0,
        vertical: 0, // menu item height reduce
      ),

      onTap: () {
        Navigator.pop(context);

        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 18, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
