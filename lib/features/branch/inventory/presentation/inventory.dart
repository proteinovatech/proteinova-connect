import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/branch_inventory_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_bloc.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_event.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_state.dart';
import 'package:proteinova_connect/features/branch/inventory/presentation/receivestock.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/shipmentcard.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  int branchId = 1;
  String userRole = "Staff";
  String branchName = "";
  final TextEditingController searchController = TextEditingController();
  final ScrollController _tableScrollController = ScrollController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    searchController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        branchId = prefs.getInt('branch_id') ?? 1;
        final roleStr = prefs.getString('role') ?? 'staff';
        userRole = roleStr.isNotEmpty
            ? '${roleStr[0].toUpperCase()}${roleStr.substring(1)}'
            : 'Staff';
      });
      // Fire the fetch event with dynamic branch ID
      context.read<InventoryBloc>().add(
        FetchInventoryEvent(branchId: branchId),
      );
    }
  }

  Future<void> handleMarkArrival(Map<String, dynamic> shipment) async {
    final rawId = shipment["dispatch_id"].toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (rawId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Dispatch ID not found in row data."),
        ),
      );
      return;
    }

    try {
      final String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? "";
      final response = await http.put(
        Uri.parse("$baseUrl/api/dispatch/$rawId/status"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"status": "ARRIVAL"}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Shipment marked as ARRIVED successfully!"),
            ),
          );
          context.read<InventoryBloc>().add(
            FetchInventoryEvent(branchId: branchId),
          );
        }
      } else {
        final errData = jsonDecode(response.body);
        final errMsg = errData['error'] ?? "Failed to mark arrival";
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errMsg)));
        }
      }
    } catch (e, stackTrace) {
      debugPrint("Error : $e");
      debugPrint("Stack : $stackTrace");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "No Date";
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return "Invalid Date";
    return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  String formatNumber(dynamic value) {
    if (value == null) return "0";
    final number = num.tryParse(value.toString()) ?? 0;
    return NumberFormat('#,##,###').format(number);
  }

  Color getStatusBgColor(String status) {
    switch (status.trim().toUpperCase()) {
      case "READY FOR UNLOAD":
      case "READY_FOR_UNLOAD":
      case "ARRIVAL":
        return const Color(0xFFDCFCE7); // green
      case "PENDING":
        return const Color(0xFFFFF3C7); // orange
      case "IN TRANSIT":
      case "IN_TRANSIT":
      case "EXPECTED TODAY":
      case "EXPECTED_TODAY":
        return const Color(0xFFE2E8F0); // gray
      case "DELAYED":
        return const Color(0xFFFEE2E2); // red
      case "TRACK SHIPMENT":
      case "TRACK_SHIPMENT":
        return Colors.black26;
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.trim().toUpperCase()) {
      case "READY FOR UNLOAD":
      case "READY_FOR_UNLOAD":
      case "ARRIVAL":
        return const Color(0xFF15803D);
      case "PENDING":
        return const Color(0xFFB45309);
      case "IN TRANSIT":
      case "IN_TRANSIT":
      case "EXPECTED TODAY":
      case "EXPECTED_TODAY":
        return const Color(0xFF475569);
      case "DELAYED":
        return const Color(0xFFB91C1C);
      case "TRACK SHIPMENT":
      case "TRACK_SHIPMENT":
        return Colors.black87;
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const Scaffold(body: Center(child: BranchInventorySkeleton()));
        }

        if (state is InventoryLoaded) {
          final inventoryData = state.inventoryData;
          final cards = inventoryData["cards"] ?? {};
          final rawShipments = inventoryData["shipments"] as List? ?? [];
          final recentActivity =
              inventoryData["recent_activity"] as List? ?? [];
          branchName = inventoryData["branch_name"] ?? "";

          // Filter shipments locally by search query
          final shipments = rawShipments.where((s) {
            if (searchQuery.isEmpty) return true;
            final q = searchQuery.toLowerCase();
            final code = (s["dispatch_code"] ?? "").toString().toLowerCase();
            final from = (s["supplier_or_from"] ?? "").toString().toLowerCase();
            final driver = (s["vehicle_driver"] ?? "").toString().toLowerCase();
            final prod = (s["product_summary"] ?? "").toString().toLowerCase();
            return code.contains(q) ||
                from.contains(q) ||
                driver.contains(q) ||
                prod.contains(q);
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop =
                  constraints.maxWidth >= _Breakpoints.tablet;

              return Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar with Safe Area protection and text constraints
                    SafeArea(
                      bottom: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        color: AppColors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${branchName.isNotEmpty ? branchName : "Branch"} Inventory",
                                    style: AppTextStyles.headingText22,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_user_outlined,
                                        size: 16,
                                        color: Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Role: $userRole",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Page Description
                            Text(
                              "Incoming Stock Queue",
                              style: AppTextStyles.headingText22.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Manage and receive incoming shipments from suppliers to update inventory.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            // Metric Cards Grid
                            _buildMetricCards(cards, constraints.maxWidth),
                            const SizedBox(height: 32),

                            // Main Content layout: Side-by-side on desktop, Stacked on mobile
                            isDesktop
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: _buildShipmentsPanel(
                                          shipments,
                                          isDesktop,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 3,
                                        child: _buildRecentActivityPanel(
                                          recentActivity,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildShipmentsPanel(
                                        shipments,
                                        isDesktop,
                                      ),
                                      const SizedBox(height: 24),
                                      _buildRecentActivityPanel(recentActivity),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMetricCards(Map<dynamic, dynamic> cards, double width) {
    final crossAxisCount = _adaptive<int>(
      context,
      mobile: 2,
      tablet: 2,
      desktop: 4,
    );

    final childAspectRatio = _adaptive<double>(
      context,
      mobile: 1.25,
      tablet: 1.4,
      desktop: 1.6,
    );

    final double spacing = _adaptive<double>(
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
      childAspectRatio: 1.2,
      children: [
        ShipmentCard(
          title: "Expected Today",
          count: "${cards["expected_today"] ?? 0} Shipments",
          subtitle: "Today's expected deliveries",
          icon: Icons.calendar_today_outlined,
          iconColor: Colors.blueAccent,
        ),
        ShipmentCard(
          title: "Ready for Unloading",
          count: "${cards["ready_for_unloading"] ?? 0} Shipments",
          subtitle: "Requires immediate action",
          icon: Icons.local_shipping_outlined,
          iconColor: Colors.green,
        ),
        ShipmentCard(
          title: "Total in Transit",
          count: "${formatNumber(cards["total_eggs_in_transit"])} Eggs",
          subtitle: "Stock currently moving",
          icon: Icons.send_outlined,
          iconColor: Colors.orange,
        ),

        ShipmentCard(
          title: "Delayed in Transit",
          count: "${cards["delayed_in_transit"] ?? 0} Shipments",
          subtitle: "Current transit delays",
          icon: Icons.warning_amber_outlined,
          iconColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildShipmentsPanel(List<dynamic> shipments, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Local Search and Filter Header
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      hintText: "Search PO, Supplier, or Driver...",
                      hintStyle: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Shipment Data Table (Desktop) or Cards List (Mobile)
          if (shipments.isEmpty)
            _buildEmptyState()
          else if (isDesktop)
            LayoutBuilder(
              builder: (context, tableConstraints) {
                // Ensure table is at least 950px wide for columns, or stretches if screen allows
                final double tableWidth = math.max(
                  950.0,
                  tableConstraints.maxWidth,
                );
                return Scrollbar(
                  controller: _tableScrollController,
                  child: SingleChildScrollView(
                    controller: _tableScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: _buildShipmentTable(shipments),
                    ),
                  ),
                );
              },
            )
          else
            _buildShipmentCardsList(shipments),

          const SizedBox(height: 20),

          // Pagination UI
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Showing ${shipments.length} records",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Previous",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Next", style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentTable(List<dynamic> shipments) {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5), // Record
            1: FlexColumnWidth(1.2), // Source
            2: FlexColumnWidth(1.3), // Driver
            3: FlexColumnWidth(1.5), // Summary
            4: FlexColumnWidth(1.0), // Status
            5: FlexColumnWidth(1.5), // Action
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
              ),
              children: [
                _buildHeaderCell("Shipment Record"),
                _buildHeaderCell("Source Details"),
                _buildHeaderCell("Vehicle & Driver"),
                _buildHeaderCell("Product Summary"),
                _buildHeaderCell("Status"),
                _buildHeaderCell("Action", textAlign: TextAlign.right),
              ],
            ),
            ...shipments.map((row) {
              final status = (row["status"] ?? "").toString().replaceAll(
                "_",
                " ",
              );
              final isArrival = row["status"] == "ARRIVAL";
              final isMarkArrival =
                  row["status"] == "IN_TRANSIT" ||
                  row["status"] == "EXPECTED_TODAY" ||
                  row["status"] == "DELAYED";

              return TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                children: [
                  // Record
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row["dispatch_code"] ?? "N/A",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Exp: ${formatDate(row["expected_arrival"])}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Source
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row["supplier_or_from"] ?? "N/A",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Main Warehouse",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vehicle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row["vehicle_driver"] ?? "N/A",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Vehicle Info",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Product Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row["product_summary"] ?? "N/A",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${formatNumber(row["total_eggs"])} Eggs",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(row["status"] ?? ""),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: getStatusTextColor(row["status"] ?? ""),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isArrival)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Receivestock(
                                    dispatchid: row["dispatch_id"],
                                  ),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  context.read<InventoryBloc>().add(
                                    FetchInventoryEvent(branchId: branchId),
                                  );
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Receive Stock",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (isMarkArrival)
                          ElevatedButton(
                            onPressed: () => handleMarkArrival(row),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Mark as Arrival",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.visibility_outlined,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Receivestock(
                                  dispatchid: row["dispatch_id"],
                                ),
                              ),
                            ).then((value) {
                              if (value == true) {
                                context.read<InventoryBloc>().add(
                                  FetchInventoryEvent(branchId: branchId),
                                );
                              }
                            });
                          },
                          tooltip: "View Details",
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildShipmentCardsList(List<dynamic> shipments) {
    return ListView.builder(
      itemCount: shipments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final row = shipments[index];
        final status = (row["status"] ?? "").toString().replaceAll("_", " ");
        final isArrival = row["status"] == "ARRIVAL";
        final isMarkArrival =
            row["status"] == "IN_TRANSIT" ||
            row["status"] == "EXPECTED_TODAY" ||
            row["status"] == "DELAYED";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                  Expanded(
                    child: Text(
                      row["dispatch_code"] ?? "N/A",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusBgColor(row["status"] ?? ""),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: getStatusTextColor(row["status"] ?? ""),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Exp: ${formatDate(row["expected_arrival"])}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade100),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "From Supplier",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row["supplier_or_from"] ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
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
                        const Text(
                          "Vehicle & Driver",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row["vehicle_driver"] ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Product Summary",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row["product_summary"] ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
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
                        const Text(
                          "Total Quantity",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${formatNumber(row["total_eggs"])} Eggs",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isArrival)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Receivestock(dispatchid: row["dispatch_id"]),
                            ),
                          ).then((value) {
                            if (value == true) {
                              context.read<InventoryBloc>().add(
                                FetchInventoryEvent(branchId: branchId),
                              );
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Receive Stock",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (isMarkArrival)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => handleMarkArrival(row),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Mark as Arrival",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Receivestock(dispatchid: row["dispatch_id"]),
                        ),
                      ).then((value) {
                        if (value == true) {
                          context.read<InventoryBloc>().add(
                            FetchInventoryEvent(branchId: branchId),
                          );
                        }
                      });
                    },
                    tooltip: "View Details",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(
    String label, {
    TextAlign textAlign = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        textAlign: textAlign,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Incoming Stock Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "There are currently no pending shipments or arrivals for this branch.\nNew dispatches from the warehouse will appear here automatically.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityPanel(List<dynamic> activities) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity",
            style: AppTextStyles.headingText22.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: const [
                    Icon(
                      Icons.history_toggle_off_outlined,
                      size: 36,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No recent activity logs",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: activities.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final activity = activities[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity["actor_name"] ?? "N/A",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${activity["activity"] ?? ""}  •  ${formatDate(activity["created_at"])}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
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
        ],
      ),
    );
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
