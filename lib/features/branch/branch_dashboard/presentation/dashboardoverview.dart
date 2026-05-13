import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/dashboard_overview_skeleton.dart';
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
      final result = await repository.fetchDashboardData();

      setState(() {
        dashboardModel = result;
        isLoading = false;
      });
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
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,

        scrolledUnderElevation: 0,

        title: const Text("All Stocks"),
      ),

      body: isLoading
          ? const Center(child: DashboardOverviewSkeleton())
          : Padding(
              padding: const EdgeInsets.all(12),

              child: RefreshIndicator(
                 color: Colors.blue,

  onRefresh: () async {
    setState(() {
      isLoading = true;
    });

    await fetchDashboardData();
  },
                child: ListView(
                  children: [
                    /// Closing Stock
                    Stock(
                      title: "Closing Stock",
                
                      value: "${dashboardModel!.cards.closingStock} trays",
                
                      percent: "13.5%",
                
                      subtitle: "Yesterday",
                
                      icon: Icons.timer_outlined,
                
                      iconBg: const Color(0xFFE6EBF0),
                
                      iconColor: Colors.brown,
                
                      highlightUnit: true,
                    ),
                
                    SizedBox(height: getHeight(context, 12)),
                
                    /// Opening Stock
                    Stockdetails(
                      title: "Opening Stock",
                
                      value: "${dashboardModel!.cards.openingStocks} trays",
                
                      icon: Icons.inventory,
                
                      iconBg: const Color(0xFFE6EBF0),
                
                      iconColor: Colors.grey,
                
                      highlightUnit: true,
                    ),
                
                    SizedBox(height: getHeight(context, 12)),
                
                    /// Sales Today
                    Stock(
                      title: "Sales Today",
                
                      value: "₹ ${dashboardModel!.cards.salesToday}",
                
                      percent: "-2%",
                
                      subtitle: "vs yesterday",
                
                      icon: Icons.attach_money_outlined,
                
                      iconBg: const Color(0xFFE6EBF0),
                
                      iconColor: Colors.grey,
                
                      highlightUnit: false,
                    ),
                
                    SizedBox(height: getHeight(context, 12)),
                
                    /// Incoming Stock
                    Stockdetails(
                      title: "Incoming Stocks",
                
                      value:
                          "${dashboardModel!.cards.incomingStockInTransit} trays",
                
                      icon: Icons.local_shipping,
                
                      iconBg: const Color(0xFFE6EBF0),
                
                      iconColor: Colors.grey,
                
                      highlightUnit: true,
                    ),
                
                    SizedBox(height: getHeight(context, 12)),
                
                    /// Damaged Stock
                    Stockdetails(
                      title: "Damage stock",
                
                      value: "${dashboardModel!.cards.damagedStock} trays",
                
                      icon: Icons.send_outlined,
                
                      iconBg: const Color(0xFFE6EBF0),
                
                      iconColor: Colors.grey,
                
                      highlightUnit: true,
                    ),
                
                    SizedBox(height: getHeight(context, 12)),
                
                    /// Today Expense
                    Stockdetails(
                      title: "Today Expense",
                
                      value: "₹ ${dashboardModel!.cards.todayExpense}",
                
                      icon: Icons.trending_up,
                
                      iconBg: const Color(0xFFE6EBF0),
                
                      iconColor: Colors.grey,
                
                      highlightUnit: false,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
