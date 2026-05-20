import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_bloc.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_event.dart';
import 'package:proteinova_connect/features/branch/inventory/bloc/inventory_state.dart';
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
 

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

   return BlocProvider(
  create: (_) =>
      InventoryBloc()
        ..add(FetchInventoryEvent()),

  child: BlocBuilder<
      InventoryBloc,
      InventoryState>(
    builder: (context, state) {

      // LOADING
      if (state is InventoryLoading) {
        return const Scaffold(
          body: Center(
            child:
                CircularProgressIndicator(),
          ),
        );
      }

      // ERROR
      if (state is InventoryError) {
        return Scaffold(
          body: Center(
            child: Text(state.message),
          ),
        );
      }

      // SUCCESS
      if (state is InventoryLoaded) {

        final inventoryData =
            state.inventoryData;

        final cards =
            inventoryData["cards"] ?? {};

        final shipments =
            inventoryData["shipments"] ?? [];

        final recentActivity =
            inventoryData["recent_activity"] ?? [];


    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        title: Text("Incoming Queue", style: AppTextStyles.headingText22),
      ),

      body: Padding(
        padding: EdgeInsets.only(
          left: size.height * 0.01,
          right: size.height * 0.01,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Manage Stock Shipments",
                      style: AppTextStyles.bodyText16,
                    ),

                    SizedBox(height: size.height * 0.02),

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
                                    "${cards["total_eggs_in_transit"] ?? 0} Eggs",
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
                    SizedBox(height: size.height * 0.02),

                    // const ShipmentFilterRow(),

                    // SizedBox(height: size.height * 0.02),
                    Text("Shipments", style: AppTextStyles.headingText22),

                    const SizedBox(height: 10),

                    shipments.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("No Shipments Found"),
                            ),
                          )
                        : ListView.builder(
                            itemCount: shipments.length,

                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            itemBuilder: (context, index) {
                              final shipment = shipments[index];

                              final status =
                                  shipment["status"]
                                      ?.toString()
                                      .trim()
                                      .toUpperCase() ??
                                  "";

                              return OrderShipmentcard(
                                orderId: shipment["dispatch_code"] ?? "",

                                dateTime: shipment["expected_arrival"] ?? "",

                                status: shipment["status"] ?? "",

                                statusBgColor: status == "READY_FOR_UNLOAD"
                                    ? AppColors.green
                                    : status == "DELAYED"
                                    ? AppColors.redAccent
                                    : status == "IN_TRANSIT"
                                    ? AppColors.containerColor2
                                    : AppColors.deepOrange,

                                statusTextColor: status == "IN_TRANSIT"
                                    ? AppColors.textSecondary
                                    : AppColors.background,

                                buttonColor: status == "READY_FOR_UNLOAD"
                                    ? AppColors.amber600
                                    : AppColors.background,

                                supplier: shipment["supplier_or_from"] ?? "",

                                product: shipment["product_summary"] ?? "",

                                quantity:
                                    "${shipment["total_trays"] ?? 0} Tray",

                                buttonText: status == "READY_FOR_UNLOAD"
                                    ? "Receive Stock"
                                    : status == "DELAYED"
                                    ? "Track Shipment"
                                    : status == "IN_TRANSIT"
                                    ? "Mark as Arrival"
                                    : "Inspect & Receive",
                                onReceiveTap: () async {
                                  final dispatchId = shipment["dispatch_id"];
                                  if (status == "IN_TRANSIT") {
                                    try {
                                      final String baseUrl =
                                          dotenv.env['BASE_URL'] ?? "";
                                      final response = await http.put(
                                        Uri.parse(
                                          "$baseUrl/api/dispatch/$dispatchId/status",
                                        ),
                                        headers: {
                                          "Content-Type": "application/json",
                                        },
                                        body: jsonEncode({"status": "ARRIVAL"}),
                                      );
                                      if (response.statusCode == 200) {
                                       context
                                          .read<InventoryBloc>()
                                          .add(FetchInventoryEvent());
                                      } else {
                                        print(
                                          "PUT ERROR : ${response.statusCode}",
                                        );
                                      }
                                    } catch (e) {
                                      print("ERROR : $e");
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Receivestock(
                                          dispatchid: dispatchId,
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                       context
                                          .read<InventoryBloc>()
                                          .add(FetchInventoryEvent());
                                      }
                                    });
                                  }
                                },
                              );
                            },
                          ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Recent activity",

                          style: AppTextStyles.headingText22,
                        ),

                        // const Text(
                        //   "View All",

                        //   style: TextStyle(color: Colors.blue),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    recentActivity.isEmpty
                        ? const Center(child: Text("No Recent Activity"))
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

                                    time: item["created_at"] ?? "",

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
      ),
    );
     }

      return const SizedBox();
    },
  ),
);
  }
  
}
