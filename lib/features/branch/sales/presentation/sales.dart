import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
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

class Sales extends StatefulWidget {
  const Sales({super.key});
  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  Size get size => MediaQuery.of(context).size;
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
      setState(() {
        _searchTerm = _searchController.text.toLowerCase();
      });
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
    if (s == "rejected" || s == "cancelled") {
      return Colors.red;
    }
    if (s == "delivered" || s == "in transit") {
      return Colors.blue;
    }
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
            if (state is SalesLoading) {
              return const SalesSkeletonLoader();
            }

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

              return RefreshIndicator(
                onRefresh: () async =>
                    _salesBloc.add(FetchSalesDashboard(branchId: branchId)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(
                        dashboardData['branch_name'] ?? "Branch",
                      ),
                      const SizedBox(height: 24),
                      _buildDashboardGrid(dashboardData['cards'] ?? {}),
                      const SizedBox(height: 32),
                      _buildRecentOrdersHeader(context, dashboardData),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildRecentOrdersTable(filteredOrders),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String branchName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$branchName Overview",
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 14,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 4),
                Text(
                  "Role: $userRole",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      Expanded(
  child: ElevatedButton.icon(
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SalesEntryPage(),
      ),
    ).then((_) => loadBranchData()),

    icon: Icon(
      Icons.add,
      size: getWidth(context, 18),
    ),

    label: FittedBox(
      child: Text(
        "New Entry",
        style: TextStyle(
          fontSize: getWidth(context, 12),
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.amber600,
      foregroundColor: Colors.white,

      padding: EdgeInsets.symmetric(
        horizontal: getWidth(context, 8),
        vertical: getHeight(context, 12),
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          getWidth(context, 12),
        ),
      ),

      elevation: 0,
    ),
  ),
),]);
  }

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
            constraints: const BoxConstraints(maxWidth: 500),
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
                          }).toList(),
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

  Widget _buildDashboardGrid(Map<String, dynamic> cards) {
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width >= 700;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 4 : 2,
      mainAxisSpacing: isTablet ? 12 : 16,
      crossAxisSpacing: isTablet ? 12 : 16,
      childAspectRatio: isTablet ? 1.55 : 1.3,
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
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(
      getWidth(context, 20),
    ),

    child: Container(
      padding: EdgeInsets.all(
        getWidth(context, 14),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          getWidth(context, 20),
        ),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: getWidth(context, 10),
            offset: Offset(
              0,
              getHeight(context, 4),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                        getWidth(context, 12),
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              SizedBox(
                width: getWidth(context, 6),
              ),
              Container(
                padding: EdgeInsets.all(
                  getWidth(context, 8),
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      BorderRadius.circular(
                    getWidth(context, 10),
                  ),
                ),
                child: Icon(
                  icon,
                  size: getWidth(context, 18),
                  color: iconColor,
                ),
              ),
            ],
          ),
          SizedBox(
            height: getHeight(context, 12),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize:
                    getWidth(context, 20),
                fontWeight: FontWeight.w800,
                color:
                    const Color(0xFF1E293B),
              ),
            ),
          ),
          SizedBox(
            height: getHeight(context, 4),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: getWidth(context, 10),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    ),
  );
}
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        TextButton.icon(
          onPressed: () => _handleExport(dashboardData),
          icon: const Icon(Icons.ios_share, size: 16),
          label: const Text("Export"),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
        ),
      ],
    );
  }

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

      String csvContent = headers.join(",") + "\n";
      for (var row in rows) {
        csvContent +=
            row
                .map((field) => '"${field.toString().replaceAll('"', '""')}"')
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
        Navigator.pop(context); // Remove loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order cancelled successfully.")),
        );
        _salesBloc.add(FetchSalesDashboard(branchId: branchId));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove loader
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Cancellation failed: $e")));
      }
    }
  }

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
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderListItem(order);
        },
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['customer']?.toString() ?? "Walk-in Customer",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${order['order_id']} • ${DateFormat('dd MMM').format(DateTime.parse(order['date']))}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${((order['amount'] ?? 0) as num).toLocaleString()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${order['items_qty']} Eggs",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _statusBadge(status, statusColor),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
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

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showOrderDetails(dynamic orderId) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final order = await _repository.fetchSingleSale(orderId.toString());
      if (mounted) {
        Navigator.pop(context); // Remove loader
        _showOrderModal(order);
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invoice #${order['invoice_no']}",
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
                        _statusBadge(
                          order['payment_status'] ?? "PAID",
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "CUSTOMER",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  order['customer_name'] ?? "Walk-in Customer",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  order['customer_phone'] ?? "N/A",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PAYMENT",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  order['payment_method'] ?? "CASH",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Status: ${order['payment_status']}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "ITEMIZED BREAKDOWN",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (order['items'] as List? ?? []).length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
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
                              "₹${((item['subtotal'] ?? 0) as num).toLocaleString()}",
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
                    const SizedBox(height: 32),
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
                            "₹${((order['total_amount'] ?? 0) as num).toLocaleString()}",
                            Colors.white70,
                          ),
                          const SizedBox(height: 12),
                          _summaryRow(
                            "Discount",
                            "-₹${((order['discount_amount'] ?? 0) as num).toLocaleString()}",
                            Colors.redAccent,
                          ),
                          const Divider(height: 24, color: Colors.white12),
                          _summaryRow(
                            "Grand Total",
                            "₹${((order['net_amount'] ?? order['amount'] ?? 0) as num).toLocaleString()}",
                            Colors.white,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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
                            icon: const Icon(Icons.print),
                            label: const Text("Print Receipt"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF1E293B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SalesReceiptService.generateAndPrintFromMap(
                                order,
                                isThermal: false,
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text("Download PDF"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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

extension NumberFormatting on num {
  String toLocaleString() {
    return NumberFormat.decimalPattern('en_IN').format(this);
  }
}
