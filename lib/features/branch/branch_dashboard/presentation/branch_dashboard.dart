import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/bloc/dashboard_bloc.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/bloc/dashboard_event.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/bloc/dashboard_state.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/presentation/resentactivity.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'package:proteinova_connect/features/branch/sales/presentation/sales_entry.dart';
import 'package:shimmer/shimmer.dart';

class BranchDashboard extends StatefulWidget {
  const BranchDashboard({super.key});

  @override
  State<BranchDashboard> createState() => _BranchDashboardState();
}

class _BranchDashboardState extends State<BranchDashboard> {
  late final DashboardRepository repository;
  late DashboardBloc dashboardBloc;
  String userRole = "Staff";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    repository = DashboardRepository(DioClient().dio);
    dashboardBloc = DashboardBloc(repository);
    dashboardBloc.add(FetchDashboardEvent());
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        final roleStr = prefs.getString('role') ?? 'staff';
        userRole = roleStr.isNotEmpty
            ? '${roleStr[0].toUpperCase()}${roleStr.substring(1)}'
            : 'Staff';
      });
    }
  }

  String formatDateTime(String dateStr) {
    if (dateStr.isEmpty) return "No Date";
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String formatNumber(num value) {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(value);
  }

  void _openDetailsModal(
    BuildContext context,
    String title,
    List<Map<String, String>> modalData,
  ) {
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
                                  width: 1.5,
                                ),
                              ),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  "Item / Category",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  "Value",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  "Notes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          ...modalData.map((row) {
                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF1F5F9),
                                    width: 1,
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    row["label"] ?? "",
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    row["value"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    row["sub"] ?? "",
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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

  int getCrossAxisCountGroup1(double width) {
    if (width > 1000) return 3;
    return 2;
  }

  int getCrossAxisCountGroup2(double width) {
    if (width > 1100) return 4;
    if (width > 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => dashboardBloc,
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          // LOADING STATE
          if (state is DashboardLoading) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [buildShimmerLoader()],
                ),
              ),
            );
          }

          // ERROR STATE
          if (state is DashboardError) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Failed to load dashboard",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          dashboardBloc.add(FetchDashboardEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD400),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Retry",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // SUCCESS STATE
          if (state is DashboardLoaded) {
            final dashboardModel = state.dashboard;

            return Scaffold(
              backgroundColor: AppColors.background,
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xff0B74FF),
                child: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesEntryPage()),
                  ).then((_) {
                    dashboardBloc.add(FetchDashboardEvent());
                  });
                },
              ),
              body: RefreshIndicator(
                color: const Color(0xff0B74FF),
                onRefresh: () async {
                  dashboardBloc.add(FetchDashboardEvent());
                },
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 36),

                        // Header Row (title + status)
                        _buildHeader(dashboardModel),

                        SizedBox(height: width < 700 ? 6 : 16),
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                          // Mobile → 2
                          // Tablet → 3
                          // Desktop → 4
                          crossAxisCount: width >= 1000
                              ? 4
                              : width >= 700
                              ? 3
                              : 2,

                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,

                          childAspectRatio: width >= 1000
                              ? 1.65
                              : width >= 700
                              ? 1.35
                              : 1.05,
                          children: [
                            // Sales Today
                            _buildMetricCard(
                              title: "OPENING STOCKS",
                              value: formatNumber(
                                dashboardModel.cards.openingStocks,
                              ),
                              valueUnit: "Eggs",
                              icon: Icons.inventory_2_outlined,
                              iconColor: const Color(0xFF3B82F6),
                              iconBgColor: const Color(0xFFEFF6FF),

                              onTap: () {
                                final data = dashboardModel.stockSummary
                                    .map(
                                      (s) => {
                                        "label": s.eggCategoryGrade,
                                        "value": "${s.trays} Trays",
                                        "sub": "${s.eggs} Eggs",
                                      },
                                    )
                                    .toList();

                                _openDetailsModal(
                                  context,
                                  "Opening Stock Breakdown",
                                  data,
                                );
                              },

                              footer: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "+2.5%",
                                      style: TextStyle(
                                        fontSize: width < 700 ? 10 : 9,
                                        color: const Color(0xFF16A34A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      "from last week",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: width < 700 ? 10 : 9,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Incoming Stock
                            _buildMetricCard(
                              title: "INCOMING STOCK",
                              value: formatNumber(
                                dashboardModel.cards.incomingStockInTransit,
                              ),
                              valueUnit: "Eggs",
                              icon: Icons.local_shipping_outlined,
                              iconColor: const Color(0xFFF97316),
                              iconBgColor: const Color(0xFFFFF7ED),

                              onTap: () {
                                final data = dashboardModel.incomingShipments
                                    .map(
                                      (s) => {
                                        "label": "Dispatch #DS-${s.id}",
                                        "value": "${s.totalTrays} Trays",
                                        "sub": s.arrivalDate != null
                                            ? "Arrival: ${formatDateTime(s.arrivalDate!)}"
                                            : "Arrival: Pending",
                                      },
                                    )
                                    .toList();

                                _openDetailsModal(
                                  context,
                                  "Incoming Shipments",
                                  data,
                                );
                              },

                              footer: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "In Transit",
                                      style: TextStyle(
                                        fontSize: width < 700 ? 10 : 9,
                                        color: const Color(0xFFF97316),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      "${dashboardModel.incomingShipments.length} shipments",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: width < 700 ? 10 : 9,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Damaged Stock
                            _buildMetricCard(
                              title: "DAMAGED STOCK",
                              value: formatNumber(
                                dashboardModel.cards.damagedStock,
                              ),
                              valueUnit: "Trays",
                              icon: Icons.warning_amber_rounded,
                              iconColor: const Color(0xFFEF4444),
                              iconBgColor: const Color(0xFFFEF2F2),

                              onTap: () {
                                final data = dashboardModel.damagedDetails
                                    .map(
                                      (d) => {
                                        "label": d.eggCategoryGrade,
                                        "value": "${d.trays} Trays",
                                        "sub": "Damaged Trays",
                                      },
                                    )
                                    .toList();

                                _openDetailsModal(
                                  context,
                                  "Damaged Stock Breakdown",
                                  data,
                                );
                              },

                              footer: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Attention",
                                      style: TextStyle(
                                        fontSize: width < 700 ? 10 : 9,
                                        color: const Color(0xFFDC2626),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      "Action required",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: width < 700 ? 10 : 9,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildMetricCard(
                              title: "SALES TODAY",
                              value:
                                  "₹${formatNumber(dashboardModel.cards.salesToday)}",
                              valueUnit: "",
                              icon: Icons.currency_rupee_outlined,
                              iconColor: const Color(0xFFD97706),
                              iconBgColor: const Color(0xFFFFFBEB),
                              onTap: () {
                                final data = dashboardModel.recentActivity
                                    .where((a) => a.tag.toLowerCase() == 'sale')
                                    .map(
                                      (a) => {
                                        "label": a.title,
                                        "value": a.amount != null
                                            ? "₹${formatNumber(a.amount!)}"
                                            : "₹0",
                                        "sub": a.description,
                                      },
                                    )
                                    .toList();
                                _openDetailsModal(
                                  context,
                                  "Recent Sales Details",
                                  data,
                                );
                              },
                              footer: Row(
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    color: Color(0xFF16A34A),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "+14.4%",
                                    style: TextStyle(
                                      fontSize: width < 400 ? 9 : 11,
                                      color: const Color(0xFF16A34A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "vs yesterday",
                                    style: TextStyle(
                                      fontSize: width < 400 ? 9 : 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Today Expense
                            _buildMetricCard(
                              title: "TODAY EXPENSE",
                              value:
                                  "₹${formatNumber(dashboardModel.cards.todayExpense)}",
                              valueUnit: "",
                              icon: Icons.trending_down_outlined,
                              iconColor: const Color(0xFFDC2626),
                              iconBgColor: const Color(0xFFFEF2F2),
                              onTap: () {
                                final data = dashboardModel.todayExpensesList
                                    .map(
                                      (e) => {
                                        "label": e.category,
                                        "value": "₹${formatNumber(e.amount)}",
                                        "sub":
                                            e.description ?? "No description",
                                      },
                                    )
                                    .toList();
                                _openDetailsModal(
                                  context,
                                  "Today's Expenses",
                                  data,
                                );
                              },
                              footer: Text(
                                "Recorded today",
                                style: TextStyle(
                                  fontSize: width < 400 ? 9 : 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),

                            // Eggs Sold Today
                            _buildMetricCard(
                              title: "EGGS SOLD TODAY",
                              value: formatNumber(
                                dashboardModel.cards.todayTraySold,
                              ),
                              valueUnit: dashboardModel.cards.todayTraySold == 1
                                  ? "Egg"
                                  : "Eggs",
                              icon: Icons.check_circle_outline,
                              iconColor: const Color(0xFF16A34A),
                              iconBgColor: const Color(0xFFF0FDF4),
                              onTap: () {
                                final data = [
                                  {
                                    "label": "Total Eggs Sold",
                                    "value":
                                        "${dashboardModel.cards.todayTraySold} Eggs",
                                    "sub": "Today's sales count",
                                  },
                                ];
                                _openDetailsModal(
                                  context,
                                  "Today's Eggs Sold",
                                  data,
                                );
                              },
                              footer: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF16A34A),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Completed transactions",
                                    style: TextStyle(
                                      fontSize: width < 400 ? 9 : 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Closing Stock
                            _buildMetricCard(
                              title: "CLOSING STOCK",
                              value: formatNumber(
                                dashboardModel.cards.closingStock,
                              ),
                              valueUnit: "Eggs",
                              icon: Icons.access_time_outlined,
                              iconColor: const Color(0xFF475569),
                              iconBgColor: const Color(0xFFF8FAFC),
                              onTap: () {
                                final data = dashboardModel.stockSummary
                                    .map(
                                      (s) => {
                                        "label": s.eggCategoryGrade,
                                        "value": "${s.trays} Trays",
                                        "sub": "${s.eggs} Eggs",
                                      },
                                    )
                                    .toList();
                                _openDetailsModal(
                                  context,
                                  "Closing Stock Breakdown",
                                  data,
                                );
                              },
                              footer: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF64748B),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Real-time update",
                                    style: TextStyle(
                                      fontSize: width < 400 ? 9 : 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Stock Summary Section
                        const Text(
                          "Stock Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),

                          itemCount: dashboardModel.stockSummary.length,

                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: width >= 1000
                                    ? 3
                                    : width >= 600
                                    ? 2
                                    : 1,

                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,

                                // REMOVE childAspectRatio
                                // REMOVE mainAxisExtent

                                // Add this
                                mainAxisExtent: 190,
                              ),

                          itemBuilder: (context, index) {
                            return Align(
                              alignment: Alignment.topCenter,
                              child: _buildStockSummaryCard(
                                dashboardModel.stockSummary[index],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Low Stock Alerts & Offers Grid
                        if (width >= 600)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildActiveOffers(
                                    dashboardModel.activeOffers,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildLowStockAlerts(
                                    dashboardModel.lowStockAlerts,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              _buildActiveOffers(dashboardModel.activeOffers),
                              const SizedBox(height: 24),
                              _buildLowStockAlerts(
                                dashboardModel.lowStockAlerts,
                              ),
                            ],
                          ),

                        const SizedBox(height: 32),

                        // Bar Graph & Recent Activity section
                        if (width > 800)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildDailySalesVolumeChart(
                                  dashboardModel.dailySalesVolume,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: _buildRecentActivity(
                                  dashboardModel.recentActivity,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildDailySalesVolumeChart(
                                dashboardModel.dailySalesVolume,
                              ),
                              const SizedBox(height: 24),
                              _buildRecentActivity(
                                dashboardModel.recentActivity,
                              ),
                            ],
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(DashboardModel dashboardModel) {
    final bool isClosed =
        dashboardModel.closingStatus?.toUpperCase() == 'CLOSED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${dashboardModel.branchName ?? "Branch"} Dashboard",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: Color(0xFF475569),
                ),
                const SizedBox(width: 4),
                Text(
                  "Role: $userRole",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isClosed
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isClosed
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFDCFCE7),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isClosed
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Branch: ${dashboardModel.closingStatus ?? "OPEN"}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isClosed
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF166534),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String valueUnit,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Widget footer,
    required VoidCallback onTap,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 8 : 11,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 24,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                          if (valueUnit.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              valueUnit,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 13,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: isSmallScreen ? 28 : 40,
                  height: isSmallScreen ? 28 : 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isSmallScreen ? 14 : 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSummaryCard(StockSummary item) {
    final bool isLowStock = item.trays < 50;
    final bool isReturnable = item.trayGroup.toLowerCase() == 'returnable';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.eggCategoryGrade,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isReturnable
                      ? const Color(0xFFE0F2FE)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isReturnable
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF475569),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.trayGroup,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isReturnable
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AVAILABLE TRAYS",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.trays}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEF3C7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TOTAL EGGS",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.eggs}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Live Inventory",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLowStock ? "Low Stock" : "Healthy",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isLowStock
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOffers(List<ActiveOffer> offers) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Active Offers",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${offers.length} ACTIVE",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (offers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "No active offers today",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final offer = offers[index];
                final bool isEven = index % 2 == 0;
                return Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isEven
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_offer_outlined,
                        color: isEven
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offer.condition,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.3,
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
    );
  }

  Widget _buildLowStockAlerts(List<LowStockAlert> alerts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Low Stock Alerts",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesEntryPage()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View Inventory",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "All stock levels are healthy",
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          alert.stock,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Left",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "CRITICAL",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDailySalesVolumeChart(List<DailySalesVolume> salesVolume) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daily Sales Volume",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendItem(const Color(0xFFFFD560), "Retail Sales (Units)"),
              const SizedBox(width: 12),
              _buildLegendItem(
                const Color(0xFF0B74FF),
                "Wholesale Sales (Units)",
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: salesVolume.isEmpty
                ? const Center(child: Text("No sales volume data available"))
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= salesVolume.length) {
                                return const SizedBox();
                              }
                              final dateStr = salesVolume[index].saleDate;
                              String formattedDay = "";
                              try {
                                final dt = DateTime.parse(dateStr);
                                formattedDay = DateFormat('EEE').format(dt);
                              } catch (_) {
                                formattedDay = dateStr;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  formattedDay,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF1E293B),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = rodIndex == 0
                                ? "Retail"
                                : "Wholesale";
                            return BarTooltipItem(
                              "$label: ${rod.toY.toInt()} Units",
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      barGroups: List.generate(salesVolume.length, (i) {
                        final item = salesVolume[i];
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: item.retailSalesUnits,
                              color: const Color(0xFFFFD560),
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: item.wholesaleSalesUnits,
                              color: const Color(0xFF0B74FF),
                              width: 8,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                          barsSpace: 4,
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<RecentActivity> activities) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Resentactivity()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  "No Recent Activity",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = activities[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(
                        item.title.isNotEmpty
                            ? item.title[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDateTime(item.time),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
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
    );
  }

  Widget shimmerCard({double height = 120, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget buildShimmerLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              return shimmerCard(height: 120);
            },
          ),

          const SizedBox(height: 20),

          // Sales chart placeholder
          shimmerCard(height: 250),

          // Products section
          shimmerCard(height: 180),

          // Damage report section
          shimmerCard(height: 180),

          // Transactions section
          shimmerCard(height: 300),
        ],
      ),
    );
  }
}
