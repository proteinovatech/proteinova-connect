import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/report/data/report_service.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
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

  List<dynamic> salesStats = [];

  List<dynamic> topBranches = [];

  List<dynamic> transactions = [];
  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];
  @override
  void initState() {
    super.initState();

    fetchSalesReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
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
                            "Sales Report",

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

                        const SizedBox(width: 12),

                        const Icon(Icons.notifications_none, size: 28),
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
                                        fromDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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
                                        toDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                      });
                                      fetchSalesReport();
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: buildDropdownField(
                                  title: "Select Branch",
                                  value: branch,
                                  items: [
                                    "All Branches",
                                    ...branchList.map((e) => e["branch_name"]?.toString() ?? "Unknown").toSet().toList()
                                  ],
                                  onChanged: (v) {
                                    setState(() {
                                      branch = v!;
                                    });
                                    fetchSalesReport();
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: buildDropdownField(
                                  title: "Item Type",
                                  value: itemType,

                                  items: const [
                                    "All Types",
                                    "White Egg",
                                    "Brown Egg",
                                  ],

                                  onChanged: (v) {
                                    setState(() {
                                      itemType = v!;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: buildDropdownField(
                                  title: "Transaction Category",

                                  value: transaction,

                                  items: const [
                                    "All Sales",
                                    "Retail",
                                    "Wholesale",
                                  ],

                                  onChanged: (v) {
                                    setState(() {
                                      transaction = v!;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: buildDropdownField(
                                  title: "Report Category",

                                  value: selectedReport,

                                  items: reportItems,

                                  onChanged: (value) {
                                    if (value == selectedReport) return;
                                    setState(() {
                                      selectedReport = value!;
                                    });

                                    Widget? nextScreen;
                                    if (value == "Financial Summary") {
                                      nextScreen =
                                          const AdminReportDashboardScreen();
                                    } else if (value == "Purchase Report") {
                                      nextScreen = const PurchaseReportScreen();
                                    } else if (value == "Expense Report") {
                                      nextScreen = const ExpenseReportScreen();
                                    } else if (value == "Branch Sales Report") {
                                      nextScreen = const SalesReportScreen();
                                    } else if (value == "Warehouse Report") {
                                      nextScreen =
                                          const WarehouseReportScreen();
                                    }

                                    if (nextScreen != null) {
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              nextScreen!,
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              buildActionButton(
                                title: "Export PDF",
                                icon: Icons.picture_as_pdf,
                                bgColor: Colors.white,
                              ),

                              const SizedBox(width: 14),

                              buildActionButton(
                                title: "Print",
                                icon: Icons.print,
                                bgColor: const Color(0xffFACC15),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// STATS
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 1000 ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: constraints.maxWidth > 1000 ? 2.0 : 1.3,
                          children: salesStats.map((e) {
                            IconData getIcon(String name) {
                              switch(name) {
                                case "money": return Icons.currency_rupee;
                                case "bag": return Icons.shopping_bag_outlined;
                                case "store": return Icons.storefront;
                                case "warning": return Icons.warning_amber_rounded;
                                default: return Icons.wallet_outlined;
                              }
                            }
                            Color getColor(String name) {
                              switch(name) {
                                case "red": return Colors.red;
                                case "blue": return Colors.blue;
                                case "orange": return Colors.orange;
                                case "grey": return const Color(0xff9CA3AF);
                                case "green": return Colors.green;
                                default: return Colors.green;
                              }
                            }
                            Color iconColor = getColor(e["color"]?.toString() ?? "green");

                            return SalesStatCard(
                              title: e["title"].toString(),
                              amount: e["title"].toString().contains("Revenue") ? "₹ ${e["amount"]}" : e["amount"].toString(),
                              growth: e["growth"].toString(),
                              icon: getIcon(e["icon"]?.toString() ?? ""),
                              iconColor: iconColor,
                              // ignore: deprecated_member_use
                              iconBg: iconColor.withOpacity(0.1),
                              growthColor: e["growth"].toString().contains("-") && e["growth"].toString() != "-" ? Colors.red : Colors.green,
                            );
                          }).toList(),
                        );
                      }
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

      if (branchList.isEmpty) {
        branchList = await reportService.getBranches();
      }

      String? branchId;
      if (branch != "All Branches") {
        final b = branchList.firstWhere(
          (element) => element['branch_name'] == branch, 
          orElse: () => null
        );
        if (b != null) {
          branchId = b['id']?.toString() ?? b['branch_id']?.toString();
        }
      }

      String? start = fromDate != "dd-mm-yyyy" ? fromDate : null;
      String? end = toDate != "dd-mm-yyyy" ? toDate : null;

      final data = await reportService.getBranchSalesReport(
        startDate: start,
        endDate: end,
        branchId: branchId,
      );

      setState(() {
        salesData = data;
        salesStats = data["stats"] ?? [];
        topBranches = data["topBranches"] ?? [];
        transactions = data["transactions"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildDateField({required String title, required String value, required VoidCallback onTap}) {
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
      width: 150,

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

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),

                  border: Border.all(color: const Color(0xffE5E7EB)),
                ),

                child: const Row(
                  children: [
                    Text("7 Days"),
                    SizedBox(width: 6),
                    Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Icon(Icons.square, color: Color(0xffE5E7EB), size: 14),

              SizedBox(width: 6),

              Text("Retail Sales (Units)"),

              SizedBox(width: 18),

              Icon(Icons.square, color: Colors.blue, size: 14),

              SizedBox(width: 6),

              Text("Wholesale Sales (Units)"),
            ],
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 220,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                buildBar(70, 110, "Mon"),
                buildBar(90, 130, "Tue"),
                buildBar(90, 150, "Wed"),
                buildBar(75, 110, "Thu"),
                buildBar(100, 160, "Fri"),
                buildBar(55, 75, "Sat"),
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

          const SizedBox(height: 28),

          ...topBranches.map((e) {
            return buildBranchRow(
              e["branch"].toString(),
              e["amount"].toString(),
              double.tryParse(e["progress"].toString()) ?? 0.0,
            );
          }),
          ...topBranches.map((e) {
            return buildBranchRow(
              e["branch"].toString(),
              e["amount"].toString(),
              double.tryParse(e["progress"].toString()) ?? 0.0,
            );
          }),
          ...topBranches.map((e) {
            return buildBranchRow(
              e["branch"].toString(),
              e["amount"].toString(),
              double.tryParse(e["progress"].toString()) ?? 0.0,
            );
          }),
          ...topBranches.map((e) {
            return buildBranchRow(
              e["branch"].toString(),
              e["amount"].toString(),
              double.tryParse(e["progress"].toString()) ?? 0.0,
            );
          }),
          const SizedBox(height: 24),

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
                  "View All",

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

  Widget buildBar(double greyHeight, double blueHeight, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Container(
              width: 16,
              height: greyHeight,

              decoration: BoxDecoration(
                color: const Color(0xffE5E7EB),

                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 6),

            Container(
              width: 16,
              height: blueHeight,

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius: BorderRadius.circular(4),
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
      padding: const EdgeInsets.all(18),
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (growth != "-")
                Icon(
                  growth.contains("-") ? Icons.trending_down : Icons.trending_up,
                  size: 16,
                  color: growthColor,
                ),
              if (growth != "-") const SizedBox(width: 4),
              Text(
                growth == "-" ? "- 0.0% vs last period" : growth,
                style: TextStyle(
                  color: growth == "-" ? const Color(0xff9CA3AF) : growthColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (growth != "-") const SizedBox(width: 4),
              if (growth != "-")
                const Expanded(
                  child: Text(
                    "vs last period",
                    style: TextStyle(color: Color(0xff9CA3AF), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
