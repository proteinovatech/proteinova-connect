import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/presentation/dashboardoverview.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/presentation/resentactivity.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/activityitem.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/dashboard_skeleton_loader.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/legenditem.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/lowstock.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/stockdetails.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/zigzagclipper.dart';
import 'package:proteinova_connect/features/branch/sales/presentation/sales_entry.dart';

class BranchDashboard extends StatefulWidget {
  const BranchDashboard({super.key});

  @override
  State<BranchDashboard> createState() => _BranchDashboardState();
}

class _BranchDashboardState extends State<BranchDashboard> {
  Size get size => MediaQuery.of(context).size;

  late final DashboardRepository repository;

  bool isLoading = true;
  bool isShopOpen = false;
  DashboardModel? dashboardModel;

  @override
  void initState() {
    super.initState();
    repository = DashboardRepository(DioClient().dio);
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
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

      print("ERROR : $e");
    }
  }

  List<BarChartGroupData> _barData() {
    if (dashboardModel == null) return [];
    List<BarChartGroupData> groups = [];

    for (int i = 0; i < dashboardModel!.dailySalesVolume.length; i++) {
      final item = dashboardModel!.dailySalesVolume[i];

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.retailSalesUnits.toDouble(),
              color: Colors.orange,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: item.wholesaleSalesUnits.toDouble(),
              color: Colors.blue,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: DashboardSkeletonLoader()));
    }

    if (dashboardModel == null) {
      return const Scaffold(
        body: Center(child: Text("Error loading dashboard data")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesEntryPage()),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(height: size.height * 0.07),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Image.asset("assets/erplogo.png", height:getHeight(context, 40), width: getWidth(context, 130)),

                // Row(
                //   children: [
                //     Text(
                //       isShopOpen ? "OPEN" : "CLOSED",

                //       style: TextStyle(
                //         color: isShopOpen ? Colors.green : Colors.red,

                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),

                //     const SizedBox(width: 10),

                //     GestureDetector(
                //       onTap: () {
                //         setState(() {
                //           isShopOpen = !isShopOpen;
                //         });
                //       },

                //       child: AnimatedContainer(
                //         duration: const Duration(milliseconds: 300),

                //         width: 50,

                //         height: 30,

                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(20),

                //           color: isShopOpen
                //               ? Colors.green.shade100
                //               : Colors.red.shade100,
                //         ),

                //         child: AnimatedAlign(
                //           duration: const Duration(milliseconds: 300),

                //           alignment: isShopOpen
                //               ? Alignment.centerRight
                //               : Alignment.centerLeft,

                //           child: Container(
                //             width: 22,

                //             height: 22,

                //             margin: const EdgeInsets.all(4),

                //             decoration: BoxDecoration(
                //               shape: BoxShape.circle,

                //               color: isShopOpen ? Colors.green : Colors.red,
                //             ),
                //           ),
                //         ),

                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text("Dashboard Overview", style: AppTextStyles.headingText22),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(builder: (_) => Dashboardoverview()),
                    );
                  },

                  child: Text(
                    "View All",

                    style:AppTextStyles.blueText2
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Expanded(
              child: RefreshIndicator(
                 color: Colors.blue,

    onRefresh: () async {
      setState(() {
        isLoading = true;
      });

      await fetchDashboard();
    },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                
                          borderRadius: BorderRadius.circular(12),
                        ),
                
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                
                              children: [
                                const Text("Opening Stocks"),
                
                                Container(
                                  padding: const EdgeInsets.all(6),
                
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                
                                  child: const Icon(
                                    Icons.inventory_2,
                
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                
                            SizedBox(height: getHeight(context, 15)),
                
                            Text(
                              "${dashboardModel!.cards.openingStocks} Trays",
                
                              style: AppTextStyles.headingText20,
                            ),
                          ],
                        ),
                      ),
                
                      SizedBox(height: getHeight(context, 15)),
                
                      Row(
                        children: [
                          Expanded(
                            child: Stockdetails(
                              title: "Today Tray Sold",
                
                              value:
                                  "${dashboardModel!.cards.todayTraySold} trays",
                
                              icon: Icons.check_circle_outline,
                
                              iconBg: Colors.blue.shade50,
                
                              iconColor: Colors.blue,
                
                              highlightUnit: true,
                            ),
                          ),
                
                          SizedBox(width: getWidth(context, 10)),
                
                          Expanded(
                            child: Stock(
                              title: "Closing Stock",
                
                              value:
                                  "${dashboardModel!.cards.closingStock} trays",
                
                              percent: "0%",
                
                              subtitle: "Yesterday",
                
                              icon: Icons.timer_outlined,
                
                              iconBg: Colors.brown.shade50,
                
                              iconColor: Colors.brown,
                
                              highlightUnit: true,
                            ),
                          ),
                        ],
                      ),
                
                      SizedBox(height: getHeight(context, 20)),
                
                      Text("Active Offers", style: AppTextStyles.headingText22),
                      GridView.builder(
                        itemCount: dashboardModel!.activeOffers.length,
                
                        shrinkWrap: true,
                
                        physics: const NeverScrollableScrollPhysics(),
                
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.3,
                            ),
                        itemBuilder: (context, index) {
                          final offer = dashboardModel!.activeOffers[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                
                                  children: [
                                    ClipPath(
                                      clipper: ZigZagClipper(),
                
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                
                                        color: Colors.green.shade50,
                
                                        child: const Icon(
                                          Icons.percent,
                
                                          color: Colors.green,
                
                                          size: 18,
                                        ),
                                      ),
                                    ),
                
                                    SizedBox(width: getWidth(context, 10)),
                
                                    Expanded(
                                      child: Text(
                                        offer.title,
                
                                        maxLines: 2,
                
                                        overflow: TextOverflow.ellipsis,
                
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                
                                SizedBox(height: getHeight(context, 8)),
                
                                Text(
                                  offer.condition,
                
                                  maxLines: 2,
                
                                  overflow: TextOverflow.ellipsis,
                
                                  style: const TextStyle(
                                    fontSize: 11,
                
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                
                      SizedBox(height: getHeight(context, 20)),
                      Container(
                        width: double.infinity,
                
                        padding: const EdgeInsets.all(16),
                
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                
                              children: [
                                const Text(
                                  "Low Stock Alerts",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red.shade400,
                                  size: 24,
                                ),
                              ],
                            ),
                
                            SizedBox(height: getHeight(context, 15)),
                
                            dashboardModel!.lowStockAlerts.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text("No Low Stock Alerts"),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: dashboardModel!.lowStockAlerts.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final alert = dashboardModel!.lowStockAlerts[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: lowStockBox(
                                          title: alert.title,
                                          subtitle: alert.subtitle,
                                          stock: alert.stock,
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                
                        decoration: BoxDecoration(
                          color: Colors.white,
                
                          borderRadius: BorderRadius.circular(12),
                        ),
                
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                
                          children: [
                            const Text(
                              "Daily Sales Volume",
                
                              style: AppTextStyles.headingText20
                            ),
                
                            const Divider(),
                
                            Row(
                              children: [
                                legendItem(Colors.orange, "Retail Sales"),
                
                                const SizedBox(width: 16),
                
                                legendItem(Colors.blue, "Wholesale Sales"),
                              ],
                            ),
                
                            const SizedBox(height: 20),
                
                            SizedBox(
                              height:getHeight(context, 250),
                
                              child: BarChart(
                                BarChartData(
                                  gridData: FlGridData(show: true),
                
                                  borderData: FlBorderData(show: false),
                
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                
                                          if (index >=
                                              dashboardModel!
                                                  .dailySalesVolume
                                                  .length) {
                                            return const SizedBox();
                                          }
                
                                          final date = dashboardModel!
                                              .dailySalesVolume[index]
                                              .saleDate;
                
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                
                                            child: Text(
                                              date.toString().substring(5, 10),
                
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                
                                  barGroups: List.generate(
                                    dashboardModel!.dailySalesVolume.length,
                
                                    (i) {
                                      final item =
                                          dashboardModel!.dailySalesVolume[i];
                
                                      final retail = item.retailSalesUnits
                                          .toDouble();
                
                                      final wholesale = item.wholesaleSalesUnits
                                          .toDouble();
                
                                      return BarChartGroupData(
                                        x: i,
                
                                        barRods: [
                                          BarChartRodData(
                                            toY: retail,
                
                                            color: Colors.orange,
                
                                            width: getWidth(context, 8),
                
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                
                                          BarChartRodData(
                                            toY: wholesale,
                
                                            color: Colors.blue,
                
                                            width: getWidth(context, 8),
                
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                
                     SizedBox(height: getHeight(context, 20)),
                
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                
                        children: [
                          const Text(
                            "Recent activity",
                
                            style: AppTextStyles.headingText22,
                          ),
                
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                
                                MaterialPageRoute(
                                  builder: (_) => Resentactivity(),
                                ),
                              );
                            },
                
                            child: Text(
                              "View All",
                
                              style: AppTextStyles.blueText2,
                            ),
                          ),
                        ],
                      ),
                
                      dashboardModel!.recentActivity.isEmpty
                          ? const Center(child: Text("No Recent Activity"))
                          : ListView.builder(
                              itemCount: dashboardModel!.recentActivity.length,
                
                              shrinkWrap: true,
                
                              physics: const NeverScrollableScrollPhysics(),
                
                              itemBuilder: (context, index) {
                                final item =
                                    dashboardModel!.recentActivity[index];
                
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
                
                                      title: item.title,
                
                                      subtitle: Text(item.description),
                
                                      time: item.time,
                
                                      tag: item.tag,
                                    ),
                
                                    SizedBox(height: getHeight(context, 10)),
                                  ],
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
