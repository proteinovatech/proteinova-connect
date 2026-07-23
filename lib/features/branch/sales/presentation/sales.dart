import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:proteinova_connect/core/services/sales_receipt_service.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_bloc.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_event.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_state.dart';
import 'package:proteinova_connect/features/branch/sales/presentation/sales_entry.dart';
import 'package:proteinova_connect/features/branch/sales/widget/sales_skeleton_loader.dart';
import '../data/repository/sales_repository.dart';

// ─── Sales Page ───────────────────────────────────────────────────────────────
class Sales extends StatefulWidget {
  const Sales({super.key});
  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  int branchId = 0;
  String userRole = "Staff";
  final SalesRepository _repository = SalesRepository();
  late final SalesBloc _salesBloc;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchTerm = _searchController.text.toLowerCase());
    });
    _salesBloc = SalesBloc();
    loadBranchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _salesBloc.close();
    super.dispose();
  }

  Future<void> loadBranchData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        branchId = prefs.getInt('branch_id') ?? 1;
        final roleStr = prefs.getString('role') ?? 'staff';
        userRole = roleStr.isNotEmpty
            ? '${roleStr[0].toUpperCase()}${roleStr.substring(1)}'
            : 'Staff';
      });
      _salesBloc.add(FetchSalesDashboard(branchId: branchId));
    }
  }

  Color getStatusColor(String status, {String? orderId}) {
    final s = status.toLowerCase();
    final id = (orderId ?? "").toUpperCase();
    if (s == "pending_review" ||
        s == "pending approval" ||
        id.startsWith("REQ-")) {
      return Colors.orange;
    }
    if (s == "approved" ||
        s == "completed" ||
        s == "paid" ||
        s == "success" ||
        s == "accepted") {
      return Colors.green;
    }
    if (s == "rejected" || s == "cancelled") return Colors.red;
    if (s == "delivered" || s == "in transit") return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _salesBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background1,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text("Sales Overview", style: AppTextStyles.headingText22),
        ),
        body: BlocBuilder<SalesBloc, SalesState>(
          builder: (context, state) {
            if (state is SalesLoading) return const SalesSkeletonLoader();

            if (state is SalesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error: ${state.error}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _salesBloc.add(
                        FetchSalesDashboard(branchId: branchId),
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state is SalesDashboardLoaded) {
              final dashboardData = state.dashboardData;
              final salesOrders = state.salesOrders;

              final filteredOrders = salesOrders.where((order) {
                if (_searchTerm.isEmpty) return true;
                final orderId = (order['order_id'] ?? '')
                    .toString()
                    .toLowerCase();
                final customer = (order['customer'] ?? '')
                    .toString()
                    .toLowerCase();
                final status = (order['order_status'] ?? '')
                    .toString()
                    .toLowerCase();
                return orderId.contains(_searchTerm) ||
                    customer.contains(_searchTerm) ||
                    status.contains(_searchTerm);
              }).toList();

              final horizontalPadding = _adaptive<double>(
                context,
                mobile: 16,
                tablet: 24,
                desktop: 40,
              );

              return RefreshIndicator(
                onRefresh: () async =>
                    _salesBloc.add(FetchSalesDashboard(branchId: branchId)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(
                        dashboardData['branch_name'] ?? "Branch",
                      ),
                      const SizedBox(height: 20),
                      _buildDashboardGrid(dashboardData['cards'] ?? {}),
                      const SizedBox(height: 28),
                      _buildRecentOrdersHeader(context, dashboardData),
                      const SizedBox(height: 12),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildRecentOrdersTable(filteredOrders),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeaderSection(String branchName) {
    final isDesktop = MediaQuery.of(context).size.width >= _Breakpoints.tablet;
    final buttonMinWidth = _adaptive<double>(
      context,
      mobile: 130,
      tablet: 150,
      desktop: 170,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Branch info — takes all available space, never overflows
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$branchName Overview",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 13,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Role: $userRole",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Fixed-width "New Entry" button — never shrinks branch name
        SizedBox(
          width: buttonMinWidth,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesEntryPage()),
            ).then((_) => loadBranchData()),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              "New Entry",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Dashboard Grid ──────────────────────────────────────────────────────────

  Widget _buildDashboardGrid(Map<String, dynamic> cards) {

    // Adaptive column count
    final crossAxisCount = _adaptive<int>(
      context,
      mobile: 2,
      tablet: 4,
      desktop: 4,
    );

    // Adaptive aspect ratio — cards taller on mobile to avoid text cutoff
    final childAspectRatio = _adaptive<double>(
      context,
      mobile: 1.15,
      tablet: 1.45,
      desktop: 1.6,
    );

    // Adaptive spacing
    final spacing = _adaptive<double>(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard(
          "Total Sales",
          "₹${((cards['total_sales']?['value'] ?? 0) as num).toLocaleString()}",
          "Lifetime Revenue",
          Icons.currency_rupee,
          const Color(0xFFFFFBEB),
          const Color(0xFFD97706),
          onTap: () {
            final breakdown =
                cards['payments_breakdown'] as List<dynamic>? ?? [];
            final modalData = breakdown
                .map(
                  (p) => {
                    'label': p['payment_method']?.toString() ?? "N/A",
                    'value': "₹${((p['amount'] ?? 0) as num).toLocaleString()}",
                    'sub': "${p['count'] ?? 0} Orders",
                  },
                )
                .toList();
            _openDetailsModal("Payment Method Breakdown", modalData);
          },
        ),
        _buildStatCard(
          "Total Orders",
          "${cards['total_orders']?['value'] ?? 0}",
          "Total Transactions",
          Icons.shopping_bag_outlined,
          const Color(0xFFF1F6FF),
          const Color(0xFF2563EB),
          onTap: () {
            _openDetailsModal("Order Volume Details", [
              {
                'label': "Total Transactions",
                'value': "${cards['total_orders']?['value'] ?? 0}",
                'sub': "Total unique sales generated lifetime",
              },
            ]);
          },
        ),
        _buildStatCard(
          "Eggs Sold (Today)",
          "${((cards['total_sales_eggs']?['value'] ?? 0) as num).toLocaleString()}",
          "Today's Volume",
          Icons.egg_outlined,
          const Color(0xFFEFF6FF),
          const Color(0xFF3B82F6),
          onTap: () {
            final breakdown = cards['eggs_breakdown'] as List<dynamic>? ?? [];
            final modalData = breakdown
                .map(
                  (e) => {
                    'label': e['egg_category_grade']?.toString() ?? "N/A",
                    'value':
                        "${((e['eggs'] ?? 0) as num).toLocaleString()} Eggs",
                    'sub': "${e['trays'] ?? 0} Trays Sold",
                  },
                )
                .toList();
            _openDetailsModal("Egg Sales Breakdown", modalData);
          },
        ),
        _buildStatCard(
          "Today's Sales",
          "₹${((cards['total_sales']?['today'] ?? 0) as num).toLocaleString()}",
          "Recorded Today",
          Icons.trending_up,
          const Color(0xFFF0FDF4),
          const Color(0xFF16A34A),
          onTap: () {
            final breakdown =
                cards['today_payments_breakdown'] as List<dynamic>? ?? [];
            final modalData = breakdown
                .map(
                  (p) => {
                    'label': p['payment_method']?.toString() ?? "N/A",
                    'value': "₹${((p['amount'] ?? 0) as num).toLocaleString()}",
                    'sub': "${p['count'] ?? 0} Orders Today",
                  },
                )
                .toList();
            _openDetailsModal("Today's Sales Breakdown", modalData);
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color bg,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    // Fixed, screen-independent sizes to avoid runaway scaling on large screens
    const double titleFontSize = 12;
    const double valueFontSize = 18;
    const double subFontSize = 10;
    const double iconSize = 18;
    const double iconPadding = 8;
    const double iconRadius = 10;
    const double cardPadding = 12;
    const double cardRadius = 16;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(cardRadius),
      child: Container(
        padding: const EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title row: text + icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(iconRadius),
                  ),
                  child: Icon(icon, size: iconSize, color: iconColor),
                ),
              ],
            ),
            // Value + subtitle pinned to bottom
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: subFontSize,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
          hintText: "Search orders...",
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─── Recent Orders Header ────────────────────────────────────────────────────

  Widget _buildRecentOrdersHeader(
    BuildContext context,
    Map<String, dynamic> dashboardData,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Sales Orders",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        // TextButton.icon(
        //   onPressed: () => _handleExport(dashboardData),
        //   icon: const Icon(Icons.ios_share, size: 15),
        //   label: const Text("Export"),
        //   style: TextButton.styleFrom(
        //     foregroundColor: const Color(0xFF6366F1),
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //   ),
        // ),
      ],
    );
  }

  // ─── Orders Table ────────────────────────────────────────────────────────────

  Widget _buildRecentOrdersTable(List<dynamic> orders) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No sales records found",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final isTablet = MediaQuery.of(context).size.width >= _Breakpoints.mobile;
    if (isTablet) {
      return _buildRecentOrdersTableDesktop(orders);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (_, index) => _buildOrderListItem(orders[index]),
      ),
    );
  }

  Widget _buildRecentOrdersTableDesktop(List<dynamic> orders) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2), // Order ID
          1: FlexColumnWidth(1.2), // Date
          2: FlexColumnWidth(1.5), // Customer
          3: FlexColumnWidth(1.2), // Eggs (Qty)
          4: FlexColumnWidth(1.2), // Amount
          5: FlexColumnWidth(1.2), // Status
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        children: [
          // Header Row
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "ORDER ID",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "DATE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "CUSTOMER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "EGGS (QTY)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "AMOUNT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "STATUS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Data Rows
          ...orders.map((order) {
            final status =
                (order['order_status'] ?? order['status'] ?? "Completed")
                    .toString();
            final statusColor = getStatusColor(
              status,
              orderId: order['order_id']?.toString(),
            );
            final orderId = order['id'] ?? order['order_id'];

            String dateFormatted = "";
            if (order['date'] != null) {
              try {
                dateFormatted = DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(order['date'].toString()));
              } catch (_) {
                dateFormatted = order['date'].toString();
              }
            }

            final customerName =
                order['customer']?.toString() ?? "Walk-in Customer";
            final paymentMethod =
                (order['payment_method'] ?? order['payment_mode'] ?? "CASH")
                    .toString();

            Widget cell({required Widget child, double vertical = 12}) {
              return InkWell(
                onTap: () => _showOrderDetails(orderId),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: vertical),
                  child: child,
                ),
              );
            }

            return TableRow(
              children: [
                cell(
                  child: Text(
                    order['order_id']?.toString() ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                cell(
                  child: Text(
                    dateFormatted,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                cell(
                  vertical: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        paymentMethod.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                cell(
                  child: Text(
                    "${order['items_qty'] ?? 0} Eggs",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                cell(
                  child: Text(
                    "₹${((order['amount'] ?? 0) as num).toLocaleString()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                cell(
                  vertical: 10,
                  child: Center(
                    child: _statusBadge(status, statusColor, isTablet: true),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderListItem(dynamic order) {
    final status = (order['order_status'] ?? order['status'] ?? "Completed")
        .toString();
    final statusColor = getStatusColor(
      status,
      orderId: order['order_id']?.toString(),
    );
    final orderId = order['id'] ?? order['order_id'];
    final isTablet = MediaQuery.of(context).size.width >= _Breakpoints.mobile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Customer + order ID
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  order['customer']?.toString() ?? "Walk-in Customer",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${order['order_id']} • ${DateFormat('dd MMM').format(DateTime.parse(order['date']))}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Amount + quantity (only shown on tablet+ to avoid overflow on mobile)
          if (isTablet) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹${((order['amount'] ?? 0) as num).toLocaleString()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${order['items_qty']} Eggs",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ] else ...[
            // On mobile: show just amount inline, compact
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹${((order['amount'] ?? 0) as num).toLocaleString()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${order['items_qty']} Eggs",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(width: 18),
          _statusBadge(status, statusColor),
          const SizedBox(width: 4),

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF64748B),
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'view') {
                _showOrderDetails(orderId);
              } else if (value == 'print') {
                _handlePrintReceipt(orderId);
              } else if (value == 'cancel') {
                _handleCancelOrder(orderId);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'view',
                child: ListTile(
                  leading: Icon(Icons.visibility_outlined, size: 20),
                  title: Text('View Details'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'print',
                child: ListTile(
                  leading: Icon(Icons.print_outlined, size: 20),
                  title: Text('Print Receipt'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (status.toLowerCase() == 'pending approval' ||
                  status.toLowerCase() == 'pending_review')
                const PopupMenuItem<String>(
                  value: 'cancel',
                  child: ListTile(
                    leading: Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 20,
                    ),
                    title: Text(
                      'Cancel Order',
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, Color color, {bool isTablet = false}) {
    // Shorten label on small screens
    final isSmall = MediaQuery.of(context).size.width < _Breakpoints.mobile;
    final label = isSmall
        ? status
              .toUpperCase()
              .split(' ')
              .first // e.g. "COMPLETED", "PENDING"
        : status;

    if (isTablet) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 90),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ─── Details Modal ───────────────────────────────────────────────────────────

  void _openDetailsModal(String title, List<Map<String, String>> modalData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Detailed breakdown of the selected metric",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (modalData.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        "No detailed data available for this metric today.",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2.0),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.5),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                              ),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Item / Category",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Value",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Notes",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          ...modalData.map((row) {
                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    row['label'] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    row['value'] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    row['sub'] ?? "",
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Export ──────────────────────────────────────────────────────────────────

  Future<void> _handleExport(Map<String, dynamic> dashboardData) async {
    final recentOrders = dashboardData['recent_orders'] as List<dynamic>?;
    if (recentOrders == null || recentOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No recent orders to export.")),
      );
      return;
    }

    try {
      final headers = [
        "Order ID",
        "Date",
        "Customer",
        "Items",
        "Amount",
        "Status",
      ];
      final rows = recentOrders.map((o) {
        String dateFormatted = "";
        if (o['date'] != null) {
          try {
            dateFormatted = DateFormat(
              'dd/MM/yyyy',
            ).format(DateTime.parse(o['date'].toString()));
          } catch (_) {
            dateFormatted = o['date'].toString();
          }
        }
        return [
          o['order_id']?.toString() ?? "",
          dateFormatted,
          o['customer']?.toString() ?? "",
          o['items_qty']?.toString() ?? "",
          o['amount']?.toString() ?? "",
          o['order_status']?.toString() ?? "",
        ];
      }).toList();

      String csvContent = "${headers.join(",")}\n";
      for (var row in rows) {
        csvContent +=
            row
                .map((f) => '"${f.toString().replaceAll('"', '""')}"')
                .join(",") +
            "\n";
      }

      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${directory.path}/sales_report_$dateStr.csv');
      await file.writeAsString(csvContent);
      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Export failed: $e")));
    }
  }

  // ─── Print / Cancel ──────────────────────────────────────────────────────────

  void _handlePrintReceipt(dynamic orderId) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final order = await _repository.fetchSingleSale(orderId.toString());
      if (mounted) {
        Navigator.pop(context);
        final orderData = order['data'] ?? order;
        SalesReceiptService.generateAndPrintFromMap(orderData, isThermal: true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _handleCancelOrder(dynamic orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text(
          "Are you sure you want to cancel this pending order?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final intId = int.tryParse(orderId.toString());
      if (intId != null) {
        await _repository.rejectSale(approvalId: intId);
      } else {
        throw Exception("Invalid order ID for cancellation");
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order cancelled successfully.")),
        );
        _salesBloc.add(FetchSalesDashboard(branchId: branchId));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cancellation failed: $e")));
      }
    }
  }

  // ─── Order Details Modal ─────────────────────────────────────────────────────

  void _showOrderDetails(dynamic orderId) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final order = await _repository.fetchSingleSale(orderId.toString());
       print("===== ORDER DATA =====");
      print(order);
print(order.runtimeType);

if (order is Map) {
  order.forEach((key, value) {
    print("$key -> $value (${value.runtimeType})");
  });
}
      if (mounted) {
        Navigator.pop(context);
        try {
    _showOrderModal(order);
  } catch (e, stackTrace) {
    print("================================");
    print("BOTTOM SHEET ERROR");
    print(e);
    print(stackTrace);
    print("================================");
  }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showOrderModal(Map<String, dynamic> data) {
    final order = data['data'] ?? data;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = MediaQuery.of(context).size.width >= _Breakpoints.mobile;
    num toNum(dynamic value) {
  if (value == null) return 0;

  if (value is num) return value;

  return num.tryParse(value.toString()) ?? 0;
}
num getNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '0') ?? 0;
}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * (isTablet ? 0.80 : 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Invoice #${order['id']}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMMM yyyy, hh:mm a',
                                ).format(DateTime.parse(order['created_at'])),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _statusBadge(
                          order['payment_status'] ?? "PAID",
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _modalInfoColumn(
                              "CUSTOMER",
                              order['customer_name'] ?? "Walk-in Customer",
                              order['customer_number'] ?? "N/A",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _modalInfoColumn(
                              "PAYMENT",
                              order['payment_method'] ?? "CASH",
                              "Status: ${order['payment_method'] ?? 'N/A'}",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "ITEMIZED BREAKDOWN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (order['items'] as List? ?? []).length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      itemBuilder: (_, index) {
                        final item = order['items'][index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['egg_category_grade'] ?? "Eggs",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item['trays']} Trays • ${item['total_eggs']} Eggs • ₹${item['rate_per_tray']}/tray",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "₹${toNum(item['subtotal']).toLocaleString()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _summaryRow(
                            "Subtotal",
                            "₹${getNum(order['total_amount']).toLocaleString()}",
                            Colors.white70,
                          ),
                          const SizedBox(height: 12),
                          _summaryRow(
                            "Discount",
                            "-₹${toNum(order['discount_amount']).toLocaleString()}",
                            Colors.redAccent,
                          ),
                          const Divider(height: 24, color: Colors.white12),
                          _summaryRow(
                            "Grand Total",
                            "₹${toNum(order['net_amount'] ?? order['amount']).toLocaleString()}",
                            Colors.white,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SalesReceiptService.generateAndPrintFromMap(
                                order,
                                isThermal: true,
                              );
                            },
                            icon: const Icon(Icons.print, size: 18),
                            label: const Text("Print Receipt"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF1E293B),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SalesReceiptService.generateAndPrintFromMap(
                                order,
                                isThermal: false,
                              );
                            },
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text("Download PDF"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modalInfoColumn(String label, String primary, String secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          primary,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
          secondary,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ─── Number Formatting Extension ─────────────────────────────────────────────
extension NumberFormatting on num {
  String toLocaleString() {
    return NumberFormat.decimalPattern('en_IN').format(this);
  }
}

// ─── Adaptive Breakpoints ─────────────────────────────────────────────────────
class _Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  // > tablet is treated as desktop
}

/// Returns a value based on screen width breakpoints.
T _adaptive<T>(
  BuildContext context, {
  required T mobile,
  required T tablet,
  required T desktop,
}) {
  final w = MediaQuery.of(context).size.width;
  if (w < _Breakpoints.mobile) return mobile;
  if (w < _Breakpoints.tablet) return tablet;
  return desktop;
}
