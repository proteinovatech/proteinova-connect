import 'dart:convert';

import 'package:flutter/material.dart';
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

class DailyClosing extends StatefulWidget {
  const DailyClosing({super.key});

  @override
  State<DailyClosing> createState() => _DailyClosingState();
}

class _DailyClosingState extends State<DailyClosing> {
  final DailyClosingRepository repository = DailyClosingRepository();
  bool isExpanded = true;

  Map<String, dynamic>? dailyClosingData;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDailyClosing();
  }

  Future<void> fetchDailyClosing() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://proteinova-system.onrender.com/api/daily-closing",
        ),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          dailyClosingData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        debugPrint("Error : ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("Exception : $e");
    }
  }

  double parseAmount(dynamic value) {
    if (value == null) return 0.0;

    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = dailyClosingData ?? {};

    final sales = data["sales"] ?? {};
    final expenses = data["expenses"] ?? {};

    final double salesTotal = parseAmount(data["sales_total"]);
    final double cashSales = parseAmount(data["cash_sales"]);
    final double upiSales = parseAmount(data["upi_sales"]);
    final double cardSales = parseAmount(data["card_sales"]);

    final double expenseTotal = parseAmount(expenses["total"]);
    final double expenseCash = parseAmount(expenses["cash"]);
    final double expenseUpi = parseAmount(expenses["upi"]);
    final double expenseCard = parseAmount(expenses["card"]);

    final int soldTrays = data["sold_trays"] ?? 0;
    final int receivedTrays = data["received_trays"] ?? 0;
    final int closingTrays = data["closing_trays"] ?? 0;
    final int openingTrays = data["opening_trays"] ?? 0;

    final double openingStock = 45000;
    final double stockReceived = 15000;
    final double totalSales = salesTotal;
    final double totalExpenses = expenseTotal;

    final double grandTotal =
        openingStock + stockReceived + totalSales - totalExpenses;

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

                  Text(
                    "Daily Closing",
                    style: AppTextStyles.headingText22,
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.01),

              Text(
                "Verify all details before closing the day.Once closed,entires cannot be edited",
                style: AppTextStyles.bodyText14,
              ),

              SizedBox(height: size.height * 0.01),

              const Divider(),

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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Eggs (With trays)",
                                  style:
                                      AppTextStyles.bodyText14dark,
                                ),

                                SizedBox(
                                  height: size.height * 0.02,
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        openingTrays.toString(),
                                        "Opening Stock",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        receivedTrays.toString(),
                                        "Received",
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: size.height * 0.02,
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: stockItem(
                                        soldTrays.toString(),
                                        "Sold",
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: stockItem(
                                        closingTrays.toString(),
                                        "Closing",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style:
                                    AppTextStyles.headingText22,
                              ),

                              Container(
                                height: 35,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  border: Border.all(
                                    color: AppColors.border2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    closingTrays.toString(),
                                    style:
                                        AppTextStyles.headingText20,
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
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      color: AppColors.background,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                                "₹${salesTotal.toStringAsFixed(2)}",
                                "Total Sales",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: infoBox(
                                "₹${cashSales.toStringAsFixed(2)}",
                                "Cash Sales",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: infoBox(
                                "₹${upiSales.toStringAsFixed(2)}",
                                "UPI Sales",
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.01),

                        const Divider(),

                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Expense Summary",
                                style:
                                    AppTextStyles.headingText20,
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: infoBox(
                                      "₹${expenseTotal.toStringAsFixed(2)}",
                                      "Total",
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: infoBox(
                                      "₹${expenseCash.toStringAsFixed(2)}",
                                      "Cash",
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: infoBox(
                                      "₹${expenseUpi.toStringAsFixed(2)}",
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
                        SummaryItem(
                          "Cash Sales",
                          "₹${cashSales.toStringAsFixed(2)}",
                        ),

                        SummaryItem(
                          "Expenses",
                          "-₹${expenseCash.toStringAsFixed(2)}",
                        ),

                        SummaryItem(
                          "Closing Cash",
                          "₹${(cashSales - expenseCash).toStringAsFixed(2)}",
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.01),

                    SummaryBlock(
                      heading:
                          "Online Transaction Summary",
                      items: [
                        SummaryItem(
                          "UPI Sales",
                          "₹${upiSales.toStringAsFixed(2)}",
                        ),

                        SummaryItem(
                          "Card Sales",
                          "₹${cardSales.toStringAsFixed(2)}",
                        ),

                        SummaryItem(
                          "Expenses(UPI)",
                          "-₹${expenseUpi.toStringAsFixed(2)}",
                        ),

                        SummaryItem(
                          "Expenses(Card)",
                          "-₹${expenseCard.toStringAsFixed(2)}",
                        ),

                        SummaryItem(
                          "Total Collection",
                          "₹${(upiSales + cardSales).toStringAsFixed(2)}",
                        ),
                      ],
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
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's summary",
                      style: AppTextStyles.headingText20,
                    ),

                    SizedBox(height: size.height * 0.01),

                    summaryRow(
                      "Opening Stock Value",
                      "₹${openingStock.toInt()}",
                    ),

                    summaryRow(
                      "Stock Received Value",
                      "₹${stockReceived.toInt()}",
                    ),

                    summaryRow(
                      "Total Sales",
                      "₹${totalSales.toInt()}",
                    ),

                    SizedBox(height: size.height * 0.01),

                    const Divider(),

                    summaryRow(
                      "Total Expenses",
                      "₹${totalExpenses.toInt()}",
                    ),

                    SizedBox(height: size.height * 0.01),

                    const Divider(),

                    summaryRow(
                      "Grand Total",
                      "₹${grandTotal.toInt()}",
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.01),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Checklist",
                      style: AppTextStyles.headingText20,
                    ),

                    SizedBox(height: size.height * 0.02),

                    CheckItem(
                      text: "Verified All Sales Entries",
                    ),

                    CheckItem(
                      text: "Counted Physical Cash",
                    ),

                    CheckItem(
                      text: "Checked Stock level",
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border2,
                      ),
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
          title: const Text("Confirm"),
          content: const Text(
            "Are you sure you want to save this details?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),

            TextButton(
           onPressed: () async {
  Navigator.pop(context);

  try {
    final result = await repository.closeDay();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"]),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
},child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  },
  child: Container(
    height: 45,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
)  ],
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
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),

        Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}