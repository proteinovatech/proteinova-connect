import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
=======
import 'package:proteinova_connect/core/network/dio_client.dart';
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stockdetails.dart';

class Dashboardoverview extends StatefulWidget {
  const Dashboardoverview({super.key});

  @override
  State<Dashboardoverview> createState() => _DashboardoverviewState();
}

class _DashboardoverviewState extends State<Dashboardoverview> {
  bool isLoading = true;
  DashboardModel? dashboardModel;
  late final DashboardRepository repository;

  @override
  void initState() {
    super.initState();
    repository = DashboardRepository(DioClient().dio);
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
<<<<<<< HEAD
      final response = await http.get(
        Uri.parse("${dotenv.env['BASE_URL']}/api/branch/dashboard"),

        headers: {"Accept": "application/json"},
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

        print("STATUS CODE : ${response.statusCode}");
      }
=======
      final result = await repository.fetchDashboardData();

      setState(() {
        dashboardModel = result;
        isLoading = false;
      });
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f
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
      backgroundColor: AppColors.background1,

      appBar: AppBar(
        backgroundColor: AppColors.background,

        scrolledUnderElevation: 0,

        title: const Text("All Stocks"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),

              child: ListView(
                children: [
                  /// Closing Stock
                  Stock(
                    title: "Closing Stock",

                    value: "${cards["closing_stock"] ?? 0} trays",

<<<<<<< HEAD
                    percent: "13.5%",
=======
                    value:
                        "${dashboardModel!.cards.closingStock} trays",
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f

                    subtitle: "Yesterday",

                    icon: Icons.timer_outlined,

                    iconBg: const Color(0xFFE6EBF0),

                    iconColor: Colors.brown,

                    highlightUnit: true,
                  ),

                  const SizedBox(height: 12),

                  /// Opening Stock
                  Stockdetails(
                    title: "Opening Stock",

                    value: "${cards["opening_stocks"] ?? 0} trays",

<<<<<<< HEAD
                    icon: Icons.inventory,
=======
                    value:
                        "${dashboardModel!.cards.openingStocks} trays",
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f

                    iconBg: const Color(0xFFE6EBF0),

                    iconColor: Colors.grey,

                    highlightUnit: true,
                  ),

                  const SizedBox(height: 12),

                  /// Sales Today
                  Stock(
                    title: "Sales Today",

                    value: "₹ ${cards["sales_today"] ?? 0}",

<<<<<<< HEAD
                    percent: "-2%",
=======
                    value:
                        "₹ ${dashboardModel!.cards.salesToday}",
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f

                    subtitle: "vs yesterday",

                    icon: Icons.attach_money_outlined,

                    iconBg: const Color(0xFFE6EBF0),

                    iconColor: Colors.grey,

                    highlightUnit: false,
                  ),

                  const SizedBox(height: 12),

                  /// Incoming Stock
                  Stockdetails(
                    title: "Incoming Stocks",

                    value: "${cards["incoming_stock_in_transit"] ?? 0} trays",

<<<<<<< HEAD
                    icon: Icons.local_shipping,
=======
                    value:
                        "${dashboardModel!.cards.incomingStockInTransit} trays",
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f

                    iconBg: const Color(0xFFE6EBF0),

                    iconColor: Colors.grey,

                    highlightUnit: true,
                  ),

                  const SizedBox(height: 12),

                  /// Damaged Stock
                  Stockdetails(
                    title: "Damage stock",

                    value: "${cards["damaged_stock"] ?? 0} trays",

<<<<<<< HEAD
                    icon: Icons.send_outlined,
=======
                    value:
                        "${dashboardModel!.cards.damagedStock} trays",
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f

                    iconBg: const Color(0xFFE6EBF0),

                    iconColor: Colors.grey,

                    highlightUnit: true,
                  ),

                  const SizedBox(height: 12),

                  /// Today Expense
                  Stockdetails(
                    title: "Today Expense",

                    value: "₹ ${cards["today_expense"] ?? 0}",

<<<<<<< HEAD
                    icon: Icons.trending_up,
=======
                    value:
                        "₹ ${dashboardModel!.cards.todayExpense}",
>>>>>>> 3932f4493cb2846aa06ff0d936b8a08c9b6c1a6f

                    iconBg: const Color(0xFFE6EBF0),

                    iconColor: Colors.grey,

                    highlightUnit: false,
                  ),
                ],
              ),
            ),
    );
  }
}
