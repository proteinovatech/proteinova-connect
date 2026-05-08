import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/presentation/dashboardoverview.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/presentation/resentactivity.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/repository/dashboard_repository.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/widget/activityitem.dart';
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

  final DashboardRepository repository = DashboardRepository();

  bool isLoading = true;

  bool isShopOpen = false;

  DashboardModel? dashboardModel;

  Map<String, dynamic> cards = {};

  List<Map<String, dynamic>> activeOffers = [];

  List<Map<String, dynamic>> dailySalesVolume = [];

  List<Map<String, dynamic>> recentActivity = [];
  List lowStockAlerts = [];

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final result = await repository.fetchDashboardData();

      setState(() {
        DashboardModel != DashboardModel;
        cards = {
          "opening_stocks": result.cards.openingStocks,

          "incoming_stock_in_transit": result.cards.incomingStockInTransit,

          "damaged_stock": result.cards.damagedStock,

          "sales_today": result.cards.salesToday,

          "today_expense": result.cards.todayExpense,

          "today_tray_sold": result.cards.todayTraySold,

          "closing_stock": result.cards.closingStock,
        };

        activeOffers = result.activeOffers
            .map((e) => {"title": e.title, "condition": e.condition})
            .toList();

        dailySalesVolume = result.dailySalesVolume
            .map(
              (e) => {
                "sale_date": e.saleDate,
                "retail_sales_units": e.retailSalesUnits,
                "wholesale_sales_units": e.wholesaleSalesUnits,
              },
            )
            .toList();

        recentActivity = result.recentActivity
            .map(
              (e) => {
                "title": e.title,

                "description": e.description,

                "time": e.time,

                "tag": e.tag,
              },
            )
            .toList();

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
    List<BarChartGroupData> groups = [];

    for (int i = 0; i < dailySalesVolume.length; i++) {
      final item = dailySalesVolume[i];

      groups.add(
        BarChartGroupData(
          x: i,

          barRods: [
            BarChartRodData(
              toY: double.parse(item["retail_sales_units"].toString()),

              color: Colors.orange,

              width: 8,

              borderRadius: BorderRadius.circular(4),
            ),

            BarChartRodData(
              toY: double.parse(item["wholesale_sales_units"].toString()),

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
  floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SalesEntry(),
            ),
          );
        },
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(height: size.height * 0.07),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Image.asset("assets/erplogo.png", height: 40, width: 130),

                Row(
                  children: [
                    Text(
                      isShopOpen ? "OPEN" : "CLOSED",

                      style: TextStyle(
                        color: isShopOpen ? Colors.green : Colors.red,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 10),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isShopOpen = !isShopOpen;
                        });
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),

                        width: 50,

                        height: 30,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),

                          color: isShopOpen
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),

                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 300),

                          alignment: isShopOpen
                              ? Alignment.centerRight
                              : Alignment.centerLeft,

                          child: Container(
                            width: 22,

                            height: 22,

                            margin: const EdgeInsets.all(4),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: isShopOpen ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

                  child: const Text(
                    "View All",

                    style: TextStyle(
                      color: Colors.blue,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Expanded(
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

                          const SizedBox(height: 15),

                          Text(
                            "${cards["opening_stocks"] ?? 0} Trays",

                            style: AppTextStyles.headingText20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: Stockdetails(
                            title: "Today Tray Sold",

                            value: "${cards["today_tray_sold"] ?? 0} trays",

                            icon: Icons.check_circle_outline,

                            iconBg: Colors.blue.shade50,

                            iconColor: Colors.blue,

                            highlightUnit: true,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Stock(
                            title: "Closing Stock",

                            value: "${cards["closing_stock"] ?? 0} trays",

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

                    const SizedBox(height: 20),

                    Text("Active Offers", style: AppTextStyles.headingText22),
                    GridView.builder(
                      itemCount: activeOffers.length,

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
                        final offer = activeOffers[index];
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

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      offer["title"],

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

                              const SizedBox(height: 8),

                              Text(
                                offer["condition"],

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

                    const SizedBox(height: 20),
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

                          const SizedBox(height: 15),

                          lowStockAlerts.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text("No Low Stock Alerts"),
                                  ),
                                )
                              : GridView.builder(
                                  itemCount: lowStockAlerts.length,

                                  shrinkWrap: true,

                                  physics: const NeverScrollableScrollPhysics(),

                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,

                                        crossAxisSpacing: 15,

                                        mainAxisSpacing: 15,

                                        childAspectRatio: 2.4,
                                      ),

                                  itemBuilder: (context, index) {
                                    final item = lowStockAlerts[index];

                                    return lowStockBox(
                                      title: item["title"] ?? "",

                                      subtitle: item["subtitle"] ?? "",

                                      stock: item["stock"] ?? "",
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

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
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
                            height: 250,

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

                                        if (index >= dailySalesVolume.length) {
                                          return const SizedBox();
                                        }

                                        final date =
                                            dailySalesVolume[index]["sale_date"];

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
                                  dailySalesVolume.length,

                                  (i) {
                                    final item = dailySalesVolume[i];

                                    final retail =
                                        double.tryParse(
                                          item["retail_sales_units"].toString(),
                                        ) ??
                                        0;

                                    final wholesale =
                                        double.tryParse(
                                          item["wholesale_sales_units"]
                                              .toString(),
                                        ) ??
                                        0;

                                    return BarChartGroupData(
                                      x: i,

                                      barRods: [
                                        BarChartRodData(
                                          toY: retail,

                                          color: Colors.orange,

                                          width: 8,

                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),

                                        BarChartRodData(
                                          toY: wholesale,

                                          color: Colors.blue,

                                          width: 8,

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

                    const SizedBox(height: 20),

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

                          child: const Text(
                            "View All",

                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),

                   
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

                                    title: item["title"],

                                    subtitle: Text(item["description"]),

                                    time: item["time"] ?? "",

                                    tag: item["tag"] ?? "",
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
}
