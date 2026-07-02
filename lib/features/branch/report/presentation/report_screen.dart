import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/features/admin/report/data/report_service.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_report_dashboard_shimmer.dart';
import 'package:proteinova_connect/features/branch/report/widget/salescategory.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  double totalRevenue = 0;
  int totalOrders = 0;
  int totalEggs = 0;
  int totalDamage = 0;
  int currentStock = 0;
  String? selectedBranchId;
  String selectedBranchName = "All Branches";

  String branch = "All Branches";
  String itemType = "All Types";
  String transaction = "All Sales";
  String reportCategory = "Branch Sales Report";
  String selectedReport = "Branch Sales Report";

  String fromDate = "dd-mm-yyyy";
  String toDate = "dd-mm-yyyy";
  List<dynamic> branchList = [];

  final ReportService reportService = ReportService();

  bool isLoading = true;

  Map<String, dynamic>? salesData;

  List<Map<String, dynamic>> salesStats = [];
  List<Map<String, dynamic>> transactions = [];

  List<Map<String, dynamic>> topBranches = [];

  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];
  final indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 0,
  );
  @override
  void initState() {
    super.initState();

    fetchSalesReport();
  }

  @override
  Widget build(BuildContext context) {
    print("salesData = $salesData");
    print("dailySales = ${salesData?["dailySales"]}");
    print("hourlySales = ${salesData?["hourlySales"]}");
    print("raw = ${salesData?["raw"]}");
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: isLoading
            ? const AdminReportDashboardShimmer()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Text(
                            "Branch Sales & Stock Reports",

                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xffFEF3C7),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 18),

                              SizedBox(width: 6),

                              Text(
                                "Admin",

                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),

                        // const SizedBox(width: 12),

                        // const Icon(Icons.notifications_none, size: 28),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// FILTER CARD
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: buildDateField(
                                  title: "From Date",
                                  value: fromDate,
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        fromDate =
                                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                      });
                                      fetchSalesReport();
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: buildDateField(
                                  title: "To Date",
                                  value: toDate,
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        toDate =
                                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                      });
                                      fetchSalesReport();
                                    }
                                  },
                                ),
                              ),

                              // const SizedBox(width: 14),

                              // Expanded(
                              //   child: buildDropdownField(
                              //     title: "Select Branch",
                              //     value: branch,
                              //     items: [
                              //       "All Branches",
                              //       ...branchList
                              //           .map(
                              //             (e) =>
                              //                 e["branch_name"]?.toString() ??
                              //                 "Unknown",
                              //           )
                              //           .toSet()
                              //           .toList(),
                              //     ],
                              //     onChanged: (v) {
                              //       setState(() {
                              //         branch = v!;
                              //       });
                              //       fetchSalesReport();
                              //     },
                              //   ),
                              // ),
                            ],
                          ),

                          // const SizedBox(height: 18),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: buildDropdownField(
                          //         title: "Item Type",
                          //         value: itemType,

                          //         items: const [
                          //           "All Types",
                          //           "White Egg",
                          //           "Brown Egg",
                          //         ],

                          //         onChanged: (v) {
                          //           setState(() {
                          //             itemType = v!;
                          //           });
                          //         },
                          //       ),
                          //     ),

                          //     const SizedBox(width: 14),

                          //     Expanded(
                          //       child: buildDropdownField(
                          //         title: "Transaction Category",

                          //         value: transaction,

                          //         items: const [
                          //           "All Sales",
                          //           "Retail",
                          //           "Wholesale",
                          //         ],

                          //         onChanged: (v) {
                          //           final selectedBranch = branchList
                          //               .firstWhere(
                          //                 (e) => e["branch_name"] == v,
                          //                 orElse: () => {},
                          //               );

                          //           setState(() {
                          //             branch = v!;
                          //             selectedBranchId = selectedBranch["id"]
                          //                 ?.toString();
                          //           });

                          //           fetchSalesReport();
                          //         },
                          //       ),
                          //     ),

                          //     const SizedBox(width: 14),

                          //     Expanded(
                          //       child: buildDropdownField(
                          //         title: "Report Category",

                          //         value: selectedReport,

                          //         items: reportItems,

                          //         onChanged: (value) {
                          //           if (value == selectedReport) return;
                          //           setState(() {
                          //             selectedReport = value!;
                          //           });

                          //           Widget? nextScreen;
                          //           if (value == "Financial Summary") {
                          //             nextScreen =
                          //                 const AdminReportDashboardScreen();
                          //           } else if (value == "Purchase Report") {
                          //             nextScreen = const PurchaseReportScreen();
                          //           } else if (value == "Expense Report") {
                          //             nextScreen = const ExpenseReportScreen();
                          //           } else if (value == "Branch Sales Report") {
                          //             nextScreen = const ReportScreen();
                          //           } else if (value == "Warehouse Report") {
                          //             nextScreen =
                          //                 const WarehouseReportScreen();
                          //           }

                          //           if (nextScreen != null) {
                          //             Navigator.pushReplacement(
                          //               context,
                          //               PageRouteBuilder(
                          //                 pageBuilder: (_, __, ___) =>
                          //                     nextScreen!,
                          //                 transitionDuration: Duration.zero,
                          //                 reverseTransitionDuration:
                          //                     Duration.zero,
                          //               ),
                          //             );
                          //           }
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          // const SizedBox(height: 24),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.end,

                          //   children: [
                          //     buildActionButton(
                          //       title: "Export PDF",
                          //       icon: Icons.picture_as_pdf,
                          //       bgColor: Colors.white,
                          //     ),

                          //     const SizedBox(width: 14),

                          //     buildActionButton(
                          //       title: "Print",
                          //       icon: Icons.print,
                          //       bgColor: const Color(0xffFACC15),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    /// DASHBOARD CARDS
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        dashboardCard(
                          "TOTAL SALES",
                          "₹ ${indianFormat.format(totalRevenue)}",
                          Icons.trending_up,
                          Colors.blue,
                        ),

                        dashboardCard(
                          "TOTAL ORDERS",
                          totalOrders.toString(),
                          Icons.inventory_2_outlined,
                          Colors.green,
                        ),

                        dashboardCard(
                          "TOTAL DAMAGED EGGS",
                          totalDamage.toString(),
                          Icons.shopping_bag_outlined,
                          Colors.red,
                        ),

                        dashboardCard(
                          "AVERAGE ORDER VALUE",
                          totalOrders == 0
                              ? "₹0"
                              : "₹${(totalRevenue / totalOrders).toStringAsFixed(0)}",
                          Icons.currency_rupee,
                          Colors.orange,
                        ),

                        dashboardCard(
                          "TOTAL CUSTOMERS",
                          transactions.length.toString(),
                          Icons.people_outline,
                          Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    /// STATS
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 1000
                            ? 4
                            : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: constraints.maxWidth > 1000
                              ? 2.0
                              : 1.3,
                          children: salesStats.map((e) {
                            IconData getIcon(String name) {
                              switch (name) {
                                case "money":
                                  return Icons.currency_rupee;
                                case "bag":
                                  return Icons.shopping_bag_outlined;
                                case "store":
                                  return Icons.storefront;
                                case "warning":
                                  return Icons.warning_amber_rounded;
                                default:
                                  return Icons.wallet_outlined;
                              }
                            }

                            Color getColor(String name) {
                              switch (name) {
                                case "red":
                                  return Colors.red;
                                case "blue":
                                  return Colors.blue;
                                case "orange":
                                  return Colors.orange;
                                case "grey":
                                  return const Color(0xff9CA3AF);
                                case "green":
                                  return Colors.green;
                                default:
                                  return Colors.green;
                              }
                            }

                            Color iconColor = getColor(
                              e["color"]?.toString() ?? "green",
                            );
                            final isRevenue = e["title"].toString().contains(
                              "Revenue",
                            );
                            double amountValue =
                                double.tryParse(e["amount"].toString()) ?? 0;
                            return SalesStatCard(
                              title: e["title"].toString(),
                              amount: isRevenue
                                  ? "₹ ${indianFormat.format(amountValue)}"
                                  : indianFormat.format(amountValue),
                              growth: e["growth"].toString(),
                              icon: getIcon(e["icon"]?.toString() ?? ""),
                              iconColor: iconColor,
                              iconBg: iconColor.withOpacity(0.1),
                              growthColor: e["growth"].toString().contains("-")
                                  ? Colors.red
                                  : Colors.green,
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    /// CHARTS
                    Column(
                      children: [
                        /// SALES VOLUME CARD
                        buildSalesVolumeCard(),

                        const SizedBox(height: 16),

                        /// TOP BRANCHES CARD
                        buildTopBranchesCard(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// TABLE
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Recent Branch Transactions",

                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: () {},

                                child: const Text("View All"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: DataTable(
                              columnSpacing: 26,

                              columns: const [
                                DataColumn(label: Text("DATE")),

                                DataColumn(label: Text("BRANCH")),

                                DataColumn(label: Text("TYPE")),

                                DataColumn(label: Text("ITEM / TYPE")),

                                DataColumn(label: Text("QTY (UNITS)")),

                                DataColumn(label: Text("AMOUNT")),

                                DataColumn(label: Text("STATUS")),
                              ],

                              rows: transactions.map<DataRow>((e) {
                                return buildRow(
                                  e["date"].toString(),
                                  e["branch"].toString(),
                                  e["type"].toString(),
                                  e["item"].toString(),
                                  e["qty"].toString(),
                                  e["amount"].toString(),
                                  e["status"].toString(),
                                  e["status"] == "Completed"
                                      ? Colors.green
                                      : e["status"] == "Received"
                                      ? Colors.blueGrey
                                      : Colors.red,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SalesCategoryCard(),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        buildSalesSummaryCard(),

                        const SizedBox(height: 16),

                        buildTopProductsCard(),

                        const SizedBox(height: 16),

                        buildTopCustomersCard(),

                        const SizedBox(height: 16),

                        buildPaymentModeCard(),

                        const SizedBox(height: 16),
                        buildNewVsRepeatCard(),
                        const SizedBox(height: 16),
                        buildDamagedEggsCard(),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> fetchSalesReport() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await reportService.getBranchSalesReport(
        startDate: fromDate == "dd-mm-yyyy" ? null : fromDate,
        endDate: toDate == "dd-mm-yyyy" ? null : toDate,
      );

      final sales = List<Map<String, dynamic>>.from(
        response["data"]["sales"] ?? [],
      );
      setState(() {
        salesData = response["data"];
        totalRevenue = sales.fold(
          0.0,
          (sum, item) =>
              sum + (double.tryParse(item["total_amount"].toString()) ?? 0),
        );

        totalOrders = sales.length;

        totalEggs = sales.fold(
          0,
          (sum, item) =>
              sum + (int.tryParse(item["total_eggs_sold"].toString()) ?? 0),
        );

        totalDamage = response["totalDamages"] ?? 0;

        transactions = sales.map((item) {
          return {
            "date": item["sale_date"],
            "branch": item["customer_name"],
            "type": item["sold_to"],
            "item": "Egg Sales",
            "qty": item["total_eggs_sold"],
            "amount": item["total_amount"],
            "status": item["balance_amount"] == "0.00"
                ? "Completed"
                : "Pending",
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print("API ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildDateField({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(value)),
                const Icon(Icons.calendar_month),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownField({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 8),

        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(14),

            border: Border.all(color: const Color(0xffE5E7EB)),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,

              items: items.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildActionButton({
    required String title,
    required IconData icon,
    required Color bgColor,
  }) {
    return Container(
      height: 56,
      width: 135,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget buildSalesVolumeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Daily Sales Volume",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),

              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 8,
              //   ),

              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),

              //     border: Border.all(color: const Color(0xffE5E7EB)),
              //   ),

              //   child: const Row(
              //     children: [
              //       Text("7 Days"),
              //       SizedBox(width: 6),
              //       Icon(Icons.keyboard_arrow_down, size: 18),
              //     ],
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 18),

          const Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.square, color: Colors.blue, size: 12),
                  SizedBox(width: 4),
                  Text("Retail Sales(Units)", style: TextStyle(fontSize: 12)),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.square, color: Color(0xffE5E7EB), size: 12),

                  SizedBox(width: 4),

                  Text(
                    "Wholesale Sales(Units)",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: (salesData?["trend"] ?? []).map<Widget>((item) {
                      return buildBar(
                        double.tryParse(item["retail_units"].toString()) ?? 0,

                        double.tryParse(item["wholesale_units"].toString()) ??
                            0,

                        item["day_name"] ?? "",
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xffF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopBranchesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Selling Branches",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),

          ...topBranches.map((branch) {
            final sales =
                double.tryParse(branch["total_sales"].toString()) ?? 0;

            return buildBranchRow(
              branch["branch_name"] ?? "",
              "₹ ${indianFormat.format(sales)}",
              totalRevenue == 0 ? 0 : sales / totalRevenue,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildBar(double retailSales, double wholesaleSales, String day) {
    double maxHeight = 160;

    double maxValue = (salesData?["trend"] ?? [])
        .map<double>((e) => double.tryParse(e["retail_units"].toString()) ?? 0)
        .fold(0, (a, b) => a > b ? a : b);

    double retailHeight = maxValue == 0
        ? 0
        : (retailSales / maxValue) * maxHeight;

    double wholesaleHeight = maxValue == 0
        ? 0
        : (wholesaleSales / maxValue) * maxHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 14,
              height: retailHeight,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 14,
              height: wholesaleHeight,
              decoration: BoxDecoration(
                color: const Color(0xffE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(day),
      ],
    );
  }

  Widget buildBranchRow(String title, String amount, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            color: Colors.blue,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  DataRow buildRow(
    String date,
    String branch,
    String type,
    String item,
    String qty,
    String amount,
    String status,
    Color color,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(branch)),
        DataCell(Text(type)),
        DataCell(Text(item)),
        DataCell(Text(qty)),
        DataCell(Text(amount)),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.15),

              borderRadius: BorderRadius.circular(30),
            ),

            child: Text(
              status,

              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget dashboardCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
          ),

          const SizedBox(height: 20),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),

          const SizedBox(height: 10),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSalesOverviewCard() {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sales Overview",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(child: buildSalesVolumeCard()),
        ],
      ),
    );
  }

  Widget buildSalesSummaryCard() {
    final rows = [
      ["1", "Total Sales (₹)", "₹ 165", "11.32%"],
      ["2", "Total Orders", "1", "10.15%"],
      ["3", "Total Quantity", "30", "8.45%"],
      ["4", "Avg Order Value (₹)", "₹ 165", "1.06%"],
      ["5", "Total Customers", "1", "9.28%"],
    ];

    return dashboardContainer(
      title: "Sales Summary",
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 30,
            headingRowHeight: 50,
            dataRowMinHeight: 55,
            dataRowMaxHeight: 60,
            columns: const [
              DataColumn(label: Text("#")),
              DataColumn(label: Text("Metric")),
              DataColumn(label: Text("This Month")),
              DataColumn(label: Text("Change")),
            ],
            rows: rows.map((e) {
              return DataRow(
                cells: [
                  DataCell(Text(e[0])),

                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(e[1], overflow: TextOverflow.ellipsis),
                    ),
                  ),

                  DataCell(Text(e[2])),

                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 15,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          e[3],
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildTopProductsCard() {
    final products = [
      ["without tray", "120", "80.00"],
      ["Plastic tray (With egg)", "30", "20.00"],
    ];

    return dashboardContainer(
      title: "Top 5 Products by Sales",
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("#")),
              DataColumn(label: Text("Product Name")),
              DataColumn(label: Text("Sales (₹)")),
              DataColumn(label: Text("%")),
            ],
            rows: [
              ...products.asMap().entries.map((entry) {
                return DataRow(
                  cells: [
                    DataCell(Text("${entry.key + 1}")),
                    DataCell(Text(entry.value[0])),
                    DataCell(Text("₹ ${entry.value[1]}")),
                    DataCell(Text("${entry.value[2]}%")),
                  ],
                );
              }),

              const DataRow(
                cells: [
                  DataCell(Text("")),
                  DataCell(
                    Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      "₹ 150",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text("100%", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopCustomersCard() {
    return dashboardContainer(
      title: "Top 5 Customers by Sales",
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("#")),
              DataColumn(label: Text("Customer Name")),
              DataColumn(label: Text("Orders")),
              DataColumn(label: Text("Sales (₹)")),
            ],
            rows: const [
              DataRow(
                cells: [
                  DataCell(Text("1")),
                  DataCell(Text("abc")),
                  DataCell(Text("1")),
                  DataCell(Text("₹ 165")),
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text("")),
                  DataCell(
                    Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text("1", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataCell(
                    Text(
                      "₹ 165",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentModeCard() {
    return dashboardContainer(
      title: "Sales by Payment Mode",
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 165,
                    color: Colors.orange,
                    radius: 20,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: const [
              CircleAvatar(radius: 5, backgroundColor: Colors.orange),
              SizedBox(width: 10),
              Text("CASH"),
              Spacer(),
              Text("₹ 165", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildNewVsRepeatCard() {
    return dashboardContainer(
      title: "New vs Repeat Customers",
      child: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "1",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const Text("Total"),

          const SizedBox(height: 30),

          customerRow(Colors.blue, "New Customers", "0 (0.00%)"),

          const SizedBox(height: 20),

          customerRow(Colors.green, "Repeat Customers", "0 (0.00%)"),
        ],
      ),
    );
  }

  Widget customerRow(Color color, String title, String value) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 10),
        Expanded(child: Text(title)),
        Text(value),
      ],
    );
  }

  Widget buildDamagedEggsCard() {
    return dashboardContainer(
      title: "Damaged Eggs Breakdown",
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.red),
          ),

          const SizedBox(width: 12),

          const Expanded(child: Text("White correct size")),

          const Text(
            "100 Eggs",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget dashboardContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }
}

class SalesStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String growth;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color growthColor;

  const SalesStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.growth,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.growthColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14), // reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: [
          /// HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: Color(0xff4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// AMOUNT
          Flexible(
            child: Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// GROWTH
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              if (growth != "-")
                Icon(
                  growth.contains("-")
                      ? Icons.trending_down
                      : Icons.trending_up,
                  size: 14,
                  color: growthColor,
                ),

              Text(
                growth == "-" ? "- 0.0%" : growth,
                style: TextStyle(
                  color: growth == "-" ? const Color(0xff9CA3AF) : growthColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Text(
                "vs last period",
                style: TextStyle(color: Color(0xff9CA3AF), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
