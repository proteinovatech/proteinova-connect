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

class Sales extends StatefulWidget {
  const Sales({super.key});
  @override
  State<Sales> createState() => _SalesState();
}
class _SalesState extends State<Sales> {
  Size get size => MediaQuery.of(context).size;
  List shipments = [];
  bool isLoading = true;
  int selectedIndex = 0;
  final ScrollController _scrollController =ScrollController();
  final List<String> tabs = [
    "Active Dispatches",
    "Recent Sale Orders",
    "Delivery Routes",
    "Draft",
  ];
  Map<String, dynamic> cards = {};
  @override
  void initState() {
    super.initState();
    fetchSalesDashboard();
  }
  Future<void> fetchSalesDashboard() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://proteinova-system.onrender.com/api/sales/dashboard",
        ),
      );
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
    return BlocProvider(
      create: (_) => SalesBloc(),
      child: Scaffold(
        backgroundColor:
           AppColors.background1,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                size.width * 0.05,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                    size.height * 0.07,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      size.width * 0.04,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height:
                          size.height *
                              0.01,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Image.asset(
                          "assets/erplogo.png",
                          height: 40,
                          width: 130,
                        ),
                        Row(

                          children: [

                            const Icon(
                              Icons
                                  .search_outlined,
                            ),

                            SizedBox(
                              width:
                                  size.width *
                                      0.02,
                            ),

                            const Icon(
                              Icons
                                  .notifications_outlined,
                            ),

                            SizedBox(
                              width:
                                  size.width *
                                      0.02,
                            ),

                            CircleAvatar(

                              radius: 18,

                              backgroundColor:
                                  Colors
                                      .grey
                                      .shade300,

                              child: Icon(
                                Icons.person,
                                size: 20,
                                color:
                                    AppColors
                                        .background,
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

              Text(

                "Sales & Dispatch",

                style:
                    AppTextStyles
                        .headingText22,
              ),

              const SizedBox(height: 20),

              BlocListener<
                  SalesBloc,
                  SalesState>(
                listener:
                    (context, state) {

                  if (state
                      is SalesSuccess) {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:
                            (_) =>
                                const Sales(),
                      ),
                    );
                  }
                },

                child: GestureDetector(

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:
                            (_) =>
                                const SalesEntry(),
                      ),
                    );
                  },

                  child: Container(

                    width: double.infinity,

                    padding:
                        const EdgeInsets
                            .all(12),

                    decoration:
                        BoxDecoration(

                      color:
                          AppColors
                              .amber600,

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),

                    child: Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [

                        Icon(
                          Icons.add,
                          color:
                              AppColors
                                  .dark,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(

                          "New Sale",

                          style:
                              AppTextStyles
                                  .headingText20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(

                child: ListView(

                  padding:
                      const EdgeInsets.only(
                    top: 10,
                    bottom: 20,
                  ),

                  children: [

                    Row(

                      children: [

                        Expanded(

                          child: DashboardCard(

                            title:
                                "Sales today",

                            value:
                                "₹${cards["sales_today"]?["amount"] ?? 0}",

                            percent:
                                "${cards["sales_today"]?["vs_yesterday_pct"] ?? 0}%",

                            subtitle:
                                "Vs yesterday",

                            icon:
                                Icons
                                    .currency_rupee,

                            iconBg:
                                const Color.fromARGB(
                              255,
                              230,
                              235,
                              240,
                            ),

                            iconColor:
                                Colors.blue,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child:
                              DashboardCard2(

                            title:
                                "Pending Unloading",

                            value:
                                "${cards["pending_unloading"] ?? 0}",

                            subtitle:
                                "Requires Assignment",

                            icon:
                                Icons
                                    .timer_outlined,

                            iconBg:
                                const Color.fromARGB(
                              255,
                              230,
                              235,
                              240,
                            ),

                            iconColor:
                                Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(

                      children: [

                        Expanded(

                          child:
                              DashboardCard2(

                            title:
                                "Vehicle in Transit",

                            value:
                                "${cards["vehicles_in_transit"] ?? 0}",

                            subtitle:
                                "Currently on route",

                            icon:
                                Icons
                                    .local_shipping,

                            iconBg:
                                const Color.fromARGB(
                              255,
                              230,
                              235,
                              240,
                            ),

                            iconColor:
                                Colors.blue,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child: DashboardCard(

                            title:
                                "Completed",

                            value:
                                "${cards["completed_deliveries"]?["today"] ?? 0}",

                            percent:
                                "${cards["completed_deliveries"]?["month_to_date"] ?? 0}",

                            subtitle:
                                "Month To Date",

                            icon:
                                Icons
                                    .check_circle_outline,

                            iconBg:
                                const Color.fromARGB(
                              255,
                              230,
                              235,
                              240,
                            ),

                            iconColor:
                                Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    SizedBox(

                      height: 45,

                      child:
                          ListView.builder(

                        controller:
                            _scrollController,

                        scrollDirection:
                            Axis.horizontal,

                        itemCount:
                            tabs.length,

                        itemBuilder:
                            (
                              context,
                              index,
                            ) {

                          final isSelected =
                              selectedIndex ==
                                  index;

                          return GestureDetector(

                            onTap: () {

                              setState(() {

                                selectedIndex =
                                    index;
                              });

                              _scrollController
                                  .animateTo(

                                index * 120,

                                duration:
                                    const Duration(
                                  milliseconds:
                                      300,
                                ),

                                curve: Curves
                                    .easeInOut,
                              );
                            },

                            child: Container(

                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    12,
                              ),

                              child: Column(

                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [

                                  Text(

                                    tabs[index],

                                    style:
                                        AppTextStyles
                                            .bodyText16
                                            .copyWith(

                                      color:
                                          isSelected
                                              ? AppColors.dark
                                              : Colors.grey,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  AnimatedContainer(

                                    duration:
                                        const Duration(
                                      milliseconds:
                                          300,
                                    ),

                                    height: 3,

                                    width:
                                        isSelected
                                            ? 110
                                            : 0,

                                    decoration:
                                        BoxDecoration(

                                      color:
                                          AppColors
                                              .blueAccent,

                                      borderRadius:
                                          BorderRadius.circular(
                                        10,
                                      ),
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
  mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

  children: [

    const Text(
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
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
      ],
    ),
  ],
),

const SizedBox(height: 15),

shipments.isEmpty

    ? const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No Dispatches Available",
          ),
        ),
      )

    : ListView.builder(

        itemCount: shipments.length,

        shrinkWrap: true,

        physics:
            const NeverScrollableScrollPhysics(),

        itemBuilder: (context, index) {

          final shipment =
              shipments[index];

          return Padding(

            padding:
                const EdgeInsets.only(
              bottom: 10,
            ),

            child: DispatchCard(

              id:
                  shipment["id"]
                          ?.toString() ??
                      "",

              status:
                  shipment["status"]
                          ?.toString() ??
                      "",

              branch:
                  shipment["branch"]
                          ?.toString() ??
                      "",

              vehicle:
                  shipment["vehicle"]
                          ?.toString() ??
                      "",

              driver:
                  shipment["driver"]
                          ?.toString() ??
                      "",

              items:
                  shipment["items"]
                          ?.toString() ??
                      "",

              firstIcon:
                  shipment["status"] ==
                          "In Transit"
                      ? Icons.location_on
                      : shipment["status"] ==
                              "Pending"
                          ? Icons.note_add
                          : Icons
                              .remove_red_eye,

              secondIcon:
                  Icons.more_vert,
            ),
          );
        },
      ),
                    const SizedBox(height: 15),

                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: const [

                        Text(

                          "Recent Sales Order",

                          style:
                              AppTextStyles
                                  .headingText22,
                        ),

                        Text(

                          "View All",

                          style:
                              TextStyle(
                            color:
                                Colors
                                    .blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Salesorders(

                      id: "#SO-1144",

                      status: "Paid",

                      branch:
                          "Retail Partner (City Center)",

                      vehicle:
                          "10:45",

                      items:
                          "₹4,250.00",

                      icon:
                          Icons.print_outlined,
                    ),

                    const SizedBox(height: 5),

                    Salesorders(

                      id: "#SO-1145",

                      status: "Net 30",

                      branch:
                          "Branch Westside(Restock)",

                      vehicle:
                          "11:45",

                      items:
                          "₹1,200.00",

                      icon:
                          Icons.print_outlined,
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