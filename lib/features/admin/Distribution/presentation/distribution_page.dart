import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/dispatch_planning_page.dart';
import 'package:proteinova_connect/features/admin/Distribution/widget/dispatchcard_widget.dart';
import 'package:proteinova_connect/features/admin/Distribution/widget/statcard_widget.dart';
import 'package:proteinova_connect/services/dispatch_service.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class DistributionPage extends StatefulWidget {
  const DistributionPage({super.key});

  @override
  State<DistributionPage> createState() => _DistributionPageState();
}

class _DistributionPageState extends State<DistributionPage> {
  bool isLoading = true;
  Map<String, dynamic>? dashboardData;
  int currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final data = await DispatchService.fetchDispatchDashboard(
      page: currentPage,
      search: _searchController.text,
      status: _selectedStatus,
    );
    setState(() {
      dashboardData = data;
      isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.amber600;
      case 'LOADING':
        return AppColors.blueAccent;
      case 'IN_TRANSIT':
        return AppColors.blueAccent;
      case 'ARRIVAL':
        return Colors.teal; // Not in AppColors yet
      case 'DELIVERED':
        return AppColors.green;
      case 'CANCELLED':
        return AppColors.textSecondary;
      default:
        return AppColors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = dashboardData?['cards'];
    final dispatches = (dashboardData?['dispatches'] as List?) ?? [];
    final pagination = dashboardData?['pagination'];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Distribution Dashboard",
              style: AppTextStyles.headingText22,
            ),
            const SizedBox(height: 4),
            Text(
              "Monitor and manage all dispatches",
              style: AppTextStyles.bodyText14,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DispatchPlanningPage(),
                  ),
                ).then((value) {
                  if (value == true) _fetchData();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber500,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      "Create Dispatch",
                      style: AppTextStyles.bodyText14dark.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    /// TOP CARDS
                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            icon: Icons.local_shipping,
                            iconColor: AppColors.blueAccent,
                            title: "Active Vehicles",
                            count: "${cards?['active_vehicles'] ?? 0}",
                            subtitle: "Vehicles currently available",
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: statCard(
                            icon: Icons.send,
                            iconColor: AppColors.blueAccent,
                            title: "Today's Dispatches",
                            count: "${cards?['todays_dispatches'] ?? 0}",
                            subtitle: "Dispatched today",
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            icon: Icons.local_shipping_outlined,
                            iconColor: AppColors.green,
                            title: "In Transit",
                            count: "${cards?['in_transit'] ?? 0}",
                            subtitle: "Deliveries in progress",
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: statCard(
                            icon: Icons.inventory_2_outlined,
                            iconColor: AppColors.textSecondary,
                            title: "Total Delivered Today",
                            count: "${cards?['total_delivered_today'] ?? 0}",
                            subtitle: "Eggs delivered today",
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    /// DISPATCH SECTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: AppColors.textPrimary.withOpacity(0.03),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recent & Planned Dispatches",
                            style: AppTextStyles.headingText20,
                          ),
                          const SizedBox(height: 18),

                          /// SEARCH + FILTER
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          decoration: const InputDecoration(
                                            hintText: "Search dispatches...",
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          onSubmitted: (_) => _fetchData(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStatus.isEmpty
                                        ? null
                                        : _selectedStatus,
                                    hint: const Row(
                                      children: [
                                        Icon(Icons.tune, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          "Filter",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                    ),
                                    items:
                                        [
                                              "",
                                              "PENDING",
                                              "LOADING",
                                              "IN_TRANSIT",
                                              "DELIVERED",
                                              "CANCELLED",
                                            ]
                                            .map(
                                              (status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(
                                                  status.isEmpty
                                                      ? "All"
                                                      : status,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value ?? "";
                                        currentPage = 1;
                                      });
                                      _fetchData();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// DISPATCH LIST
                          if (dispatches.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text("No dispatches found"),
                              ),
                            )
                          else
                            ...dispatches.map((dispatch) {
                              if (dispatch == null)
                                return const SizedBox.shrink();

                              final String vehicleDriver =
                                  dispatch['vehicle_driver']?.toString() ?? "-";
                              final String driverPart =
                                  vehicleDriver.contains('(')
                                  ? vehicleDriver
                                        .split('(')
                                        .last
                                        .replaceAll(')', '')
                                        .trim()
                                  : '-';
                              final String vehiclePart = vehicleDriver
                                  .split('(')
                                  .first
                                  .trim();

                              return dispatchCard(
                                id: dispatch['dispatch_id']?.toString() ?? "-",
                                date: dispatch['date']?.toString() ?? "-",
                                branch:
                                    dispatch['destination_branch']
                                        ?.toString() ??
                                    "-",
                                vehicle: vehiclePart,
                                driver: driverPart,
                                qty: dispatch['total_qty']?.toString() ?? "0",
                                status:
                                    dispatch['status']?.toString() ?? "PENDING",
                                statusColor: _getStatusColor(
                                  dispatch['status']?.toString() ?? "PENDING",
                                ),
                              );
                            }),

                          const SizedBox(height: 20),

                          /// PAGINATION
                          if (pagination != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Showing ${(currentPage - 1) * 10 + 1} to ${((currentPage - 1) * 10 + dispatches.length)} of ${pagination['total']} dispatches",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      onPressed: currentPage > 1
                                          ? () {
                                              setState(() => currentPage--);
                                              _fetchData();
                                            }
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 38,
                                      width: 38,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$currentPage",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      onPressed:
                                          currentPage <
                                              (pagination['total_pages'] ?? 1)
                                          ? () {
                                              setState(() => currentPage++);
                                              _fetchData();
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
