import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/admin/data/services/dashboard_service.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_dashboard_skeleton_loader.dart';

// Navigation target imports
import 'package:proteinova_connect/features/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/dispatch_planning_page.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_entry_page.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DashboardModel? dashboard;
  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await DashboardService().fetchDashboard();
      if (!mounted) return;
      setState(() {
        dashboard = data;
        isLoading = false;
        isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
      debugPrint("Error loading dashboard data: $e");
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    await _loadDashboard();
  }

  String formatCurrency(num val) {
    return "₹${NumberFormat('#,##,###').format(val)}";
  }

  String formatNumber(num val) {
    return NumberFormat('#,##,###').format(val);
  }

  String formatTimeAgo(dynamic dateValue) {
    if (dateValue == null) return "just now";
    try {
      final date = DateTime.parse(dateValue.toString());
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) {
        return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
      }
      if (diff.inHours > 0) {
        return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
      }
      if (diff.inMinutes > 0) {
        return "${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago";
      }
      return "just now";
    } catch (_) {
      return "just now";
    }
  }

  void _openDetailsModal({
    required String title,
    required List<dynamic> data,
    required String type,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: data.isEmpty
                    ? const Center(
                        child: Text(
                          "No detailed data available for this metric yet.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: data.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final item = data[idx];
                          final label =
                              item['category'] ??
                              item['branch_name'] ??
                              item['location'] ??
                              "N/A";
                          final value = type == "currency"
                              ? (item['revenue'] ?? item['total_value'] ?? 0)
                              : (item['total_eggs'] ??
                                    item['revenue'] ??
                                    item['total_value'] ??
                                    0);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  label.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                Text(
                                  type == "currency"
                                      ? formatCurrency(
                                          num.tryParse(value.toString()) ?? 0,
                                        )
                                      : "${formatNumber(num.tryParse(value.toString()) ?? 0)} Eggs",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAllActivitiesModal(List<dynamic> activities) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Activities",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: activities.isEmpty
                    ? const Center(child: Text("No recent activities."))
                    : ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final item = activities[idx];
                          final name = item['movement_type'] ?? "System";
                          final action =
                              "${item['tray_id']} moved from ${item['from_location'] ?? 'N/A'} to ${item['to_location'] ?? 'N/A'}.";
                          final timeStr = formatTimeAgo(item['created_at']);
                          final status = item['status'] ?? "Movement";

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : "S",
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "$name ",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: action),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$timeStr • $status",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: AdminDashboardSkeletonLoader()),
      );
    }

    // Prep dynamic stats & values
    final totalStockEggs = dashboard?.totalStockEggs ?? 0;
    final incomingStockEggs = dashboard?.incomingStockEggs ?? 0;
    final dispatchedStockEggs = dashboard?.dispatchedStockEggs ?? 0;
    final branchSalesEggs = dashboard?.branchSalesEggs ?? 0;
    final profit = num.tryParse(dashboard?.profit ?? '0') ?? 0;

    // Prep dynamic alerts list
    final alerts = <Map<String, dynamic>>[];
    if (dispatchedStockEggs < 1000 && dispatchedStockEggs > 0) {
      alerts.add({
        "type": "critical",
        "title": "Critical Stock Depletion",
        "description":
            "Dispatched stock is at ${formatNumber(dispatchedStockEggs)} eggs. Monitor replenishment.",
        "action": "Review & Reorder",
        "icon": Icons.warning_amber_rounded,
        "page": const Newpurchase(),
      });
    }
    if (incomingStockEggs > 0) {
      alerts.add({
        "type": "warning",
        "title": "Incoming Stock In Transit",
        "description":
            "${formatNumber(incomingStockEggs)} eggs are currently in transit. Track shipment progress.",
        "action": "Track Shipment",
        "icon": Icons.access_time_rounded,
      });
    }
    if (profit < 0) {
      alerts.add({
        "type": "warning",
        "title": "Profit Margin Alert",
        "description":
            "Estimated profit is currently negative (${formatCurrency(profit)}). Review pricing.",
        "action": "View Financials",
        "icon": Icons.error_outline_rounded,
        "page": const AdminReportDashboardScreen(),
      });
    }

    final activities = dashboard?.recentActivity ?? [];
    final recentActivities = activities.take(10).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text("Dashboard Overview", style: AppTextStyles.headingText22),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome & Role Header
              _buildRoleHeader(),
              const SizedBox(height: 20),

              // Horizontal Row of Action Buttons (as per requested screenshot!)
              _buildActionRow(context),
              const SizedBox(height: 24),

              // Dynamic Metric Cards Grid
              _buildMetricsGrid(
                totalStockEggs: totalStockEggs,
                incomingStockEggs: incomingStockEggs,
                dispatchedStockEggs: dispatchedStockEggs,
                branchSalesEggs: branchSalesEggs,
              ),
              const SizedBox(height: 24),

              // Recent Activities & Actions Required Dual Widgets
              _buildPanelsSection(recentActivities, activities, alerts),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to ERP Overview",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, size: 14, color: Colors.amber),
              SizedBox(width: 5),
              Text(
                "Role: Warehouse & Admin",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionButton(
            context: context,
            label: "Create\nPurchase Order",
            icon: Icons.add_circle_outline,
            targetPage: const Newpurchase(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            label: "Dispatch\nItems",
            icon: Icons.local_shipping_outlined,
            targetPage: const DispatchPlanningPage(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            label: "New Sales\nEntry",
            icon: Icons.receipt_long_outlined,
            targetPage: const SalesEntryPage(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            label: "Export\nReport",
            icon: Icons.exit_to_app_rounded,
            targetPage: const AdminReportDashboardScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Widget targetPage,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 115,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid({
    required num totalStockEggs,
    required num incomingStockEggs,
    required num dispatchedStockEggs,
    required num branchSalesEggs,
  }) {
    final revenue = num.tryParse(dashboard?.revenue ?? '0') ?? 0;
    final totalStockValue = dashboard?.totalStockValue ?? 0;
    final branchRevenue = num.tryParse(dashboard?.branchRevenue ?? '0') ?? 0;

    final breakdowns = dashboard?.breakdowns ?? {};

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      children: [
        _buildMetricCard(
          title: "Total Revenue",
          value: formatCurrency(revenue),
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF0B74FF),
          onTap: () => _openDetailsModal(
            title: "Total Revenue Breakdown (by Category)",
            data: breakdowns['revenue_by_category'] ?? [],
            type: "currency",
          ),
        ),
        _buildMetricCard(
          title: "Total Stock Value",
          value: formatCurrency(totalStockValue),
          icon: Icons.currency_exchange_outlined,
          color: const Color(0xFF16A34A),
          onTap: () => _openDetailsModal(
            title: "Stock Value by Location/Branch",
            data: (breakdowns['inventory_by_location'] as List? ?? [])
                .map(
                  (e) => {
                    ...e,
                    "branch_name": e['location'],
                    "revenue": e['total_value'],
                  },
                )
                .toList(),
            type: "currency",
          ),
        ),
        _buildMetricCard(
          title: "Incoming Stock",
          value: "${formatNumber(incomingStockEggs)} Eggs",
          icon: Icons.warehouse_outlined,
          color: const Color(0xFFF97316),
          onTap: () => _openDetailsModal(
            title: "Incoming Stock by Category",
            data: breakdowns['incoming_by_category'] ?? [],
            type: "count",
          ),
        ),
        _buildMetricCard(
          title: "Total Dispatched",
          value: "${formatNumber(dispatchedStockEggs)} Eggs",
          icon: Icons.send_rounded,
          color: const Color(0xFF10B981),
          onTap: () => _openDetailsModal(
            title: "Dispatched Stock by Branch",
            data: breakdowns['dispatched_by_branch'] ?? [],
            type: "count",
          ),
        ),
        _buildMetricCard(
          title: "Total Revenue (Today)",
          value: formatCurrency(branchRevenue),
          icon: Icons.storefront_outlined,
          color: const Color(0xFFF59E0B),
          onTap: () => _openDetailsModal(
            title: "Today's Revenue by Branch",
            data: breakdowns['revenue_by_branch'] ?? [],
            type: "currency",
          ),
        ),
        _buildMetricCard(
          title: "Total Stock Eggs",
          value: "${formatNumber(totalStockEggs)} Eggs",
          icon: Icons.egg_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () => _openDetailsModal(
            title: "Stock Eggs by Location/Branch",
            data: (breakdowns['inventory_by_location'] as List? ?? [])
                .map((e) => {...e, "branch_name": e['location']})
                .toList(),
            type: "count",
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const Row(
              children: [
                Text(
                  "Tap to view breakdown",
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 8, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelsSection(
    List<dynamic> recentActivities,
    List<dynamic> activities,
    List<Map<String, dynamic>> alerts,
  ) {
    return Column(
      children: [
        // Recent Activity Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openAllActivitiesModal(activities),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      "View All",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "No recent activity.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentActivities.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, idx) {
                    final item = recentActivities[idx];
                    final name = item['movement_type'] ?? "System";
                    final action =
                        "${item['tray_id']} moved from ${item['from_location'] ?? 'N/A'} to ${item['to_location'] ?? 'N/A'}.";
                    final timeStr = formatTimeAgo(item['created_at']);
                    final category = item['status'] ?? "Movement";

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "S",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "$name ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: action),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$timeStr • $category",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Required Card (Alerts)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Action Required",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: alerts.isEmpty
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${alerts.length} Alerts",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: alerts.isEmpty ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (alerts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 36,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Everything is fine!",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "No urgent actions required at this moment.",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: alerts.map((alert) {
                    final isCritical = alert['type'] == 'critical';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCritical
                            ? Colors.red.shade50
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCritical
                              ? Colors.red.shade100
                              : Colors.amber.shade200,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            alert['icon'] as IconData,
                            size: 20,
                            color: isCritical
                                ? Colors.red
                                : Colors.amber.shade800,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['title'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isCritical
                                        ? Colors.red.shade900
                                        : Colors.amber.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alert['description'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCritical
                                        ? Colors.red.shade700
                                        : Colors.amber.shade800,
                                  ),
                                ),
                                if (alert['page'] != null) ...[
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              alert['page'] as Widget,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          alert['action'] as String,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 10,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
