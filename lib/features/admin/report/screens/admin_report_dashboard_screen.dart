import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:proteinova_connect/features/admin/report/data/report_service.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_report_dashboard_shimmer.dart';

import '../widgets/financial_summary_table.dart';
import '../widgets/report_filter_field.dart';
import '../widgets/report_stat_card.dart';
import '../widgets/revenue_chart_card.dart';
import '../widgets/top_branch_tile.dart';

class AdminReportDashboardScreen extends StatefulWidget {
  const AdminReportDashboardScreen({super.key});

  @override
  State<AdminReportDashboardScreen> createState() =>
      _AdminReportDashboardScreenState();
}

class _AdminReportDashboardScreenState
    extends State<AdminReportDashboardScreen> {
  String selectedReport = "Financial Summary";

  final ReportService reportService = ReportService();

  bool isLoading = true;

  Map<String, dynamic>? summaryData;

  List<dynamic> topBranches = [];

  String fromDate = "dd-mm-yyyy";
  String toDate = "dd-mm-yyyy";
  String selectedBranch = "All Branches";
  List<dynamic> branchList = [];
  List<dynamic> revenueBreakdown = [];

  List<dynamic> expenseBreakdown = [];

  List<dynamic> profitSummary = [];

  List<dynamic> orderDistribution = [];
  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];
  void showSummaryDialog({
    required String title,
    required List<Map<String, dynamic>> rows,
  }) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TOP HANDLE
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),

                  width: 60,
                  height: 6,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,

                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,

                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),

                child: Text(
                  "Detailed report data for your selection",

                  style: TextStyle(color: Color(0xff64748B)),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),

                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffE5E7EB)),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      children: [
                        /// HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),

                          decoration: const BoxDecoration(
                            color: Color(0xffF8FAFC),

                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),

                          child: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "CATEGORY / BRANCH",

                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xff94A3B8),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  "AMOUNT / COUNT",

                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xff94A3B8),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  "DETAILS",

                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xff94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// ROWS
                        ...rows.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),

                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),

                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e["name"].toString(),

                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    e["amount"].toString(),

                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    e["details"].toString(),

                                    style: const TextStyle(
                                      color: Color(0xff64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<void> fetchReport() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (branchList.isEmpty) {
        final branches = await reportService.getBranches();
        branchList = branches;
      }

      String? branchId;
      if (selectedBranch != "All Branches") {
        final b = branchList.firstWhere(
          (element) => element['branch_name'] == selectedBranch,
          orElse: () => null,
        );
        if (b != null) {
          branchId = b['id']?.toString() ?? b['branch_id']?.toString();
        }
      }

      String? start = fromDate != "dd-mm-yyyy" ? fromDate : null;
      String? end = toDate != "dd-mm-yyyy" ? toDate : null;

  

      final data = await reportService.getFinancialSummary(
        startDate: start,
        endDate: end,
        branchId: branchId,
      );
      debugPrint("API RESPONSE: $data");
      debugPrint(data.toString());
      setState(() {
        summaryData = data["summary"];
        topBranches = data["topBranches"] ?? [];
        revenueBreakdown = (data["summary"]?["branches"] ?? []).map((e) {
          return {
            "name": e["branch_name"] ?? "",
            "amount": "₹ ${e["revenue"] ?? 0}",
            "details": "${e["orders"] ?? 0} Orders",
          };
        }).toList();

        expenseBreakdown = [
          {
            "name": "Purchase Expenses",
            "amount": "₹ ${summaryData?['totalExpenses'] ?? 0}",
            "details": "Operating Costs",
          },
        ];

        profitSummary = [
          {
            "name": "Total Revenue",
            "amount": "₹ ${summaryData?['totalRevenue'] ?? 0}",
            "details": "Sales Income (+)",
          },

          {
            "name": "Total Expenses",
            "amount": "₹ ${summaryData?['totalExpenses'] ?? 0}",
            "details": "Expense (-)",
          },

          {
            "name": "Net Profit",
            "amount": "₹ ${summaryData?['netProfit'] ?? 0}",
            "details": "Final Profit/Loss",
          },
        ];

        orderDistribution = (data["summary"]?["branches"] ?? []).map((e) {
          return {
            "name": e["branch_name"] ?? "",
            "amount": "${e["orders"] ?? 0}",
            "details": "Orders",
          };
        }).toList();
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
          pw.Text(
            "Financial Summary Report",
            style: pw.TextStyle(fontSize: 24),
          ),

          pw.SizedBox(height: 20),

          pw.Text("Total Revenue : Rs. ${summaryData?['totalRevenue'] ?? 0}"),

          pw.Text("Total Expenses : Rs. ${summaryData?['totalExpenses'] ?? 0}"),

          pw.Text("Net Profit : Rs. ${summaryData?['netProfit'] ?? 0}"),
          pw.Text("Total Orders : ${summaryData?['totalOrders'] ?? 0}"),

          pw.SizedBox(height: 30),

          pw.Text("Top Performing Branches", style: pw.TextStyle(fontSize: 18)),

          pw.SizedBox(height: 10),

          pw.TableHelper.fromTextArray(
            headers: ["Branch", "Amount"],

            data: topBranches.map((e) {
              return [e["branch_name"].toString(), e["amount"].toString()];
            }).toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/financial_report.pdf");

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
              pw.Text(
                "Financial Summary Report",
                style: pw.TextStyle(fontSize: 24),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Revenue : Rs. ${summaryData?['totalRevenue'] ?? 0}"),
              pw.Text("Expenses : Rs. ${summaryData?['totalExpenses'] ?? 0}"),
              pw.Text("Profit : Rs. ${summaryData?['netProfit'] ?? 0}"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
     if (isLoading) {
    return const AdminReportDashboardShimmer();
  }

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      body: SafeArea(
        child:SingleChildScrollView(
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
                            "Report Dashboard",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
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
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// SEARCH
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Container(
                    //         height: 58,

                    //         padding: const EdgeInsets.symmetric(horizontal: 18),

                    //         decoration: BoxDecoration(
                    //           color: Colors.white,
                    //           borderRadius: BorderRadius.circular(14),
                    //           border: Border.all(
                    //             color: const Color(0xffE5E7EB),
                    //           ),
                    //         ),

                    //         child: const Row(
                    //           children: [
                    //             Icon(Icons.search),

                    //             SizedBox(width: 12),

                    //             Expanded(
                    //               child: Text(
                    //                 "Search reports...",
                    //                 overflow: TextOverflow.ellipsis,
                    //                 style: TextStyle(color: Color(0xff9CA3AF)),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),

                    //     const SizedBox(width: 14),

                    //     Container(
                    //       width: 58,
                    //       height: 58,

                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(14),
                    //         border: Border.all(color: const Color(0xffE5E7EB)),
                    //       ),

                    //       child: const Icon(Icons.filter_alt_outlined),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 24),

                    /// FILTER CARD
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,

                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: ReportFilterField(
                              hint: fromDate,
                              prefix: Icons.calendar_month,
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
                                  fetchReport();
                                }
                              },
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: ReportFilterField(
                              hint: toDate,
                              prefix: Icons.calendar_month,
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
                                  fetchReport();
                                }
                              },
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: Container(
                              height: 58,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xffE5E7EB),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedBranch,
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem(
                                      value: "All Branches",
                                      child: Text("All Branches"),
                                    ),
                                    ...branchList
                                        .map((e) {
                                          final bName =
                                              e['branch_name']?.toString() ??
                                              'Unknown';
                                          return DropdownMenuItem(
                                            value: bName,
                                            child: Text(bName),
                                          );
                                        })
                                        .toSet()
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    if (value != null &&
                                        value != selectedBranch) {
                                      setState(() {
                                        selectedBranch = value;
                                      });
                                      fetchReport();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.38,

                            child: Container(
                              height: 58,

                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xffE5E7EB),
                                ),
                              ),

                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedReport,
                                  isExpanded: true,

                                  items: reportItems.map((e) {
                                    return DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    );
                                  }).toList(),

                                  onChanged: (value) {
                                    if (value == null) return;

                                    Widget? nextScreen;

                                    if (value == "Purchase Report") {
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
                                        MaterialPageRoute(
                                          builder: (_) => nextScreen!,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),

                          InkWell(
                            onTap: exportPdf,

                            child: Container(
                              height: 58,
                              width: 150,

                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xffE5E7EB),
                                ),
                              ),

                              child: const Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(Icons.picture_as_pdf),

                                  SizedBox(width: 8),

                                  Text(
                                    "Export PDF",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          InkWell(
                            onTap: printPdf,

                            child: Container(
                              height: 58,
                              width: 150,

                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                              ),

                              decoration: BoxDecoration(
                                color: const Color(0xffFACC15),
                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: const Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(Icons.print),

                                  SizedBox(width: 8),

                                  Text(
                                    "Print",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                      childAspectRatio: 0.95,

                      children: [
                        ReportStatCard(
                          title: "Total Revenue",
                          amount: "₹ ${summaryData?['totalRevenue'] ?? 0}",
                          growth: "+12.5%",
                          icon: Icons.currency_rupee,
                          iconBg: const Color(0xffDCFCE7),
                          growthColor: Colors.green,

                          onTap: () {
                            showSummaryDialog(
                              title: "Revenue Breakdown",

                              rows: revenueBreakdown.map<Map<String, dynamic>>((
                                e,
                              ) {
                                return {
                                  "name": e["name"].toString(),
                                  "amount": e["amount"].toString(),
                                  "details": e["details"].toString(),
                                };
                              }).toList(),
                            );
                          },
                        ),

                        ReportStatCard(
                          title: "Total Expenses",
                          amount: "₹ ${summaryData?['totalExpenses'] ?? 0}",
                          growth: "-8.2%",
                          icon: Icons.trending_down,
                          iconBg: const Color(0xffFEE2E2),
                          growthColor: Colors.red,

                          onTap: () {
                            showSummaryDialog(
                              title: "Itemized Expenses",

                              rows: expenseBreakdown.map<Map<String, dynamic>>((
                                e,
                              ) {
                                return {
                                  "name": e["name"].toString(),
                                  "amount": e["amount"].toString(),
                                  "details": e["details"].toString(),
                                };
                              }).toList(),
                            );
                          },
                        ),

                        ReportStatCard(
                          title: "Net Profit",
                          amount: "₹ ${summaryData?['netProfit'] ?? 0}",
                          growth: "+15.3%",
                          icon: Icons.trending_up,
                          iconBg: const Color(0xffDCFCE7),
                          growthColor: Colors.green,

                          onTap: () {
                            showSummaryDialog(
                              title: "Profit Summary",

                              rows: profitSummary.map<Map<String, dynamic>>((
                                e,
                              ) {
                                return {
                                  "name": e["name"].toString(),
                                  "amount": e["amount"].toString(),
                                  "details": e["details"].toString(),
                                };
                              }).toList(),
                            );
                          },
                        ),

                        ReportStatCard(
                          title: "Total Orders",
                          amount: "${summaryData?['totalOrders'] ?? 0}",
                          growth: "+5.8%",
                          icon: Icons.inventory_2,
                          iconBg: const Color(0xffE9D5FF),
                          growthColor: Colors.green,

                          onTap: () {
                            showSummaryDialog(
                              title: "Order Distribution",

                              rows: orderDistribution.map<Map<String, dynamic>>(
                                (e) {
                                  return {
                                    "name": e["name"].toString(),
                                    "amount": e["amount"].toString(),
                                    "details": e["details"].toString(),
                                  };
                                },
                              ).toList(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    RevenueChartCard(
                      chartData: summaryData?["chartData"] ?? [],
                    ),
                    const SizedBox(height: 24),

                    /// TOP BRANCHES
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Top Performing Branches",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 24),

                          ...topBranches.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 22),

                              child: TopBranchTile(
                                branch: e["branch_name"].toString(),

                                amount: "₹ ${e["amount"].toString()}",

                                progress:
                                    double.tryParse(e["progress"].toString()) ??
                                    0.0,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// TABLE
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Financial Summary by Branch",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 24),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: FinancialSummaryTable(
                              branches: summaryData?["branches"] ?? const [],
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),

                              SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  "All amounts are in INR (₹)",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
