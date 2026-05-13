import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/daily_closing/repository/dailyclosing_repository.dart';
import 'package:proteinova_connect/features/daily_closing/widget/checkitem.dart';
import 'package:proteinova_connect/features/daily_closing/widget/infobox.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_block.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_item.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_row.dart';
import 'package:proteinova_connect/features/sales/widget/buildrow.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyClosing extends StatefulWidget {
  const DailyClosing({super.key});

  @override
  State<DailyClosing> createState() => _DailyClosingState();
}

class _DailyClosingState extends State<DailyClosing> {
  bool isLoading = true;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  int? branchId;
  Map<String, dynamic> dailyClosingData = {};
  bool isExpanded = true;
  double openingStock = 45000;
  double stockReceived = 15000;
  double totalSales = 26000;
  double totalExpenses = 4000;
  double get grandTotal =>
      openingStock + stockReceived + totalSales - totalExpenses;
  @override
  void initState() {
    super.initState();
    fetchDailyClosing();
    loadBranchId();
  }

  Future<void> loadBranchId() async {
    final prefs = await SharedPreferences.getInstance();

    branchId = prefs.getInt("branch_id");

    print("BRANCH ID => $branchId");

    fetchDailyClosing();
  }

  Future<void> fetchDailyClosing() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/branch/daily-closing/dashboard/$branchId?date=2026-04-28",
        ),
      );
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          dailyClosingData = data;

          // openingStock = (data["opening_stock"] ?? 0).toDouble();

          // stockReceived = (data["stock_received"] ?? 0).toDouble();

          // totalSales = (data["total_sales"] ?? 0).toDouble();

          // totalExpenses = (data["total_expenses"] ?? 0).toDouble();
          openingStock =
              double.tryParse(dailyClosingData["opening_trays"].toString()) ??
              0;

          stockReceived =
              double.tryParse(dailyClosingData["received_trays"].toString()) ??
              0;

          totalSales =
              double.tryParse(dailyClosingData["sales_total"].toString()) ?? 0;

          totalExpenses =
              double.tryParse(
                dailyClosingData["expenses"]?["total"]?.toString() ?? "0",
              ) ??
              0;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        print("API FAILED");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.07),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text("Daily Closing", style: AppTextStyles.headingText22),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                "Verify all details before closing the day.Once closed,entires cannot be edited",
                style: AppTextStyles.bodyText14,
              ),
              SizedBox(height: size.height * 0.01),
              Divider(),
              SizedBox(height: size.height * 0.01),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Stock Summary",
                              style: AppTextStyles.headingText20,
                            ),
                            IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          SizedBox(height: size.height * 0.02),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Eggs (With trays)",
                                  style: AppTextStyles.bodyText14dark,
                                ),

                                SizedBox(height: size.height * 0.02),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["opening_trays"] ?? 0}",
                                        "Opening Stock",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["received_trays"] ?? 0}",
                                        "Received",
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: size.height * 0.02),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["sold_trays"] ?? 0}",
                                        "Sold",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["closing_trays"] ?? 0}",
                                        "Closing",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          // Container(
                          //   width: double.infinity,
                          //   padding: const EdgeInsets.all(16),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(color: Colors.grey.shade300),
                          //     color: Colors.white,
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         "Paper Trays(With Eggs)",
                          //         style: AppTextStyles.bodyText14dark,
                          //       ),
                          //       SizedBox(height: size.height * 0.02),
                          //       Row(
                          //         children: [
                          //           Expanded(
                          //             child: stockItem("100", "Opening Stock"),
                          //           ),
                          //           const SizedBox(width: 10),
                          //           Expanded(
                          //             child: stockItem("200", "Received"),
                          //           ),
                          //         ],
                          //       ),
                          //       SizedBox(height: size.height * 0.02),
                          //       Row(
                          //         children: [
                          //           Expanded(child: stockItem("150", "Sold")),
                          //           const SizedBox(width: 10),
                          //           Expanded(
                          //             child: stockItem("250", "Closing"),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Paper Trays (With Eggs)",
                                  style: AppTextStyles.bodyText14dark,
                                ),

                                SizedBox(height: size.height * 0.02),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["opening_trays"] ?? 0}",
                                        "Opening Stock",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["received_trays"] ?? 0}",
                                        "Received",
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: size.height * 0.02),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["sold_trays"] ?? 0}",
                                        "Sold",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["closing_trays"] ?? 0}",
                                        "Closing",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          // Container(
                          //   width: double.infinity,
                          //   padding: const EdgeInsets.all(16),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(color: Colors.grey.shade300),
                          //     color: Colors.white,
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         "Empty Trays",
                          //         style: AppTextStyles.bodyText14dark,
                          //       ),

                          //       SizedBox(height: size.height * 0.02),

                          //       Row(
                          //         children: [
                          //           Expanded(
                          //             child: stockItem("100", "Opening Stock"),
                          //           ),
                          //           const SizedBox(width: 10),
                          //           Expanded(
                          //             child: stockItem("200", "Received"),
                          //           ),
                          //         ],
                          //       ),
                          //       SizedBox(height: size.height * 0.02),
                          //       Row(
                          //         children: [
                          //           Expanded(child: stockItem("150", "Sold")),
                          //           const SizedBox(width: 10),
                          //           Expanded(
                          //             child: stockItem("250", "Closing"),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Empty Trays",
                                  style: AppTextStyles.bodyText14dark,
                                ),

                                SizedBox(height: size.height * 0.02),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["opening_trays"] ?? 0}",
                                        "Opening Stock",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["received_trays"] ?? 0}",
                                        "Received",
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: size.height * 0.02),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["sold_trays"] ?? 0}",
                                        "Sold",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        "${dailyClosingData["closing_trays"] ?? 0}",
                                        "Closing",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text("Total", style: AppTextStyles.headingText22),
                          //     Container(
                          //       height: 35,
                          //       width: 70,
                          //       decoration: BoxDecoration(
                          //         color: AppColors.background,
                          //         border: Border.all(color: AppColors.border2),
                          //       ),
                          //       child: Center(
                          //         child: Text(
                          //           "500",
                          //           style: AppTextStyles.headingText20,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total", style: AppTextStyles.headingText22),

                              Container(
                                height: 35,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  border: Border.all(color: AppColors.border2),
                                ),
                                child: Center(
                                  child: Text(
                                    "${dailyClosingData["closing_trays"] ?? 0}",
                                    style: AppTextStyles.headingText20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      color: AppColors.background,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sales Summary",
                          style: AppTextStyles.headingText20,
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          children: [
                            Expanded(
                              child: infoBox(
                                "₹${dailyClosingData["sales"]?["total"] ?? 0}",
                                "Total Sales",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: infoBox(
                                "₹${dailyClosingData["sales"]?["cash"] ?? 0}",
                                "Cash Sales",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: infoBox(
                                "₹${dailyClosingData["sales"]?["upi"] ?? 0}",
                                "UPI Sales",
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Divider(),
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Expense Summary",
                                style: AppTextStyles.headingText20,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: infoBox(
                                      "₹${dailyClosingData["expenses"]?["total"] ?? 0}",
                                      "Total",
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: infoBox(
                                      "₹${dailyClosingData["expenses"]?["cash"] ?? 0}",
                                      "Cash",
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: infoBox(
                                      "₹${dailyClosingData["expenses"]?["upi"] ?? 0}",
                                      "UPI",
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
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SummaryBlock(
                      heading: "Cash Summary",
                      items: [
                        // SummaryItem("Opening Cash", "₹15,000"),
                        // SummaryItem("Added Cash", "₹5,000"),
                        // SummaryItem("Cash Sales", "₹18,000"),
                        // SummaryItem("Expenses", "-₹2,000"),
                        // SummaryItem("Closing Cash", "₹21,000"),
                        // SummaryItem("Difference", "₹0.00"),
                        SummaryItem(
                          "Opening Cash",
                          "₹${dailyClosingData["sales"]?["cash"] ?? 0}",
                        ),

                        SummaryItem(
                          "Added Cash",
                          "₹${dailyClosingData["sales"]?["cash"] ?? 0}",
                        ),

                        SummaryItem(
                          "Cash Sales",
                          "₹${dailyClosingData["sales"]?["cash"] ?? 0}",
                        ),

                        SummaryItem(
                          "Expenses",
                          "₹${dailyClosingData["expenses"]?["cash"] ?? 0}",
                        ),

                        SummaryItem(
                          "Closing Cash",
                          "₹${dailyClosingData["sales"]?["cash"] ?? 0}",
                        ),

                        SummaryItem("Difference", "₹0.00"),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01),
                    SummaryBlock(
                      heading: "Online Transaction Summary",
                      items: [
                        // SummaryItem("UPI Sales", "₹7,120"),
                        // SummaryItem("Expenses(UPI)", "-₹1,110"),
                        // SummaryItem("Closing UPI", "₹4,210"),
                        // SummaryItem("Card Sales", "₹4,210"),
                        // SummaryItem("Expenses(Card)", "-₹4,210"),
                        // SummaryItem("Card Sales", "₹4,210"),
                        // SummaryItem("Total Collection", "₹4,210"),
                        SummaryItem(
                          "UPI Sales",
                          "₹${dailyClosingData["sales"]?["upi"] ?? 0}",
                        ),

                        SummaryItem(
                          "Expenses(UPI)",
                          "₹${dailyClosingData["expenses"]?["upi"] ?? 0}",
                        ),

                        SummaryItem(
                          "Closing UPI",
                          "₹${dailyClosingData["sales"]?["upi"] ?? 0}",
                        ),

                        SummaryItem(
                          "Card Sales",
                          "₹${dailyClosingData["sales"]?["card"] ?? 0}",
                        ),

                        SummaryItem(
                          "Expenses(Card)",
                          "₹${dailyClosingData["expenses"]?["card"] ?? 0}",
                        ),

                        SummaryItem(
                          "Online Sales",
                          "₹${dailyClosingData["sales"]?["online"] ?? 0}",
                        ),

                        SummaryItem(
                          "Total Collection",
                          "₹${dailyClosingData["sales"]?["total"] ?? 0}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.01),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      "Closing Stock Value (Estimated)",
                      style: AppTextStyles.headingText20,
                    ),
                    // SizedBox(height: size.height * 0.02),
                    // buildSummaryRow("Eggs (with trays)", "₹50,000"),
                    // buildSummaryRow("Plastic Trays (with Eggs)", "₹30,000"),
                    // buildSummaryRow("Paper Trays (with Eggs)", "-₹2,000"),
                    // buildSummaryRow("Empty Trays", "₹20,000"),

                    // Divider(),

                    // buildSummaryRow(
                    //   "Total Stock Value",
                    //   "₹70,000",
                    //   isBold: true,
                    // ),
                    SizedBox(height: size.height * 0.02),

                    buildSummaryRow(
                      "Opening Trays",
                      "${dailyClosingData["opening_trays"] ?? 0}",
                    ),

                    buildSummaryRow(
                      "Received Trays",
                      "${dailyClosingData["received_trays"] ?? 0}",
                    ),

                    buildSummaryRow(
                      "Sold Trays",
                      "${dailyClosingData["sold_trays"] ?? 0}",
                    ),

                    buildSummaryRow(
                      "Closing Trays",
                      "${dailyClosingData["closing_trays"] ?? 0}",
                    ),

                    Divider(),

                    buildSummaryRow(
                      "Total Stock Value",
                      "${dailyClosingData["closing_trays"] ?? 0}",
                      isBold: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's summary", style: AppTextStyles.headingText20),
                    SizedBox(height: size.height * 0.01),
                    summaryRow(
                      "Opening Stock Value",
                      "₹${openingStock.toInt()}",
                    ),
                    summaryRow(
                      "Stock Received Value",
                      "₹${stockReceived.toInt()}",
                    ),
                    summaryRow("Total Sales", "₹${totalSales.toInt()}"),
                    SizedBox(height: size.height * 0.01),
                    Divider(),
                    summaryRow("Total Expenses", "₹${totalExpenses.toInt()}"),
                    SizedBox(height: size.height * 0.01),
                    Divider(),
                    summaryRow("Grand Total", "₹${grandTotal.toInt()}"),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Checklist", style: AppTextStyles.headingText20),
                    SizedBox(height: size.height * 0.02),
                    CheckItem(text: "Verified All Sales Entries"),
                    CheckItem(text: "Counted Physical Cash"),
                    CheckItem(text: "Checked Stock level"),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),

              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: .end,
                children: [
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border2),
                    ),
                    child: Text(
                      "Save as Draft",
                      style: AppTextStyles.containerText,
                    ),
                  ),
                  SizedBox(width: size.width * 0.01),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Confirm"),
                            content: Text(
                              "Are you sure you want to save this details?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Close Day",
                        style: AppTextStyles.containerText,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget stockItem(String value, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
