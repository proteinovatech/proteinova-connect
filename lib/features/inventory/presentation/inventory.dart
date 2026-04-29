import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/activityitem.dart';
import 'package:proteinova_connect/features/inventory/model/inventory_model.dart';
import 'package:proteinova_connect/features/inventory/presentation/receivestock.dart';
import 'package:proteinova_connect/features/inventory/repository/inventory_repository.dart';
import 'package:proteinova_connect/features/inventory/widget/order_shipmentcard.dart';
import 'package:proteinova_connect/features/inventory/widget/shipment_filter_row.dart';
import 'package:proteinova_connect/features/inventory/widget/shipmentcard.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {

  final InventoryRepository repository =
      InventoryRepository();

  bool isLoading = true;

  InventoryModel? inventoryModel;

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {

    try {

      final result =
          await repository.fetchInventory();

      setState(() {

        inventoryModel = result;

        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      print("ERROR : $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    final Size size =
        MediaQuery.of(context).size;

    if (isLoading) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final cards =
        inventoryModel?.cards;

    final shipments =
        inventoryModel?.shipments ?? [];

    final recentActivity =
        inventoryModel?.recentActivity ?? [];

    return Scaffold(

      backgroundColor:
          AppColors.background1,

      body: Padding(

        padding: EdgeInsets.only(
          left: size.height * 0.01,
          right: size.height * 0.01,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            SizedBox(
              height: size.height * 0.01,
            ),

            Padding(

              padding: EdgeInsets.symmetric(
                horizontal:
                    size.width * 0.04,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  SizedBox(
                    height:
                        size.height * 0.06,
                  ),

                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      Image.asset(
                        "assets/erplogo.png",
                        height: 40,
                        width: 130,
                      ),

                      Row(

                        children: [

                          const Icon(
                            Icons
                                .notifications_outlined,
                          ),

                          SizedBox(
                            width:
                                size.width *
                                    0.02,
                          ),

                          CircleAvatar(

                            radius: 18,

                            backgroundColor:
                                Colors.grey
                                    .shade300,

                            child: Icon(
                              Icons.person,
                              size: 20,
                              color:
                                  AppColors.background,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(

              child:
                  SingleChildScrollView(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Incoming Queue",
                      style:
                          AppTextStyles
                              .headingText25,
                    ),

                    Text(
                      "Manage Stock Shipments",
                      style:
                          AppTextStyles
                              .bodyText16,
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

                    Row(

                      children: [

                        Expanded(

                          child:
                              ShipmentCard(

                            title:
                                "Expected Today",

                            count:
                                "${cards?.expectedToday ?? 0} Shipments",

                            subtitle:
                                "Incoming shipments",

                            icon:
                                Icons.event,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child:
                              ShipmentCard(

                            title:
                                "Ready for Unloading",

                            count:
                                "${cards?.readyForUnloading ?? 0} Shipments",

                            subtitle:
                                "Requires immediate action",

                            icon: Icons
                                .local_shipping_outlined,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

                    const ShipmentFilterRow(),

                    SizedBox(
                      height:
                          size.height *
                              0.02,
                    ),

              Text(
  "Shipments",
  style: AppTextStyles.headingText22,
),

const SizedBox(
  height: 10,
),

shipments.isEmpty
    ? const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No Shipments Found",
          ),
        ),
      )
    : ListView.builder(
        itemCount: shipments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {

          final shipment = shipments[index];

          return OrderShipmentcard(

            orderId:
                shipment.dispatchCode ?? "",

            dateTime:
                shipment.expectedArrival ?? "",

            status:
                shipment.status ?? "",

            statusBgColor:
                shipment.status == "READY_FOR_UNLOAD"
                    ? AppColors.green
                    : shipment.status == "DELAYED"
                        ? AppColors.redAccent
                        : shipment.status == "IN_TRANSIT"
                            ? AppColors.containerColor2
                            : AppColors.deepOrange,

            statusTextColor:
                shipment.status == "IN_TRANSIT"
                    ? AppColors.textSecondary
                    : AppColors.background,

            buttonColor:
                shipment.status == "READY_FOR_UNLOAD"
                    ? AppColors.amber600
                    : AppColors.background,

            supplier:
                shipment.supplierOrFrom ?? "",

            product:
                shipment.productSummary ?? "",

            quantity:
                "${shipment.totalTrays ?? 0} Tray",

            buttonText:
                shipment.status == "READY_FOR_UNLOAD"
                    ? "Receive Stock"
                    : shipment.status == "DELAYED"
                        ? "Track Shipment"
                        : shipment.status == "IN_TRANSIT"
                            ? "View Details"
                            : "Inspect & Receive",

            onReceiveTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Receivestock(),
                ),
              );
            },
          );
        },
      ),  const SizedBox(height: 20),

                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(

                          "Recent activity",

                          style:
                              AppTextStyles
                                  .headingText22,
                        ),

                        const Text(

                          "View All",

                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    recentActivity.isEmpty

                        ? const Center(
                            child: Text(
                              "No Recent Activity",
                            ),
                          )

                        : ListView.builder(

                            itemCount:
                                recentActivity
                                    .length,

                            shrinkWrap: true,

                            physics:
                                const NeverScrollableScrollPhysics(),

                            itemBuilder:
                                (
                                  context,
                                  index,
                                ) {

                              final item =
                                  recentActivity[
                                      index];

                              return Column(

                                children: [

                                  ActivityItem(

                                    leading:
                                        const CircleAvatar(

                                      backgroundColor:
                                          Colors
                                              .grey,

                                      child: Icon(
                                        Icons.person,
                                        color:
                                            Colors
                                                .white,
                                      ),
                                    ),

                                    title:
                                        item.actorName,

                                    subtitle:
                                        Text(
                                      item.activity,
                                    ),

                                    time:
                                        item.createdAt,

                                    tag:
                                        item.activityType,
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),
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
}