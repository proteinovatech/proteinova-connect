import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/receiveditem.dart';
import 'package:proteinova_connect/features/branch/inventory/widget/traydetailcard.dart';
import 'package:proteinova_connect/features/branch/sales/widget/buildrow.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isSubmitting = false;

  Map<String, dynamic> receiveInfo = {};
  Map<String, dynamic> summary = {};
  List receivedItems = [];
  Map<String, int> damagedTrays = {};
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReceiveStock();
  }

  Future<void> fetchReceiveStock() async {

    try {

      // final response = await http.get(

      //   Uri.parse(
      //     "${ApiConstants.baseUrl}/api/branch/incoming-stock/1/dispatch/${widget.dispatchid}",
      //   ),

      //   headers: {
      //     "Accept": "application/json",
      //   },
      final prefs = await SharedPreferences.getInstance();

    int branchId = prefs.getInt("branch_id") ?? 0;

    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/api/branch/incoming-stock/$branchId/dispatch/${widget.dispatchid}",
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

  Future<void> handleArrival() async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/api/branch/incoming-stock/1/dispatch/${widget.dispatchid}/arrival"),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Arrival marked successfully!")));
        fetchReceiveStock();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to mark arrival: ${response.statusCode}")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> handleConfirmReceive() async {
    setState(() {
      isSubmitting = true;
    });
    try {
      List<Map<String, dynamic>> items = receivedItems.map((item) {
        int eggs = item["eggs"] ?? 0;
        int trays = item["trays"] ?? 1;
        double eggsPerTray = trays > 0 ? eggs / trays : 0;
        int damaged = damagedTrays[item["product"]] ?? 0;
        int traysToMarkDamaged = eggsPerTray > 0 ? (damaged / eggsPerTray).ceil() : 0;

        return {
          "egg_category_grade": item["product"],
          "damaged_trays": traysToMarkDamaged
        };
      }).toList();

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/branch/incoming-stock/1/dispatch/${widget.dispatchid}/receive"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "dispatch_id": widget.dispatchid.toString(),
          "items": items,
          "notes": notesController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stock received successfully!")));
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to confirm receive: ${response.statusCode}")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
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
            if (receiveInfo["status"] != "ARRIVAL" && receiveInfo["status"] != "DELIVERED")
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: handleArrival,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 30),
                  ),
                  child: const Text("Mark Arrival", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              )
            else if (receiveInfo["status"] == "ARRIVAL")
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Arrived", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
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
                "${damagedTrays[item["product"]] ?? 0}",

            goodEggs:
                "${(item["eggs"] ?? 0) - (damagedTrays[item["product"]] ?? 0)}",

            onChanged: (val) {
              setState(() {
                damagedTrays[item["product"]] = int.tryParse(val) ?? 0;
              });
            },
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
                    const SizedBox(height: 20),
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter any additional notes...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            Row(

              children: [

                Expanded(

                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                ),

                const SizedBox(width: 10),

                Expanded(

                  child: GestureDetector(
                    onTap: isSubmitting ? null : handleConfirmReceive,
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
  
                        color: isSubmitting ? Colors.grey : Colors.orange,
  
                        borderRadius:
                            BorderRadius.circular(
                                8),
                      ),
  
                      child: Text(
  
                        isSubmitting ? "Processing..." : "Confirm Receive",
  
                        style: AppTextStyles
                            .bodyText14dark,
                      ),
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