import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/sales/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/sales/bloc/auth_state.dart';
import 'package:proteinova_connect/features/sales/presentation/sales_entry.dart';
import 'package:proteinova_connect/features/sales/widget/Salesorders.dart';
import 'package:proteinova_connect/features/sales/widget/dashboardcard.dart';
import 'package:proteinova_connect/features/sales/widget/dashboardcard2.dart';
import 'package:proteinova_connect/features/sales/widget/dispatchcard.dart';
import 'package:proteinova_connect/services/sales_service.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});
  @override
  State<Sales> createState() => _SalesState();
}

int selectedIndex = 0;
final ScrollController _scrollController = ScrollController();
final List<String> tabs = [
  "Active Dispatches",
  "Recent Sale Orders",
  "Delivery Routes",
  "Draft",
];

class _SalesState extends State<Sales> {
  Size get size => MediaQuery.of(context).size;
  bool isLoading = true;
  List<dynamic> dispatches = [];
  List<dynamic> salesOrders = [];
  List<dynamic> recentOrders = [];
  Map<String, dynamic> dashboardData = {};
  @override
  void initState() {
    super.initState();

    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    final data = await SalesService.fetchDashboard();

    dispatches = await SalesService.fetchDispatches();

    salesOrders = await SalesService.fetchSalesOrders();

    print("DASHBOARD DATA => $data");

    print("DISPATCHES => $dispatches");

    print("SALES ORDERS => $salesOrders");

    if (data != null) {
      if (!mounted) return;

      setState(() {
        dashboardData = data;

        isLoading = false;
      });
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
    return BlocProvider(
      create: (_) => SalesBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background1,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.07),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.01),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/erplogo.png",
                          height: 40,
                          width: 130,
                        ),
                        Row(
                          children: [
                            Icon(Icons.search_outlined),
                            SizedBox(width: size.width * 0.02),
                            Icon(Icons.notifications_outlined),
                            SizedBox(width: size.width * 0.02),

                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                size: 20,
                                color: AppColors.background,
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
              Text("Sales & Dispatch", style: AppTextStyles.headingText22),
              SizedBox(height: 20),
              BlocListener<SalesBloc, SalesState>(
                listener: (context, state) {
                  if (state is SalesSuccess) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => SalesBloc(),
                          child: Sales(),
                        ),
                      ),
                    );
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SalesEntry()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.amber600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.dark),
                        const SizedBox(width: 8),
                        Text("New Sale", style: AppTextStyles.headingText20),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: "Sales today",
                            value:
                                dashboardData["cards"]?["sales_today"]?["amount"]
                                    ?.toString() ??
                                "0",
                            percent:
                                dashboardData["cards"]?["sales_today"]?["vs_yesterday_pct"]
                                    ?.toString() ??
                                "0%",
                            subtitle: "Vs yesterday",
                            icon: Icons.currency_pound,
                            iconBg: const Color.fromARGB(255, 230, 235, 240),
                            iconColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DashboardCard2(
                            title: "Pending Dispatches",
                            value:
                                dashboardData["cards"]?["pending_unloading"]
                                    ?.toString() ??
                                "0",
                            subtitle: "Requiers Assignment",
                            icon: Icons.timer_outlined,
                            iconBg: const Color.fromARGB(255, 230, 235, 240),
                            iconColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard2(
                            title: "Vehicle in transit",
                            value:
                                dashboardData["cards"]?["vehicles_in_transit"]
                                    ?.toString() ??
                                "0",
                            subtitle: "Currently on route",
                            icon: Icons.local_shipping,
                            iconBg: const Color.fromARGB(255, 230, 235, 240),
                            iconColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DashboardCard(
                            title: "Completed",
                            value:
                                dashboardData["cards"]?["completed_deliveries"]?["today"]
                                    ?.toString() ??
                                "0",
                            percent: "+5%",
                            subtitle: "From Daily Target",
                            icon: Icons.check_circle_outline,
                            iconBg: const Color.fromARGB(255, 230, 235, 240),
                            iconColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                              _scrollController.animateTo(
                                index * 120, // adjust spacing if needed
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    tabs[index],
                                    style: AppTextStyles.bodyText16.copyWith(
                                      color: isSelected
                                          ? AppColors.dark
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    height: 3,
                                    width: isSelected ? 110 : 0,
                                    decoration: BoxDecoration(
                                      color: AppColors.blueAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Active dispatches",
                          style: AppTextStyles.headingText22,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Filter",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // const SizedBox(height: 15),
                    // DispatchCard(
                    //   id: "#DS-1142",
                    //   status: "In Transit",
                    //   branch: "Branch downtown",
                    //   vehicle: "KL-07 AB 1234",
                    //   driver: "John Smith",
                    //   items: "2,400 units",
                    //   firstIcon: Icons.location_on,
                    //   secondIcon: Icons.more_vert,
                    // ),
                    ListView.builder(
                      itemCount: dispatches.length,

                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemBuilder: (context, index) {
                        final dispatch = dispatches[index];

                        return DispatchCard(
                          id: dispatch["dispatch_id"].toString(),

                          status: dispatch["status"].toString(),

                          branch: dispatch["destination"].toString(),

                          vehicle: dispatch["vehicle_driver"].toString(),

                          driver: "${dispatch["total_trays"]} Trays",

                          items: "${dispatch["items_qty"]} units",

                          firstIcon: Icons.location_on,

                          secondIcon: Icons.more_vert,
                        );
                      },
                    ),

                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Resent Sales order",
                          style: AppTextStyles.headingText22,
                        ),
                        Text("View All", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                    SizedBox(height: 5),
                    ListView.builder(
                      itemCount: salesOrders.length,

                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemBuilder: (context, index) {
                        final order = salesOrders[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),

                          child: Salesorders(
                            id: "#SO-${order["id"]}",

                            status: order["payment_status"].toString(),

                            branch: order["customer_name"].toString(),

                            vehicle: order["dispatch_date"].toString(),

                            items: "₹ ${order["total_amount"]}",

                            icon: Icons.print_outlined,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
