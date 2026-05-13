import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stockdetails.dart';

class Dashboardoverview extends StatefulWidget {
  const Dashboardoverview({super.key});

  @override
  State<Dashboardoverview> createState() =>
      _DashboardoverviewState();
}

class _DashboardoverviewState
    extends State<Dashboardoverview> {

  bool isLoading = true;

  Map<String, dynamic> cards = {};

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {

    try {

      final response = await http.get(

        Uri.parse(
          "https://proteinova-system.onrender.com/api/branch/dashboard",
        ),

        headers: {
          "Accept": "application/json",
        },
      );

      print(response.body);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {

          cards = data["cards"] ?? {};

          isLoading = false;
        });

      } else {

        setState(() {
          isLoading = false;
        });

        print(
          "STATUS CODE : ${response.statusCode}",
        );
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          AppColors.background1,

      appBar: AppBar(

        backgroundColor:
            AppColors.background,

        scrolledUnderElevation: 0,

        title: const Text(
          "All Stocks",
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Padding(

              padding:
                  const EdgeInsets.all(
                12,
              ),

              child: ListView(

                children: [

                  /// Closing Stock

                  Stock(

                    title:
                        "Closing Stock",

                    value:
                        "${cards["closing_stock"] ?? 0} trays",

                    percent:
                        "13.5%",

                    subtitle:
                        "Yesterday",

                    icon:
                        Icons.timer_outlined,

                    iconBg:
                        const Color(
                      0xFFE6EBF0,
                    ),

                    iconColor:
                        Colors.brown,

                    highlightUnit:
                        true,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  /// Opening Stock

                  Stockdetails(

                    title:
                        "Opening Stock",

                    value:
                        "${cards["opening_stocks"] ?? 0} trays",

                    icon:
                        Icons.inventory,

                    iconBg:
                        const Color(
                      0xFFE6EBF0,
                    ),

                    iconColor:
                        Colors.grey,

                    highlightUnit:
                        true,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  /// Sales Today

                  Stock(

                    title:
                        "Sales Today",

                    value:
                        "₹ ${cards["sales_today"] ?? 0}",

                    percent:
                        "-2%",

                    subtitle:
                        "vs yesterday",

                    icon:
                        Icons.attach_money_outlined,

                    iconBg:
                        const Color(
                      0xFFE6EBF0,
                    ),

                    iconColor:
                        Colors.grey,

                    highlightUnit:
                        false,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  /// Incoming Stock

                  Stockdetails(

                    title:
                        "Incoming Stocks",

                    value:
                        "${cards["incoming_stock_in_transit"] ?? 0} trays",

                    icon:
                        Icons.local_shipping,

                    iconBg:
                        const Color(
                      0xFFE6EBF0,
                    ),

                    iconColor:
                        Colors.grey,

                    highlightUnit:
                        true,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  /// Damaged Stock

                  Stockdetails(

                    title:
                        "Damage stock",

                    value:
                        "${cards["damaged_stock"] ?? 0} trays",

                    icon:
                        Icons.send_outlined,

                    iconBg:
                        const Color(
                      0xFFE6EBF0,
                    ),

                    iconColor:
                        Colors.grey,

                    highlightUnit:
                        true,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  /// Today Expense

                  Stockdetails(

                    title:
                        "Today Expense",

                    value:
                        "₹ ${cards["today_expense"] ?? 0}",

                    icon:
                        Icons.trending_up,

                    iconBg:
                        const Color(
                      0xFFE6EBF0,
                    ),

                    iconColor:
                        Colors.grey,

                    highlightUnit:
                        false,
                  ),
                ],
              ),
            ),
    );
  }
}