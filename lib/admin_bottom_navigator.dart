import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/dispatch_planning_page.dart';
import 'package:proteinova_connect/features/admin/Receiving%20branch/presentation/receiving_branch.dart';
import 'package:proteinova_connect/features/admin/add%20branch/presentation/add_branch.dart';
import 'package:proteinova_connect/features/admin/admin%20branch/presentation/admin_branch.dart';
import 'package:proteinova_connect/features/admin/dailyclosing/screen/dailyclosing.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_bloc.dart';
import 'package:proteinova_connect/features/admin/expense/data/repository/expense_repository.dart';
import 'package:proteinova_connect/features/admin/inventory/presentation/admin_inventory.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/bloc/asset_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/data/asset_repository.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/bloc/tray_receive_bloc.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/bloc/tray_receive_event.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/data/services/tray_receive_service.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/bloc/sales_dashboard_event.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/data/datasource/sales_remote_datasource.dart';

import 'package:proteinova_connect/features/admin/purchase/presentation/purchase.dart';
import 'package:proteinova_connect/features/admin/purchase/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/admin/purchase/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/admin/purchase/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/admin/purchase/data/repository/supplier_repository.dart'
    as admin_supplier;
import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';
import 'package:proteinova_connect/features/admin/settings/screens/admin_settings_screen.dart';
import 'package:proteinova_connect/features/admin/supplier/bloc/supplier_bloc.dart';
import 'package:proteinova_connect/features/admin/supplier/data/services/supplier_service.dart';
import 'package:proteinova_connect/features/admin/supplier/screens/add_suppliers.dart';
import 'package:proteinova_connect/features/admin/tray_management/screen/tray_management.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/presentation/admin_damage_entry.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_event.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/distribution_page.dart';
import 'package:proteinova_connect/features/admin/addprice/presentation/add_price.dart';
import 'package:proteinova_connect/features/admin/approval/screens/approvals_queue_screen.dart';
import 'package:proteinova_connect/features/admin/expense/screens/admin_expense_screen.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/presentation/asset_management_page.dart';
import 'package:proteinova_connect/features/admin/menu/ReceiveTrays/presentation/receive_trays_screen.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_dashoard.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_dashboard.dart';
import 'package:proteinova_connect/features/admin/presentation/offer_price.dart';
import 'package:proteinova_connect/features/admin/supplier/screens/admin_suppliers_screen.dart';
import 'package:proteinova_connect/features/admin/presentation/Incoming_stock.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/screens/purchase_expense_screen.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/bloc/purchase_bloc.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/data/repository/purchase_expense_repository.dart';
import 'package:proteinova_connect/features/auth/presentation/signup_screen.dart';
import 'package:proteinova_connect/features/admin/admin customertrays/presentation/admin_customer_trays.dart';
import 'package:proteinova_connect/features/branch/tray_returns/presentation/tray_returns.dart';

import 'features/admin/menu/SalesDashboard/bloc/sales_dashboard_bloc.dart';

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
              width: MediaQuery.of(context).size.width > 600
                  ? 320
                  : MediaQuery.of(context).size.width * 0.75,
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
    AdminInventory(role: 'admin',),
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
          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 0)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard_rounded, 0),
            _buildNavItem(Icons.currency_rupee_rounded, 1),
            _buildNavItem(Icons.inventory_2, 2),
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
        return "Inventory";
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
                  // ─── ADMIN ───────────────────────────────────────────
                  // _expansionSection(
                  //   icon: Icons.settings_outlined,
                  //   title: "Admin",
                  //   initiallyExpanded: true,
                  //   children: [
                  //     _menuTile(
                  //       Icons.dashboard_rounded,
                  //       "Dashboard",
                  //       AdminDashboard(),
                  //     ),
                  //     _menuTile(
                  //       Icons.currency_rupee_rounded,
                  //       "Add Price",
                  //       AddPriceScreen(),
                  //     ),
                  //     _menuTile(
                  //       Icons.verified_rounded,
                  //       "Approvals",
                  //       ApprovalsQueueScreen(),
                  //     ),
                  //     _menuTile(
                  //       Icons.notifications_outlined,
                  //       "Notifications",
                  //       AdminDashboard(),
                  //     ),
                  //   ],
                  // ),

                  // ─── WAREHOUSE ───────────────────────────────────────
                  _expansionSection(
                    icon: Icons.warehouse_outlined,
                    title: "Warehouse",
                    initiallyExpanded: true,
                    children: [
                      // _menuTile(
                      //   Icons.inventory_2_outlined,
                      //   "Inventory",
                      //   AdminInventory(role: "admin"),
                      // ),
                      _menuTile(
                        Icons.local_shipping_outlined,
                        "Incoming Stock",
                        IncomingStock(role: "admin"),
                      ),
                      _menuTile(
                        Icons.account_balance_wallet_outlined,
                        "Purchase Expense",
                        BlocProvider(
                          create: (_) =>
                              PurchaseExpenseBloc(PurchaseExpenseRepository()),
                          child: const PurchaseExpenseScreen(),
                        ),
                      ),
                       _menuTile(
                        Icons.local_shipping_outlined,
                        "Sales",
                      DistributionPage(),
                      ),
                       _menuTile(
                        Icons.add_circle_outline,
                        "Create New Sales",
                        DispatchPlanningPage(),
                      ),
                      _menuTile(
                        Icons.inventory_2_outlined,
                        "Tray Management",
                        TrayManagementScreen(),
                      ),
                      _menuTile(
                        Icons.reply,
                        "Receiving Tray",
                        BlocProvider(
                          create: (_) =>
                              TrayReceiveBloc(TrayReceiveService())
                                ..add(FetchTrayReceiveNotes()),
                          child: const ReceiveTraysScreen(),
                        ),
                      ),
                      // _menuTile(
                      //   Icons.account_balance_wallet_outlined,
                      //   "Asset Management",
                      //   BlocProvider(
                      //     create: (_) =>
                      //         AssetBloc(AssetRepository())
                      //           ..add(FetchAssetsEvent()),
                      //     child: AssetManagementPage(),
                      //   ),
                      // ),
                      _menuTile(
                        Icons.money,
                        "Expenses Overview",
                        BlocProvider(
                          create: (_) => BranchExpenseBloc(ExpenseRepository()),
                          child: const AdminExpenseScreen(),
                        ),
                      ),
                      _menuTile(
                        Icons.sell_outlined,
                        "Offers & Prices",
                        OfferPrice(),
                      ),
                     _menuTile(
                        Icons.inventory_2_outlined,
                        "Customer Trays",
                        const AdminCustomerTrays(),
                      ),
                       _menuTile(
                        Icons.error_outline_rounded,
                        "Damage Entry",
                        const AdminDamageEntryPage(),
                      ),
                    ],
                  ),

                  // ─── PURCHASE SECTION ────────────────────────────────
                  _expansionSection(
                    icon: Icons.local_shipping_outlined,
                    title: "Purchase Section",
                    children: [
                      _menuTile(
                        Icons.local_shipping_outlined,
                        "Purchases",
                        BlocProvider(
                          create: (_) => PurchaseBloc(
                            admin_supplier.SupplierRepository(DioClient().dio),
                            PurchaseRepository(
                              DioClient().dio,
                              PurchaseCacheService(),
                            ),
                            PurchaseCacheService(),
                          )..add(FetchPurchaseInitData()),
                          child: const Purchase(),
                        ),
                      ),
                    
                    ],
                  ),
                _expansionSection(
                    icon: Icons.groups_outlined,
                    title: "SUPPLIERS",
                    children: [
                     
                      _menuTile(
                        Icons.groups_outlined,
                        "Supplier",
                        BlocProvider(
                          create: (_) =>
                              SupplierBloc(SupplierService())
                                ..add(FetchSuppliersEvent()),
                          child: const AdminSuppliersScreen(),
                        ),
                      ),
                       _menuTile(
                        Icons.add_circle_outline,
                        "Add Supplier",
                         const  AddSuppliers()
                      ),

                    ],
                  ),

      
                  // ─── BRANCH SECTION ──────────────────────────────────
                  _expansionSection(
                    icon: Icons.storefront_outlined,
                    title: "Branch Section",
                    children: [
                      _menuTile(
                        Icons.storefront_outlined,
                        "Branch",
                        const AdminBranchPage(),
                      ),
                      _menuTile(
                        Icons.add_circle_outline,
                        "Add Branch",
                        AddBranchPage(),
                      ),
                      _menuTile(
                        Icons.shopping_cart_outlined,
                        "Sales",
                        BlocProvider(
                          create: (_) =>
                              SalesDashboardBloc(SalesRemoteDatasource())
                                ..add(FetchSalesDashboard()),
                          child: const SalesDashboardPage(),
                        ),
                      ),
                      _menuTile(
                        Icons.groups_outlined,
                        "Receiving From Branch",
                        ReceivingBranchDashboardPage(),
                      ),
                      _menuTile(
                        Icons.storefront_outlined,
                        "Daily Closing",
                        DailyClosingScreen(),
                      ),
                      _menuTile(Icons.reply, "Tray Return", TrayReturn()),
                    ],
                  ),

                  // ─── ADMINISTRATION ──────────────────────────────────
                  _expansionSection(
                    icon: Icons.pie_chart_outline_outlined,
                    title: "REPORTS",
                    children: [
                      _menuTile(
                        Icons.pie_chart_outline_outlined,
                        "Financial Summary",
                        AdminReportDashboardScreen(),
                      ),
                      _menuTile(
                        Icons.shopping_bag_outlined,
                        "Purchase Report",
                        PurchaseReportScreen(),
                      ),
                       _menuTile(
                        Icons.money_outlined,
                        "Expense Report",
                        ExpenseReportScreen(),
                      ),
                       _menuTile(
                        Icons.storefront_outlined,
                        "Branch Sales Report",
                        SalesReportScreen(),
                      ),
                        _menuTile(
                        Icons.inventory_2_outlined,
                        "Warehouse Report",
                        WarehouseReportScreen(),
                      ),
                    ],
                  ),
                    _expansionSection(
                    icon: Icons.settings_outlined,
                    title: "SETTINGS",
                    children: [
                      _menuTile(
                        Icons.warehouse_outlined,
                        "Company Details",
                        AdminReportDashboardScreen(),
                      ),
                      _menuTile(
                        Icons.person_outline,
                        "User Details",
                        PurchaseReportScreen(),
                      ),
                       _menuTile(
                        Icons.settings_outlined,
                        "Branch Settings",
                        ExpenseReportScreen(),
                      ),
                       _menuTile(
                        Icons.group_outlined,
                        "Staff Management",
                        SalesReportScreen(),
                      ),
                       
                    ],
                  ),

       

                  const SizedBox(height: 20),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
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

  Widget _expansionSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        childrenPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 20, color: Colors.grey.shade700),
        title: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            letterSpacing: 0.8,
          ),
        ),
        iconColor: Colors.grey.shade700,
        collapsedIconColor: Colors.grey.shade500,
        children: children,
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, Widget page) {
    return ListTile(
      dense: true,
      minVerticalPadding: 0,
      horizontalTitleGap: 8,
      minLeadingWidth: 20,
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
      leading: Icon(icon, size: 18, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1,
        ),
      ),
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
