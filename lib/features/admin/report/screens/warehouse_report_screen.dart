import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/report/data/report_service.dart'
    show ReportService;
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

  String fromDate = "dd-mm-yyyy";
  String toDate = "dd-mm-yyyy";
  List<dynamic> branchList = [];

  final ReportService reportService = ReportService();

  bool isLoading = true;

  Map<String, dynamic>? warehouseData;

  List<dynamic> warehouseStats = [];

  List<dynamic> branchDispatch = [];

  List<dynamic> dispatchLogs = [];
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

    fetchWarehouseReport();
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
                                      fetchWarehouseReport();
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
                                      fetchWarehouseReport();
                                    }
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
                                  title: "Destination Branch",
                                  value: branch,
                                  items: [
                                    "All Branches",
                                    ...branchList.map((e) => e["branch_name"]?.toString() ?? "Unknown").toSet().toList()
                                  ],
                                  onChanged: (v) {
                                    setState(() {
                                      branch = v!;
                                    });
                                    fetchWarehouseReport();
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
                                    nextScreen =
                                        const AdminReportDashboardScreen();
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
                          children: warehouseStats.map((e) {
                            IconData getIcon(String name) {
                              switch(name) {
                                case "warehouse": return Icons.warehouse_outlined;
                                case "truck": return Icons.local_shipping_outlined;
                                case "check": return Icons.check_circle_outline;
                                case "clock": return Icons.access_time;
                                default: return Icons.inventory_2_outlined;
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

                            return WarehouseStatCard(
                              title: e["title"].toString(),
                              amount: e["amount"].toString(),
                              growth: e["growth"].toString(),
                              icon: getIcon(e["icon"]?.toString() ?? ""),
                              iconColor: iconColor,
                              // ignore: deprecated_member_use
                              iconBg: iconColor.withOpacity(0.1),
                              growthColor: e["growth"].toString().contains("-") && !e["growth"].toString().contains("- ") ? Colors.red : Colors.green,
                            );
                          }).toList(),
                        );
                      }
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

                              rows: dispatchLogs.map<DataRow>((e) {
                                return buildRow(
                                  e["date"].toString(),
                                  e["dispatchId"].toString(),
                                  e["destination"].toString(),
                                  e["vehicle"].toString(),
                                  e["quantity"].toString(),
                                  e["status"].toString(),
                                  e["status"] == "Delivered"
                                      ? Colors.green
                                      : e["status"] == "Delayed"
                                      ? Colors.red
                                      : Colors.orange,
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

  Future<void> fetchWarehouseReport() async {
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

      final data = await reportService.getWarehouseReport(
        startDate: start,
        endDate: end,
        branchId: branchId,
      );

      setState(() {
        warehouseData = data;
        warehouseStats = data["stats"] ?? [];
        branchDispatch = data["destinations"] ?? data["branchDispatch"] ?? [];
        dispatchLogs = data["recentDispatches"] ?? data["logs"] ?? [];
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

         Wrap(
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: 14,
  runSpacing: 6,

  children: [
    Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.square,
          color:Color(0xffE5E7EB),
          size: 12,
        ),

        SizedBox(width: 4),

        Text(
          "Requested (Units)",
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    ),

    Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.square,
          color: Colors.blue,
          size: 12,
        ),

        SizedBox(width: 4),

        Text(
          "Dispatched (Units)",
          style: TextStyle(
            fontSize: 12,
          ),
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

          ...branchDispatch.map((e) {
            return buildBranchRow(
              e["branch"].toString(),
              e["amount"].toString(),
              double.tryParse(e["progress"].toString()) ?? 0.0,
            );
          }),
          ...branchDispatch.map((e) {
            return buildBranchRow(
              e["branch"].toString(),
              e["amount"].toString(),
              double.tryParse(e["progress"].toString()) ?? 0.0,
            );
          }),
          ...branchDispatch.map((e) {
            return buildBranchRow(
              e["branch"].toString(),
              e["amount"].toString(),
              double.tryParse(e["progress"].toString()) ?? 0.0,
            );
          }),
          ...branchDispatch.map((e) {
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

class WarehouseStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String growth;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color growthColor;

  const WarehouseStatCard({
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
  padding: const EdgeInsets.all(14),
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
      /// TOP SECTION
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
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
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
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),

      const SizedBox(height: 6),

      /// GROWTH ROW
      Flexible(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 3,
          runSpacing: 2,
          children: [
            if (growth != "-")
              Icon(
                growth.contains("-") && !growth.contains("- ")
                    ? Icons.trending_down
                    : Icons.trending_up,
                size: 14,
                color: growthColor,
              ),

            Text(
              growth == "-" ? "- 0.0%" : growth,
              style: TextStyle(
                color: growth == "-"
                    ? const Color(0xff9CA3AF)
                    : growthColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Text(
              "vs last period",
              style: TextStyle(
                color: Color(0xff9CA3AF),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
); }
}
