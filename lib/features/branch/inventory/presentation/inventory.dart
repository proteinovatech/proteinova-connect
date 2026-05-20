import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/activityitem.dart';
import 'package:proteinova_connect/features/branch/inventory/presentation/receivestock.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/order_shipmentcard.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/shipmentcard.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  bool isLoading = true;
  int branchId = 1;
  String userRole = "Staff";
  String branchName = "";
  Map<String, dynamic>? inventoryData;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) => fetchIncomingStock());
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
    }
  }

  Future<void> fetchIncomingStock() async {
    try {
      if (mounted) setState(() => isLoading = true);
      final String baseUrl = dotenv.env['BASE_URL'] ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/api/branch/incoming-stock/$branchId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            inventoryData = data;
            branchName = data['branch_name'] ?? "";
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        debugPrint("STATUS CODE : ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("ERROR : $e");
    }
  }

  Future<void> handleMarkArrival(Map<String, dynamic> shipment) async {
    final rawId = shipment["dispatch_id"];
    if (rawId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Dispatch ID not found in row data."),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Starting Mark Arrival process...")),
    );

    try {
      final String baseUrl = dotenv.env['BASE_URL'] ?? "";
      final response = await http.put(
        Uri.parse("$baseUrl/api/dispatch/$rawId/status"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"status": "ARRIVAL"}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Shipment marked as ARRIVED successfully!"),
          ),
        );
        fetchIncomingStock();
      } else {
        final errData = jsonDecode(response.body);
        final errMsg =
            errData['error'] ??
            "Failed to mark arrival: ${response.statusCode}";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errMsg)));
      }
    } catch (err) {
      debugPrint("Error marking arrival: $err");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to mark arrival: $err")));
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
      case "ARRIVAL":
      case "READY_FOR_UNLOAD":
        return Colors.green.shade100;
      case "IN_TRANSIT":
      case "EXPECTED_TODAY":
        return Colors.blue.shade100;
      case "DELAYED":
        return Colors.red.shade100;
      case "RECEIVED":
      case "DELIVERED":
        return Colors.grey.shade200;
      default:
        return Colors.orange.shade100;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.trim().toUpperCase()) {
      case "ARRIVAL":
      case "READY_FOR_UNLOAD":
        return Colors.green.shade800;
      case "IN_TRANSIT":
      case "EXPECTED_TODAY":
        return Colors.blue.shade800;
      case "DELAYED":
        return Colors.red.shade800;
      case "RECEIVED":
      case "DELIVERED":
        return Colors.grey.shade800;
      default:
        return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600),
          ),
        ),
      );
    }

    final cards = inventoryData?["cards"] ?? {};
    final rawShipments = inventoryData?["shipments"] as List? ?? [];
    final recentActivity = inventoryData?["recent_activity"] as List? ?? [];

    // Filter shipments by search query
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

    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        title: Text("Incoming Stock", style: AppTextStyles.headingText22),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header role info matching React dashboard header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${branchName.isNotEmpty ? branchName : "Branch"} Inventory",
                      style: AppTextStyles.headingText22.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Role: $userRole",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   "Incoming Stock Queue",
                  //   style: AppTextStyles.headingText22.copyWith(fontSize: 20),
                  // ),
                  // const SizedBox(height: 4),
                  // const Text(
                  //   "Manage and receive incoming shipments from suppliers to update inventory.",
                  //   style: TextStyle(fontSize: 12, color: Colors.grey),
                  // ),
                  const SizedBox(height: 3),

                  // Cards Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double cardWidth = constraints.maxWidth > 800
                          ? (constraints.maxWidth - 20) / 3
                          : (constraints.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: ShipmentCard(
                              title: "EXPECTED TODAY",
                              count:
                                  "${cards["expected_today"] ?? 0} Shipments",
                              subtitle: "Today's expected deliveries",
                              icon: Icons.event,
                              iconColor: Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: ShipmentCard(
                              title: "READY FOR\n UNLOADING",
                              count:
                                  "${cards["ready_for_unloading"] ?? 0} Shipments",
                              subtitle: "Requires immediate action",
                              icon: Icons.local_shipping_outlined,
                              iconColor: Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: ShipmentCard(
                              title: "TOTAL IN TRANSIT",
                              count:
                                  "${formatNumber(cards["total_eggs_in_transit"])} Eggs",
                              subtitle: "Stock currently moving",
                              icon: Icons.send_outlined,
                              iconColor: Colors.orange,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: ShipmentCard(
                              title: "DELAYED IN TRANSIT",
                              count:
                                  "${cards["delayed_in_transit"] ?? 0} Shipments",
                              subtitle: "Current transit delays",
                              icon: Icons.warning_amber_rounded,
                              iconColor: Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Search Controller Bar matching React's po-table-controls
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Search PO, Supplier, or Driver...",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Shipments Heading
                  Text("Shipments", style: AppTextStyles.headingText22),
                  const SizedBox(height: 10),

                  // Shipments List
                  shipments.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 20,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: 60,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "No Incoming Stock Found",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "There are currently no pending shipments or arrivals for this branch.\nNew dispatches from the warehouse will appear here automatically.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: shipments.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final shipment = shipments[index];
                            final status = (shipment["status"] ?? "")
                                .toString()
                                .trim()
                                .toUpperCase();

                            final isMarkArrival =
                                status == "IN_TRANSIT" ||
                                status == "EXPECTED_TODAY" ||
                                status == "DELAYED";

                            final isReceiveStock =
                                status == "ARRIVAL" ||
                                status == "READY_FOR_UNLOAD";

                            return OrderShipmentcard(
                              orderId: shipment["dispatch_code"] ?? "",
                              dateTime: formatDate(
                                shipment["expected_arrival"],
                              ),
                              status: status.replaceAll("_", " "),
                              statusBgColor: getStatusBgColor(status),
                              statusTextColor: getStatusTextColor(status),
                              supplier: shipment["supplier_or_from"] ?? "",
                              product: shipment["product_summary"] ?? "",
                              quantity: "${shipment["total_trays"] ?? 0} Tray",
                              buttonColor: isReceiveStock
                                  ? const Color(0xFF10B981)
                                  : isMarkArrival
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey.shade400,
                              buttonText: isReceiveStock
                                  ? "Receive Stock"
                                  : isMarkArrival
                                  ? "Mark as Arrival"
                                  : "View Details",
                              onReceiveTap: () async {
                                if (isMarkArrival) {
                                  await handleMarkArrival(shipment);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Receivestock(
                                        dispatchid: shipment["dispatch_id"],
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      fetchIncomingStock();
                                    }
                                  });
                                }
                              },
                            );
                          },
                        ),
                  const SizedBox(height: 24),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Activity",
                        style: AppTextStyles.headingText22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  recentActivity.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("No recent activity logs"),
                          ),
                        )
                      : ListView.builder(
                          itemCount: recentActivity.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = recentActivity[index];

                            return Column(
                              children: [
                                ActivityItem(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: item["actor_name"] ?? "",
                                  subtitle: Text(item["activity"] ?? ""),
                                  time: formatDate(item["created_at"]),
                                  tag: item["activity_type"] ?? "",
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension NumberFormatting on num {
  String toLocaleString() {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(this);
  }
}