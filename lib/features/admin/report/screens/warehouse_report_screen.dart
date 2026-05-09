import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';

class WarehouseReportScreen extends StatefulWidget {
  const WarehouseReportScreen({super.key});

  @override
  State<WarehouseReportScreen> createState() => _WarehouseReportScreenState();
}

class _WarehouseReportScreenState extends State<WarehouseReportScreen> {
  String branch = "All Branches";
  String zone = "All Zones";
  String status = "All Status";
  String reportCategory = "Warehouse Report";
  String selectedReport = "Warehouse Report";

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
                      "Warehouse Report",

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
                            title: "Destination Branch",

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

                        const SizedBox(width: 14),

                        Expanded(
                          child: buildDropdownField(
                            title: "Warehouse Zone",

                            value: zone,

                            items: const [
                              "All Zones",
                              "Zone A",
                              "Zone B",
                              "Zone C",
                            ],

                            onChanged: (v) {
                              setState(() {
                                zone = v!;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: buildDropdownField(
                            title: "Dispatch Status",

                            value: status,

                            items: const [
                              "All Status",
                              "Delivered",
                              "In Transit",
                              "Delayed",
                            ],

                            onChanged: (v) {
                              setState(() {
                                status = v!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Column(
                      children: [
                        buildDropdownField(
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

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: buildActionButton(
                                title: "Export PDF",
                                icon: Icons.picture_as_pdf,
                                bgColor: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: buildActionButton(
                                title: "Print",
                                icon: Icons.print,
                                bgColor: const Color(0xffFACC15),
                              ),
                            ),
                          ],
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
                  WarehouseStatCard(
                    title: "Available Stock",
                    amount: "420.3K",
                    growth: "+4.4%",
                    icon: Icons.inventory_2,
                    iconBg: Color(0xffDBEAFE),
                    growthColor: Colors.green,
                  ),

                  WarehouseStatCard(
                    title: "Total Dispatched (Units)",
                    amount: "380.2K",
                    growth: "+12.4%",
                    icon: Icons.local_shipping,
                    iconBg: Color(0xffDCFCE7),
                    growthColor: Colors.green,
                  ),

                  WarehouseStatCard(
                    title: "On-time Delivery",
                    amount: "94.5%",
                    growth: "+1.4%",
                    icon: Icons.access_time,
                    iconBg: Color(0xffFFEDD5),
                    growthColor: Colors.green,
                  ),

                  WarehouseStatCard(
                    title: "Active Suppliers",
                    amount: "14",
                    growth: "-1.5m",
                    icon: Icons.people_outline,
                    iconBg: Color(0xffF3E8FF),
                    growthColor: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// CHARTS
              Column(
                children: [
                  buildDispatchVolumeCard(),

                  const SizedBox(height: 16),

                  buildBranchDispatchCard(),
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
                            "Recent Dispatch Log",

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

                          DataColumn(label: Text("DISPATCH ID")),

                          DataColumn(label: Text("DESTINATION")),

                          DataColumn(label: Text("VEHICLE NO")),

                          DataColumn(label: Text("QUANTITY (UNITS)")),

                          DataColumn(label: Text("STATUS")),
                        ],

                        rows: [
                          buildRow(
                            "Jun 30, 2023",
                            "DSP-1042",
                            "Downtown Branch",
                            "TRK-01",
                            "15,000",
                            "Delivered",
                            Colors.green,
                          ),

                          buildRow(
                            "Jun 30, 2023",
                            "DSP-1041",
                            "Northside Branch",
                            "TRK-04",
                            "12,500",
                            "In Transit",
                            Colors.orange,
                          ),

                          buildRow(
                            "Jun 29, 2023",
                            "DSP-1044",
                            "West End Market",
                            "TRK-02",
                            "10,000",
                            "Delivered",
                            Colors.green,
                          ),

                          buildRow(
                            "Jun 29, 2023",
                            "DSP-1045",
                            "Suburbia Superstore",
                            "TRK-03",
                            "8,000",
                            "Delivered",
                            Colors.green,
                          ),

                          buildRow(
                            "Jun 28, 2023",
                            "DSP-1046",
                            "Downtown Branch",
                            "TRK-01",
                            "14,000",
                            "Delayed",
                            Colors.red,
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

  Widget buildDispatchVolumeCard() {
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
                  "Daily Dispatch Volume",

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

              Text("Requested (Units)"),

              SizedBox(width: 18),

              Icon(Icons.square, color: Colors.blue, size: 14),

              SizedBox(width: 6),

              Text("Dispatched (Units)"),
            ],
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 220,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                buildBar(60, 90, "Mon"),
                buildBar(70, 120, "Tue"),
                buildBar(65, 140, "Wed"),
                buildBar(62, 100, "Thu"),
                buildBar(95, 145, "Fri"),
                buildBar(40, 65, "Sat"),
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

  Widget buildBranchDispatchCard() {
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
            "Dispatch by Branch",

            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 28),

          buildBranchRow("Downtown Branch", "120,000 Units", 0.88),

          buildBranchRow("Northside Branch", "95,000 Units", 0.70),

          buildBranchRow("West End Market", "80,000 Units", 0.62),

          buildBranchRow("Suburbia Superstore", "50,000 Units", 0.42),

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
    String id,
    String destination,
    String vehicle,
    String qty,
    String status,
    Color color,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(Text(id)),
        DataCell(Text(destination)),
        DataCell(Text(vehicle)),
        DataCell(Text(qty)),

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

class WarehouseStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String growth;
  final IconData icon;
  final Color iconBg;
  final Color growthColor;

  const WarehouseStatCard({
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

          const SizedBox(height: 14),

          /// AMOUNT
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,

              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,

                child: Text(
                  amount,

                  maxLines: 1,

                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
