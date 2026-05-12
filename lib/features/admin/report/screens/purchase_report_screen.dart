import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  String viewMode = "Monthly";
  String supplier = "All Suppliers";
  String eggType = "All Types";
  String reportCategory = "Purchase Report";
  String selectedReport = "Purchase Report";

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
                      "Purchase Report",

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
                            title: "View Mode",

                            value: viewMode,

                            items: const ["Monthly", "Weekly", "Yearly"],

                            onChanged: (v) {
                              setState(() {
                                viewMode = v!;
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
                            title: "Supplier",

                            value: supplier,

                            items: const [
                              "All Suppliers",

                              "Valley Farms",

                              "Sunrise Poultry",
                            ],

                            onChanged: (v) {
                              setState(() {
                                supplier = v!;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: buildDropdownField(
                            title: "Egg Type",

                            value: eggType,

                            items: const [
                              "All Types",

                              "White Egg",

                              "Brown Egg",
                            ],

                            onChanged: (v) {
                              setState(() {
                                eggType = v!;
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

                        const SizedBox(width: 12),

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

                childAspectRatio: 1.1,

                children: const [
                  PurchaseStatCard(
                    title: "Total Spend",

                    amount: "₹ 682,100",

                    growth: "+4.4%",

                    growthColor: Colors.green,

                    icon: Icons.currency_rupee,

                    iconBg: Color(0xffDBEAFE),
                  ),

                  PurchaseStatCard(
                    title: "Total Volume (Units)",

                    amount: "830K",

                    growth: "+2.4%",

                    growthColor: Colors.green,

                    icon: Icons.inventory_2,

                    iconBg: Color(0xffDCFCE7),
                  ),

                  PurchaseStatCard(
                    title: "Avg Unit Cost",

                    amount: "0.3",

                    growth: "-1.4%",

                    growthColor: Colors.red,

                    icon: Icons.calculate,

                    iconBg: Color(0xffFFEDD5),
                  ),

                  PurchaseStatCard(
                    title: "Active Suppliers",

                    amount: "14",

                    growth: "0.0%",

                    growthColor: Colors.grey,

                    icon: Icons.groups,

                    iconBg: Color(0xffE9D5FF),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Column(
                children: [
                  /// MONTHLY PURCHASE TREND
                  Container(
                    width: double.infinity,

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
                          "Monthly Purchase Trend",

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Wrap(
                          spacing: 14,
                          runSpacing: 8,

                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.square,
                                  color: Colors.blue,
                                  size: 14,
                                ),

                                SizedBox(width: 6),

                                Text("Spend (₹)"),
                              ],
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.square,
                                  color: Colors.green,
                                  size: 14,
                                ),

                                SizedBox(width: 6),

                                Text("Volume (Units)"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          height: 180,

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,

                            mainAxisAlignment: MainAxisAlignment.spaceAround,

                            children: [
                              buildBar(80, 60, "Jan"),

                              buildBar(110, 90, "Feb"),

                              buildBar(70, 45, "Mar"),

                              buildBar(140, 100, "Apr"),

                              buildBar(100, 85, "May"),

                              buildBar(140, 120, "Jun"),
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

                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),

                              SizedBox(width: 10),

                              Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TOP SUPPLIERS
                  Container(
                    width: double.infinity,

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
                          "Top Suppliers by Spend",

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 24),

                        buildSupplierRow("Valley Farms", "₹ 245,000", 0.85),

                        buildSupplierRow("Sunrise Poultry", "₹ 180,000", 0.65),

                        buildSupplierRow("Green Pastures", "₹ 125,000", 0.45),

                        buildSupplierRow("Meadowbrook", "₹ 65,000", 0.20),

                        const SizedBox(height: 28),

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

                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),

                              SizedBox(width: 10),

                              Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    const Text(
                      "Month-wise Purchase Summary",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("PERIOD")),

                          DataColumn(label: Text("ORDERS")),

                          DataColumn(label: Text("QUANTITY")),

                          DataColumn(label: Text("AVG. UNIT RATE")),

                          DataColumn(label: Text("TOTAL SPEND")),

                          DataColumn(label: Text("MOM TREND")),
                        ],

                        rows: const [
                          DataRow(
                            cells: [
                              DataCell(Text("Jun 2023")),

                              DataCell(Text("60")),

                              DataCell(Text("160,000")),

                              DataCell(Text("₹ 0.78")),

                              DataCell(Text("₹ 148,400")),

                              DataCell(
                                Text(
                                  "+12%",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),

                          DataRow(
                            cells: [
                              DataCell(Text("May 2023")),

                              DataCell(Text("55")),

                              DataCell(Text("150,000")),

                              DataCell(Text("₹ 0.80")),

                              DataCell(Text("₹ 120,600")),

                              DataCell(
                                Text(
                                  "+15%",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),

                          SizedBox(width: 10),

                          Text(
                            "All amounts are in iNR (₹)",

                            style: TextStyle(
                              color: Colors.blue,

                              fontWeight: FontWeight.w600,
                            ),
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

  Widget buildBar(double blueHeight, double greenHeight, String month) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Container(
              width: 14,
              height: blueHeight,

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 6),

            Container(
              width: 14,
              height: greenHeight,

              decoration: BoxDecoration(
                color: Colors.green,

                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(month),
      ],
    );
  }

  Widget buildSupplierRow(String name, String amount, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(name)),

              Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress,

            minHeight: 6,

            backgroundColor: Colors.grey.shade200,

            color: const Color(0xffFACC15),
          ),
        ],
      ),
    );
  }
}

class PurchaseStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String growth;
  final IconData icon;
  final Color iconBg;
  final Color growthColor;

  const PurchaseStatCard({
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
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// TOP
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(icon, size: 20),
              ),
            ],
          ),

          const Spacer(),

          /// AMOUNT
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,

            child: Text(
              amount,

              maxLines: 1,

              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 10),

          /// GROWTH
          Wrap(
            spacing: 4,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,

            children: [
              Icon(
                growth.contains("-") ? Icons.trending_down : Icons.trending_up,

                size: 16,
                color: growthColor,
              ),

              Text(
                growth,

                style: TextStyle(
                  color: growthColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),

              const Text(
                "vs last period",

                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
