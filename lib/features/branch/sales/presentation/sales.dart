import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  final SalesRepository _repository = SalesRepository();

  @override
  void initState() {
    super.initState();
    loadBranchData();
  }

  Future<void> loadBranchData() async {
    // TEMP STATIC ID - replace later with login user branch id
    branchId = 1;
    if (mounted) {
      setState(() {});
    }
  }

  Color getStatusColor(String status, {String? orderId}) {
    final s = status.toLowerCase();
    final id = (orderId ?? "").toUpperCase();

    if (s == "pending_review" || s == "pending approval" || id.startsWith("REQ-")) {
      return Colors.orange;
    }
    if (s == "approved" || s == "completed" || s == "paid" || s == "success" || s == "accepted") {
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
    return BlocProvider(
      create: (context) => SalesBloc()..add(FetchSalesDashboard(branchId: branchId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Sales Overview", style: AppTextStyles.headingText22),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_outlined, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Branch+User&background=6366f1&color=fff'),
              ),
            ),
          ],
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
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text("Error: ${state.error}", style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<SalesBloc>().add(FetchSalesDashboard(branchId: branchId)),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state is SalesDashboardLoaded) {
              final dashboardData = state.dashboardData;
              final salesOrders = state.salesOrders;

              return RefreshIndicator(
                onRefresh: () async => context.read<SalesBloc>().add(FetchSalesDashboard(branchId: branchId)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(dashboardData['branch_name'] ?? "Branch"),
                      const SizedBox(height: 24),
                      _buildDashboardGrid(dashboardData['cards'] ?? {}),
                      const SizedBox(height: 32),
                      _buildRecentOrdersHeader(context),
                      const SizedBox(height: 16),
                      _buildRecentOrdersTable(salesOrders),
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
            Text("$branchName Overview", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.verified_user, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text("Branch Staff Account", style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
              ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesEntryPage())).then((_) => loadBranchData()),
          icon: const Icon(Icons.add, size: 20),
          label: const Text("New Entry"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(Map<String, dynamic> cards) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard("Total Sales", "₹${((cards['total_sales']?['value'] ?? 0) as num).toLocaleString()}", "Lifetime Revenue", Icons.currency_rupee, const Color(0xFFFFFBEB), const Color(0xFFD97706)),
        _buildStatCard("Total Orders", "${cards['total_orders']?['value'] ?? 0}", "Total Transactions", Icons.shopping_bag_outlined, const Color(0xFFF1F6FF), const Color(0xFF2563EB)),
        _buildStatCard("Eggs Sold", "${((cards['total_sales_eggs']?['value'] ?? 0) as num).toLocaleString()}", "Today's Volume", Icons.egg_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6)),
        _buildStatCard("Today's Sales", "₹${((cards['total_sales']?['today'] ?? 0) as num).toLocaleString()}", "Recorded Today", Icons.trending_up, const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String sub, IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        // ignore: deprecated_member_use
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.5)),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: iconColor)),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Recent Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.ios_share, size: 16),
          label: const Text("Export"),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersTable(List<dynamic> orders) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No sales records found", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
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
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderListItem(order);
        },
      ),
    );
  }

  Widget _buildOrderListItem(dynamic order) {
    final status = (order['order_status'] ?? order['status'] ?? "Completed").toString();
    final statusColor = getStatusColor(status, orderId: order['order_id']?.toString());
    
    return InkWell(
      onTap: () => _showOrderDetails(order['id'] ?? order['order_id']),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              // ignore: deprecated_member_use
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order['customer']?.toString() ?? "Walk-in Customer", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text("${order['order_id']} • ${DateFormat('dd MMM').format(DateTime.parse(order['date']))}", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${((order['amount'] ?? 0) as num).toLocaleString()}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text("${order['items_qty']} Eggs", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _statusBadge(status, statusColor),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      // ignore: deprecated_member_use
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
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
                            Text("Invoice #${order['invoice_no']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            Text(DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.parse(order['created_at'])), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                        _statusBadge(order['payment_status'] ?? "PAID", Colors.green),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("CUSTOMER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
                                const SizedBox(height: 8),
                                Text(order['customer_name'] ?? "Walk-in Customer", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(order['customer_phone'] ?? "N/A", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("PAYMENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
                                const SizedBox(height: 8),
                                Text(order['payment_method'] ?? "CASH", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("Status: ${order['payment_status']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text("ITEMIZED BREAKDOWN", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (order['items'] as List? ?? []).length,
                      separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final item = order['items'][index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['egg_category_grade'] ?? "Eggs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                                  const SizedBox(height: 4),
                                  Text("${item['trays']} Trays • ${item['total_eggs']} Eggs • ₹${item['rate_per_tray']}/tray", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            Text("₹${((item['subtotal'] ?? 0) as num).toLocaleString()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _summaryRow("Subtotal", "₹${((order['total_amount'] ?? 0) as num).toLocaleString()}", Colors.white70),
                          const SizedBox(height: 12),
                          _summaryRow("Discount", "-₹${((order['discount_amount'] ?? 0) as num).toLocaleString()}", Colors.redAccent),
                          const Divider(height: 24, color: Colors.white12),
                          _summaryRow("Grand Total", "₹${((order['net_amount'] ?? order['amount'] ?? 0) as num).toLocaleString()}", Colors.white, isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SalesReceiptService.generateAndPrintFromMap(order, isThermal: true);
                            },
                            icon: const Icon(Icons.print),
                            label: const Text("Print Receipt"),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9), foregroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SalesReceiptService.generateAndPrintFromMap(order, isThermal: false);
                            },
                            icon: const Icon(Icons.download),
                            label: const Text("Download PDF"),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
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

  Widget _summaryRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: color, fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

extension NumberFormatting on num {
  String toLocaleString() {
    return NumberFormat.decimalPattern('en_IN').format(this);
  }
}
