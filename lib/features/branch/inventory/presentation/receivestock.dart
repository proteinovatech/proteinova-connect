import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/receiveditem.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/traydetailcard.dart';
import 'package:proteinova_connect/features/branch/sales/widget/buildrow.dart';

class Receivestock extends StatefulWidget {
  final dispatchid;
  
  const Receivestock({super.key, this.dispatchid});

  @override
  State<Receivestock> createState() => _ReceivestockState();
}

class _ReceivestockState extends State<Receivestock> {

  bool isExpanded = true;
  bool isTrayExpanded = true;
  bool isReceivedExpanded = true;
  bool isLoading = true;

  Map<String, dynamic> receiveInfo = {};
  Map<String, dynamic> summary = {};
  List receivedItems = [];

  @override
  void initState() {
    super.initState();
    fetchReceiveStock();
  }

  Future<void> fetchReceiveStock() async {

    try {

      final response = await http.get(

        Uri.parse(
          "${ApiConstants.baseUrl}/api/branch/incoming-stock/1/dispatch/${widget.dispatchid}",
        ),

        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        setState(() {

          receiveInfo =
              data["receive_info"] ?? {};

          summary =
              data["summary"] ?? {};

          receivedItems =
              data["received_items"] ?? [];

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });

        print(
          "Status Code : ${response.statusCode}",
        );
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      print("ERROR : $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          AppColors.background1,

      appBar: AppBar(

        backgroundColor:
            AppColors.background,

        scrolledUnderElevation: 0,

        title: const Text(
          "Receive Stock",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(12),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 10),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(

                  receiveInfo[
                          "receive_no"] ??
                      "",

                  style: AppTextStyles
                      .headingText22,
                ),

                Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(

                    color: Colors.green,

                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),

                  child: Text(

                    receiveInfo[
                            "status"] ??
                        "",

                    style:
                        const TextStyle(

                      color: Colors.white,

                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            Text(

              "Manage and receive incoming shipment for suppliers to upload inventery",

              style:
                  AppTextStyles.bodyText12,
            ),

            const SizedBox(height: 10),

            Expanded(

              child:
                  SingleChildScrollView(

                child: Column(

                  children: [

                    Container(

                      padding:
                          const EdgeInsets.all(
                              12),

                      decoration:
                          BoxDecoration(

                        border: Border.all(
                          color: Colors
                              .grey
                              .shade300,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),

                        color: AppColors
                            .background,
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(

                            "Received Info",

                            style:
                                AppTextStyles
                                    .headingText22,
                          ),

                          const SizedBox(
                              height: 10),

                          Divider(
                            color: Colors
                                .grey
                                .shade300,
                          ),

                          const SizedBox(
                              height: 10),

                          Row(

                            children: const [

                              Expanded(
                                child: Text(
                                  "Receive No.",
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontSize:
                                        14,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  "Receiving Date",
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontSize:
                                        14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 6),

                          Row(

                            children: [

                              Expanded(
                                child: Text(

                                  receiveInfo[
                                          "receive_no"] ??
                                      "",

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .grey,
                                    fontSize:
                                        13,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(

                                  receiveInfo[
                                          "receiving_date"] ??
                                      "",

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .grey,
                                    fontSize:
                                        13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Divider(
                            color: Colors
                                .grey
                                .shade300,
                          ),

                          const SizedBox(
                              height: 10),

                          Row(

                            children: const [

                              Expanded(
                                child: Text(
                                  "Vehicle No.",
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontSize:
                                        14,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  "Driver Name",
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontSize:
                                        14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 6),

                          Row(

                            children: [

                              Expanded(
                                child: Text(

                                  receiveInfo[
                                          "vehicle_number"] ??
                                      "",

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .grey,
                                    fontSize:
                                        13,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(

                                  receiveInfo[
                                          "driver_name"] ??
                                      "",

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .grey,
                                    fontSize:
                                        13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 10),

                          Container(

                            width: 170,

                            padding:
                                const EdgeInsets
                                    .all(12),

                            decoration:
                                BoxDecoration(

                              border:
                                  Border.all(
                                color: Colors
                                    .grey
                                    .shade300,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),

                              color:
                                  const Color
                                      .fromARGB(
                                255,
                                185,
                                196,
                                216,
                              ),
                            ),

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                const Text(

                                  "From Supplier",

                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontSize:
                                        14,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        6),

                                Text(

                                  receiveInfo[
                                          "from_supplier"] ??
                                      "",

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .grey,
                                    fontSize:
                                        13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Container(

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),

                      decoration:
                          BoxDecoration(

                        color: AppColors
                            .background,

                        border: Border.all(
                          color:
                              AppColors.border,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(8),
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        mainAxisSize:
                            MainAxisSize.min,

                        children: [

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Text(

                                "Received Items",

                                style:
                                    AppTextStyles
                                        .headingText20,
                              ),

                              ],
                          ),

                          const SizedBox(
                              height: 6),

                                      Column(

                              children:
                                  receivedItems
                                      .map(
                                        (
                                          item,
                                        ) {

                                          return Padding(

                                            padding:
                                                const EdgeInsets.only(
                                              bottom:
                                                  6,
                                            ),

                                            child:
                                               Receiveditem(

                                             title:
                      "${item["product"]} (${item["tray_type"]})",

                  trays:
                      "${item["trays"]}",

                  eggs:
                      "${item["eggs"]}",

               
                                            ),
                                          );
                                        },
                                      )
                                      .toList(),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Container(

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),

                      decoration:
                          BoxDecoration(

                        color: AppColors
                            .background,

                        border: Border.all(
                          color:
                              AppColors.border,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(5),
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        mainAxisSize:
                            MainAxisSize.min,

                        children: [

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Text(

                                "Tray details",

                                style:
                                    AppTextStyles
                                        .headingText20,
                              ),

                            ],
                          ),

                          const SizedBox(
                              height: 6),
                            Column(

  children:
      receivedItems.map(
        (item) {

          return TrayDetailsCard(

            productGrade:
                item["product"] ?? "",

            trayType:
                item["tray_type"] ?? "",

            expectedEggs:
                "${item["eggs"] ?? 0}",

            damagedEggs:
                "${item["damaged_eggs"] ?? 0}",

            goodEggs:
                "${item["good_eggs"] ?? item["eggs"] ?? 0}",
          );
        },
      ).toList(),
), ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              "Summary",
                              style:
                                  AppTextStyles
                                      .headingText22,
                            ),
                            const Icon(
                              Icons
                                  .inventory_outlined,
                              color:
                                  Colors.blue,
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 10),

                        Container(

                          padding:
                              const EdgeInsets
                                  .all(16),

                          margin:
                              const EdgeInsets
                                  .all(12),

                          decoration:
                              BoxDecoration(

                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),

                            border:
                                Border.all(
                              color:
                                  const Color
                                      .fromARGB(
                                255,
                                204,
                                203,
                                203,
                              ),
                            ),
                          ),

                          child: Column(

                            children: [

                              buildSummaryRow(
                                "Total Trays",
                                "${summary["total_trays"] ?? 0}",
                              ),

                              const SizedBox(
                                  height:
                                      5),

                              const Divider(),

                              buildSummaryRow(
                                "Total Eggs",
                                "${summary["total_eggs"] ?? 0}",
                              ),

                              const SizedBox(
                                  height:
                                      5),

                              const Divider(),

                              buildSummaryRow(
                                "Plastic Trays",
                                "${summary["plastic_trays"] ?? 0}",
                              ),

                              const SizedBox(
                                  height:
                                      5),

                              const Divider(),

                              buildSummaryRow(
                                "Paper Trays",
                                "${summary["paper_trays"] ?? 0}",
                              ),

                              const SizedBox(
                                  height:
                                      5),
                              const Divider(),
                              buildSummaryRow(
                                "Empty Trays",
                                "${summary["empty_trays"] ?? 0}",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            Row(

              children: [

                Expanded(

                  child: Container(

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),

                    alignment:
                        Alignment.center,

                    decoration:
                        BoxDecoration(

                      color:
                          AppColors.background,

                      borderRadius:
                          BorderRadius.circular(
                              8),

                      border: Border.all(
                        color:
                            AppColors.border2,
                      ),
                    ),

                    child: Text(
                      "Cancel",
                      style: AppTextStyles
                          .bodyText14dark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color: Colors.orange,
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Confirm Receive",
                      style: AppTextStyles
                          .bodyText14dark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}