import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:proteinova_connect/features/admin/report/data/report_service.dart';
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_report_dashboard_shimmer.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  final ReportService reportService = ReportService();

  bool isLoading = true;

  Map<String, dynamic>? expenseData;

  List<dynamic> expenseStats = [];

  List<dynamic> expenseCategories = [];

  List<dynamic> expenseLogs = [];

  String expenseCategory = "All Categories";
  String branch = "All Locations";
  String status = "All Status";
  String selectedReport = "Expense Report";

  String fromDate = "dd-mm-yyyy";
  String toDate = "dd-mm-yyyy";
  List<dynamic> branchList = [];

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

    fetchExpenseReport();
  }

  Future<void> fetchExpenseReport() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (branchList.isEmpty) {
        branchList = await reportService.getBranches();
      }

      String? branchId;
      if (branch != "All Locations") {
        final b = branchList.firstWhere(
          (element) => element['branch_name'] == branch,
          orElse: () => null,
        );
        if (b != null) {
          branchId = b['id']?.toString() ?? b['branch_id']?.toString();
        }
      }

      String? start = fromDate != "dd-mm-yyyy" ? fromDate : null;
      String? end = toDate != "dd-mm-yyyy" ? toDate : null;

      final data = await reportService.getExpenseReport(
        startDate: start,
        endDate: end,
        branchId: branchId,
      );

      setState(() {
        expenseData = data;
        expenseStats = data["stats"] ?? [];
        expenseCategories = data["categories"] ?? [];
        expenseLogs = data["recentExpenses"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Expense Report", style: pw.TextStyle(fontSize: 24)),

          pw.SizedBox(height: 20),

          pw.TableHelper.fromTextArray(
            headers: ["Date", "Reference", "Amount", "Status"],

            data: expenseLogs.map((e) {
              return [
                e["date"].toString(),

                e["reference"].toString(),

                e["amount"].toString(),

                e["status"].toString(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/expense_report.pdf");

    await file.writeAsBytes(await pdf.save());

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("PDF Saved : ${file.path}")));
  }

  Future<void> printPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [
              pw.Text("Expense Report", style: pw.TextStyle(fontSize: 24)),

              pw.SizedBox(height: 20),

              pw.Text(
                "Total Expenses : ₹ ${expenseData?['totalExpenses'] ?? 0}",
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
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
                                      fetchExpenseReport();
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
                                      fetchExpenseReport();
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
                                  items: [
                                    "All Locations",
                                    ...branchList
                                        .map(
                                          (e) =>
                                              e["branch_name"]?.toString() ??
                                              "Unknown",
                                        )
                                        .toSet()
                                        .toList(),
                                  ],
                                  onChanged: (v) {
                                    setState(() {
                                      branch = v!;
                                    });
                                    fetchExpenseReport();
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
                                    if (value == selectedReport) {
                                      return;
                                    }

                                    setState(() {
                                      selectedReport = value!;
                                    });

                                    Widget? nextScreen;

                                    if (value == "Financial Summary") {
                                      nextScreen =
                                          const AdminReportDashboardScreen();
                                    } else if (value == "Purchase Report") {
                                      nextScreen = const PurchaseReportScreen();
                                    } else if (value == "Branch Sales Report") {
                                      nextScreen = const SalesReportScreen();
                                    } else if (value == "Warehouse Report") {
                                      nextScreen =
                                          const WarehouseReportScreen();
                                    }

                                    if (nextScreen != null) {
                                      Navigator.pushReplacement(
                                        context,

                                        MaterialPageRoute(
                                          builder: (_) => nextScreen!,
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
                              InkWell(
                                onTap: exportPdf,

                                child: buildActionButton(
                                  title: "Export PDF",

                                  icon: Icons.picture_as_pdf,

                                  bgColor: Colors.white,
                                ),
                              ),

                              const SizedBox(width: 14),

                              InkWell(
                                onTap: printPdf,

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
                          children: expenseStats.map((e) {
                            IconData getIcon(String name) {
                              switch (name) {
                                case "money":
                                  return Icons.money;
                                case "truck":
                                  return Icons.local_shipping;
                                case "warehouse":
                                  return Icons.inventory;
                                case "check":
                                  return Icons.check_circle_outline;
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
                                default:
                                  return Colors.green;
                              }
                            }

                            Color iconColor = getColor(
                              e["color"]?.toString() ?? "green",
                            );

                            return ExpenseStatCard(
                              title: e["title"].toString(),
                              amount: e["title"] == "Pending Approvals"
                                  ? e["amount"].toString()
                                  : "₹ ${e["amount"]}",
                              growth: e["growth"].toString(),
                              icon: getIcon(e["icon"]?.toString() ?? ""),
                              iconColor: iconColor,
                              // ignore: deprecated_member_use
                              iconBg: iconColor.withOpacity(0.1),
                              growthColor:
                                  e["growth"].toString().contains("-") &&
                                      e["growth"].toString() != "-"
                                  ? Colors.red
                                  : Colors.green,
                            );
                          }).toList(),
                        );
                      },
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

                                  border: Border.all(
                                    color: const Color(0xffE5E7EB),
                                  ),
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

                          const Wrap(
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: 14,
  runSpacing: 6,

  children: [
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
          "Operating Expenses",
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
          color: Color(0xffE5E7EB),
          size: 12,
        ),

        SizedBox(width: 4),

        Text(
          "Capital Expenditures",
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    ),
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

                          ...expenseCategories.map((e) {
                            return buildCategoryRow(
                              e["title"].toString(),

                              e["amount"].toString(),

                              double.tryParse(e["progress"].toString()) ?? 0.0,

                              Colors.blue,
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// TABLE
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

                          const SizedBox(height: 24),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: DataTable(
                              columnSpacing: 70,

                              headingRowHeight: 56,

                              dataRowMinHeight: 62,

                              dataRowMaxHeight: 68,

                              dividerThickness: 0.6,

                              // ignore: deprecated_member_use
                              headingRowColor: MaterialStateProperty.all(
                                const Color(0xffF8FAFC),
                              ),

                              columns: const [
                                DataColumn(
                                  label: Text(
                                    "DATE",

                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                      color: Color(0xff64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                DataColumn(
                                  label: Text(
                                    "SOURCE",

                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                      color: Color(0xff64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                DataColumn(
                                  label: Text(
                                    "CATEGORY",

                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                      color: Color(0xff64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                DataColumn(
                                  label: Text(
                                    "LOCATION / BRANCH",

                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                      color: Color(0xff64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                DataColumn(
                                  label: Text(
                                    "AMOUNT",

                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                      color: Color(0xff64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                DataColumn(
                                  label: Text(
                                    "STATUS",

                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                      color: Color(0xff64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],

                              rows: expenseLogs.map<DataRow>((e) {
                                final status =
                                    e["status"]?.toString() ?? "Paid";

                                return DataRow(
                                  cells: [
                                    /// DATE
                                    DataCell(
                                      Text(
                                        e["date"]?.toString() ?? "",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    /// SOURCE
                                    DataCell(
                                      Text(
                                        e["source"]?.toString() ??
                                            e["reference"]?.toString() ??
                                            "Branch",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    /// CATEGORY
                                    DataCell(
                                      Text(
                                        e["category"]?.toString() ?? "",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    /// LOCATION
                                    DataCell(
                                      Text(
                                        e["location"]?.toString() ??
                                            e["branch"]?.toString() ??
                                            "",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    /// AMOUNT
                                    DataCell(
                                      Text(
                                        "₹${e["amount"] ?? 0}",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    /// STATUS
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),

                                        decoration: BoxDecoration(
                                          color: status == "Paid"
                                              ? const Color(0xffDCFCE7)
                                              : status == "Rejected"
                                              ? const Color(0xffFEE2E2)
                                              : const Color(0xffFEF3C7),

                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),

                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,

                                          children: [
                                            Icon(
                                              status == "Paid"
                                                  ? Icons.check_circle_outline
                                                  : status == "Rejected"
                                                  ? Icons.cancel_outlined
                                                  : Icons.access_time,

                                              size: 14,

                                              color: status == "Paid"
                                                  ? Colors.green
                                                  : status == "Rejected"
                                                  ? Colors.red
                                                  : Colors.orange,
                                            ),

                                            const SizedBox(width: 5),

                                            Text(
                                              status,

                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,

                                                color: status == "Paid"
                                                    ? Colors.green
                                                    : status == "Rejected"
                                                    ? Colors.red
                                                    : Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              // ignore: deprecated_member_use
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
  final Color iconColor;
  final Color iconBg;
  final Color growthColor;

  const ExpenseStatCard({
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
                fontSize: 12, // reduced
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
              size: 16, // reduced
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
            fontSize: 20, // reduced
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),

      const SizedBox(height: 6),

      /// GROWTH
      Flexible(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 3,
          runSpacing: 2,
          children: [
            if (growth != "-")
              Icon(
                growth.contains("-")
                    ? Icons.trending_down
                    : Icons.trending_up,
                size: 14, // reduced
                color: growthColor,
              ),

            Text(
              growth == "-" ? "No change" : growth,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: growth == "-"
                    ? const Color(0xff9CA3AF)
                    : growthColor,
                fontSize: 11, // reduced
                fontWeight: FontWeight.w600,
              ),
            ),

            if (growth != "-")
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
