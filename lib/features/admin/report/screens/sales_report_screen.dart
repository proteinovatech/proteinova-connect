import 'package:flutter/material.dart';
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

  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      body: SafeArea(
        child: SingleChildScrollView(
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
                        Expanded(child: buildDateField("From Date")),

                        const SizedBox(width: 14),

                        Expanded(child: buildDateField("To Date")),

                        const SizedBox(width: 14),

                        Expanded(
                          child: buildDropdownField(
                            title: "Select Branch",
                            value: branch,

                            items: const [
                              "All Branches",
                              "Downtown Branch",
                              "Northside Branch",
                              "West End Market",
                            ],

                            onChanged: (v) {
                              setState(() {
                                branch = v!;
                              });
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

                            items: const ["All Sales", "Retail", "Wholesale"],

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
                                nextScreen = const AdminReportDashboardScreen();
                              } else if (value == "Purchase Report") {
                                nextScreen = const PurchaseReportScreen();
                              } else if (value == "Expense Report") {
                                nextScreen = const ExpenseReportScreen();
                              } else if (value == "Branch Sales Report") {
                                nextScreen = const SalesReportScreen();
                              } else if (value == "Warehouse Report") {
                                nextScreen = const WarehouseReportScreen();
                              }

                              if (nextScreen != null) {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => nextScreen!,
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
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
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,

                children: const [
                  SalesStatCard(
                    title: "Total Sales Revenue",
                    amount: "₹ 242.5K",
                    growth: "+8.4%",
                    icon: Icons.currency_rupee,
                    iconBg: Color(0xffDBEAFE),
                    growthColor: Colors.green,
                  ),

                  SalesStatCard(
                    title: "Total Units Sold",
                    amount: "144.2K",
                    growth: "+2.4%",
                    icon: Icons.calendar_today,
                    iconBg: Color(0xffDCFCE7),
                    growthColor: Colors.green,
                  ),

                  SalesStatCard(
                    title: "Branch Stock Available",
                    amount: "68.3k",
                    growth: "-2.4%",
                    icon: Icons.storefront,
                    iconBg: Color(0xffFFEDD5),
                    growthColor: Colors.red,
                  ),

                  SalesStatCard(
                    title: "Spoilage / Damaged Rate",
                    amount: "1.2%",
                    growth: "-0.5%",
                    icon: Icons.warning_amber,
                    iconBg: Color(0xffFEE2E2),
                    growthColor: Colors.green,
                  ),
                ],
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

                        rows: [
                          buildRow(
                            "Jun 30, 2023",
                            "Downtown Branch",
                            "Sale (Retail)",
                            "Large White",
                            "500",
                            "₹ 150.00",
                            "Completed",
                            Colors.green,
                          ),

                          buildRow(
                            "Jun 30, 2023",
                            "Northside Branch",
                            "Sale (Wholesale)",
                            "Medium Brown",
                            "2,000",
                            "₹ 500.00",
                            "Completed",
                            Colors.green,
                          ),

                          buildRow(
                            "Jun 29, 2023",
                            "West End Market",
                            "Restock (Inward)",
                            "Large White",
                            "5,000",
                            "-",
                            "Received",
                            Colors.blueGrey,
                          ),

                          buildRow(
                            "Jun 29, 2023",
                            "Suburbia Superstore",
                            "Spoilage / Damage",
                            "Mixed Variety",
                            "50",
                            "-",
                            "Logged",
                            Colors.red,
                          ),

                          buildRow(
                            "Jun 28, 2023",
                            "Downtown Branch",
                            "Sale (Wholesale)",
                            "Extra Large",
                            "1,000",
                            "₹ 250.00",
                            "Completed",
                            Colors.green,
                          ),
                        ],
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

  Widget buildDateField(String title) {
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

          child: const Row(
            children: [
              Expanded(child: Text("dd-mm-yyyy")),

              Icon(Icons.calendar_month),
            ],
          ),
        ),
      ],
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

          buildBranchRow("Downtown Branch", "45,000 Units", 0.85),

          buildBranchRow("Northside Branch", "28,000 Units", 0.60),

          buildBranchRow("West End Market", "32,000 Units", 0.70),

          buildBranchRow("Suburbia Superstore", "27,500 Units", 0.55),

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
  final Color iconBg;
  final Color growthColor;

  const SalesStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.growth,
    required this.icon,
    required this.iconBg,
    required this.growthColor,
  });

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: iconBg,

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon),
              ),
            ],
          ),

          const Spacer(),

          Text(
            amount,

            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                growth.contains("-") ? Icons.trending_down : Icons.trending_up,

                size: 18,
                color: growthColor,
              ),

              const SizedBox(width: 6),

              Text(
                growth,

                style: TextStyle(
                  color: growthColor,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(width: 6),

              const Expanded(
                child: Text("vs last period", overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
