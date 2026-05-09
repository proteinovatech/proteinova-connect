import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/presentation/admin_dashboard.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  String expenseCategory = "All Categories";
  String branch = "All Locations";
  String status = "All Status";
  String reportCategory = "Expense Report";
  String selectedReport = "Expense Report";

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
                      "Expense Report",

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
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: buildDropdownField(
                            title: "Expense Category",
                            value: expenseCategory,

                            items: const [
                              "All Categories",
                              "Transport",
                              "Fuel",
                              "Salary",
                              "Maintenance",
                            ],

                            onChanged: (v) {
                              setState(() {
                                expenseCategory = v!;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: buildDropdownField(
                            title: "Branch / Location",
                            value: branch,

                            items: const [
                              "All Locations",
                              "Northside Branch",
                              "Downtown Branch",
                              "Warehouse",
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
                            title: "Status",
                            value: status,

                            items: const [
                              "All Status",
                              "Paid",
                              "Pending",
                              "Rejected",
                            ],

                            onChanged: (v) {
                              setState(() {
                                status = v!;
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
                  ExpenseStatCard(
                    title: "Total Expenses",
                    amount: "₹ 42.5K",
                    growth: "+4.4%",
                    icon: Icons.wallet_outlined,
                    iconBg: Color(0xffFEE2E2),
                    growthColor: Colors.red,
                  ),

                  ExpenseStatCard(
                    title: "Logistics & Transport",
                    amount: "₹ 18.2K",
                    growth: "-2.4%",
                    icon: Icons.local_shipping_outlined,
                    iconBg: Color(0xffDBEAFE),
                    growthColor: Colors.green,
                  ),

                  ExpenseStatCard(
                    title: "Warehouse Ops",
                    amount: "₹ 146,300",
                    growth: "+1.4%",
                    icon: Icons.home_work_outlined,
                    iconBg: Color(0xffFFEDD5),
                    growthColor: Colors.red,
                  ),

                  ExpenseStatCard(
                    title: "Pending Approvals",
                    amount: "14",
                    growth: "No change",
                    icon: Icons.inventory_2_outlined,
                    iconBg: Color(0xffE9D5FF),
                    growthColor: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// DAILY TREND
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
                            "Daily Expense Trend",

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
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
                        Icon(Icons.square, color: Colors.blue, size: 14),

                        SizedBox(width: 6),

                        Text("Operating Expenses"),

                        SizedBox(width: 18),

                        Icon(Icons.square, color: Color(0xffE5E7EB), size: 14),

                        SizedBox(width: 6),

                        Text("Capital Expenditures"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 220,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          buildBar(100, 60, "Mon"),
                          buildBar(120, 70, "Tue"),
                          buildBar(150, 80, "Wed"),
                          buildBar(110, 70, "Thu"),
                          buildBar(130, 75, "Fri"),
                          buildBar(140, 78, "Sat"),
                        ],
                      ),
                    ),

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
                            "View Details",

                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),

                          SizedBox(width: 8),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// CATEGORY CARD
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
                    const Text(
                      "Expenses by Category",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    buildCategoryRow(
                      "Logistics & Transport",
                      "₹ 21,300",
                      0.88,
                      Colors.blue,
                    ),

                    buildCategoryRow(
                      "Warehouse Operations",
                      "₹ 14,400",
                      0.60,
                      const Color(0xffFACC15),
                    ),

                    buildCategoryRow(
                      "Utilities & Power",
                      "₹ 8,500",
                      0.36,
                      const Color(0xffFACC15),
                    ),

                    buildCategoryRow(
                      "Office Supplies",
                      "₹ 5,400",
                      0.25,
                      const Color(0xffFACC15),
                    ),

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
                            "View Details",

                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),

                          SizedBox(width: 8),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    const Text(
                      "Recent Expenses Log",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: DataTable(
                        columnSpacing: 30,

                        columns: const [
                          DataColumn(label: Text("DATE")),

                          DataColumn(label: Text("REF NO.")),

                          DataColumn(label: Text("DESCRIPTION")),

                          DataColumn(label: Text("CATEGORY")),

                          DataColumn(label: Text("LOCATION")),

                          DataColumn(label: Text("AMOUNT")),

                          DataColumn(label: Text("STATUS")),
                        ],

                        rows: [
                          buildExpenseRow(
                            "Jun 26, 2023",
                            "EXP-0402",
                            "Fleet Fuel Refill - 4 Trucks",
                            "Logistics & Transport",
                            "Headquarters",
                            "₹ 2,150.00",
                            "Paid",
                            Colors.green,
                          ),

                          buildExpenseRow(
                            "Jun 24, 2023",
                            "EXP-0401",
                            "Warehouse Cooling System Repair",
                            "Maintenance",
                            "Northside Branch",
                            "₹ 950.00",
                            "Pending Approval",
                            Colors.orange,
                          ),

                          buildExpenseRow(
                            "Jun 23, 2023",
                            "EXP-0400",
                            "Monthly Electricity Bill",
                            "Utilities",
                            "Downtown Branch",
                            "₹ 420.50",
                            "Paid",
                            Colors.green,
                          ),

                          buildExpenseRow(
                            "Jun 21, 2023",
                            "EXP-0398",
                            "New Office Chairs (5)",
                            "Office Supplies",
                            "Headquarters",
                            "₹ 1,050.00",
                            "Rejected",
                            Colors.red,
                          ),

                          buildExpenseRow(
                            "Jun 20, 2023",
                            "EXP-0395",
                            "Delivery Van Service",
                            "Logistics & Transport",
                            "Headquarters",
                            "₹ 650.00",
                            "Paid",
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

              Icon(Icons.keyboard_arrow_down),
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

  Widget buildBar(double blueHeight, double greyHeight, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Container(
              width: 18,
              height: blueHeight,

              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 6),

            Container(
              width: 18,
              height: greyHeight,

              decoration: BoxDecoration(
                color: const Color(0xffE5E7EB),

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

  Widget buildCategoryRow(
    String title,
    String amount,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),

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
            minHeight: 8,
            color: color,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  DataRow buildExpenseRow(
    String date,
    String ref,
    String desc,
    String category,
    String location,
    String amount,
    String status,
    Color statusColor,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(ref)),
        DataCell(Text(desc)),
        DataCell(Text(category)),
        DataCell(Text(location)),
        DataCell(Text(amount)),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),

              borderRadius: BorderRadius.circular(30),
            ),

            child: Text(
              status,

              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class ExpenseStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String growth;
  final IconData icon;
  final Color iconBg;
  final Color growthColor;

  const ExpenseStatCard({
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
                    fontSize: 16,
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
