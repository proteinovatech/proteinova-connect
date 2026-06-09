
import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';

import '../../admin/report/widgets/report_filter_field.dart';
import '../../admin/report/widgets/report_stat_card.dart';
import '../../admin/report/widgets/revenue_chart_card.dart';
import '../../admin/report/widgets/top_branch_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_state.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() =>
      _PurchaseReportScreenState();
}

class _PurchaseReportScreenState
    extends State<PurchaseReportScreen> {
     
    
  String selectedReport = "Financial Summary";

 
  bool isLoading = true;

 
  String fromDate = "dd-mm-yyyy";
  String toDate = "dd-mm-yyyy";
  String selectedBranch = "All Branches";
 
  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];
  List<dynamic> purchases = [];

double totalPurchaseAmount = 0;
int totalOrders = 0;
int totalTrays = 0;
int totalEggs = 0;

List<Map<String, dynamic>> supplierSummary = [];
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
   loadPurchaseData();
   
  }

  Future<void> loadPurchaseData() async {
  try {
    setState(() {
      isLoading = true;
    });

    final purchaseBloc =
        context.read<PurchaseBloc>();

    purchases = purchaseBloc.state is PurchaseLoaded
        ? (purchaseBloc.state as PurchaseLoaded)
            .purchases
        : [];

    totalPurchaseAmount = 0;
    totalOrders = purchases.length;
    totalTrays = 0;

    Map<String, double> supplierMap = {};

    for (var purchase in purchases) {
      final items = purchase["items"] ?? [];

      double purchaseAmount = 0;

      for (var item in items) {
        final trays = item["trays"] ?? 0;

        final capacity =
            item["capacity"] ?? 30;

        final rate =
            double.tryParse(
                  item["per_egg_price"]
                          ?.toString() ??
                      "0",
                ) ??
                0;

        purchaseAmount +=
            trays * capacity * rate;

        totalTrays +=
            (trays as num).toInt();
      }

      totalPurchaseAmount +=
          purchaseAmount;

      final supplier =
          purchase["supplier_company_name"] ??
              "Unknown";

      supplierMap[supplier] =
          (supplierMap[supplier] ?? 0) +
              purchaseAmount;
    }

    totalEggs = totalTrays * 30;

    supplierSummary =
        supplierMap.entries.map((e) {
      return {
        "supplier": e.key,
        "amount": e.value,
      };
    }).toList();

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
  }
}
//   Future<void> exportPdf() async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.MultiPage(
//         build: (context) => [
//           pw.Text(
//             "Financial Summary Report",
//             style: pw.TextStyle(fontSize: 24),
//           ),

//           pw.SizedBox(height: 20),

//           pw.Text("Total Revenue : Rs. ${['totalRevenue']}"),

//           pw.Text("Total Expenses : Rs. ${['totalExpenses'] ?? 0}"),

//           pw.Text("Net Profit : Rs. ${['netProfit'] ?? 0}"),
//           pw.Text("Total Orders : ${['totalOrders'] ?? 0}"),

//           pw.SizedBox(height: 30),

//           pw.Text("Top Performing Suppliers", style: pw.TextStyle(fontSize: 18)),

//           pw.SizedBox(height: 10),

//          pw.TableHelper.fromTextArray(
//   headers: ["Supplier", "Amount"],
//   data: supplierSummary.map((e) {
//     return [
//       e["supplier"].toString(),
//       e["amount"].toString(),
//     ];
//   }).toList(),
// ), ],
//       ),
//     );

//     final dir = await getApplicationDocumentsDirectory();

//     final file = File("${dir.path}/financial_report.pdf");

//     await file.writeAsBytes(await pdf.save());

//     if (!mounted) return;

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("PDF Saved : ${file.path}")));
//   }

//   Future<void> printPdf() async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (context) {
//           return pw.Column(
//             children: [
//               pw.Text(
//                 "Financial Summary Report",
//                 style: pw.TextStyle(fontSize: 24),
//               ),

//               pw.SizedBox(height: 20),
//               pw.Text(
//                 "Total Purchase : ₹${totalPurchaseAmount.toStringAsFixed(2)}",
//               ),
//               pw.Text(
//                 "Purchase Orders : $totalOrders",
//               ),
//               pw.Text(
//                 "Total Trays : $totalTrays",
//               ),
//               pw.Text(
//                 "Total Eggs : $totalEggs",
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     await Printing.layoutPdf(onLayout: (format) async => pdf.save());
//   }

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
                                 loadPurchaseData();
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
                                  loadPurchaseData();
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
                                    ],
                                  onChanged: (value) {
                                    if (value != null &&
                                        value != selectedBranch) {
                                      setState(() {
                                        selectedBranch = value;
                                      });
                                      loadPurchaseData();
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

                          // InkaWell(
                          //   onTap: exportPdf,

                          //   child: Container(
                          //     height: 58,
                          //     width: 150,

                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 18,
                          //     ),

                          //     decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.circular(14),
                          //       border: Border.all(
                          //         color: const Color(0xffE5E7EB),
                          //       ),
                          //     ),

                          //     child: const Row(
                          //       mainAxisSize: MainAxisSize.min,

                          //       children: [
                          //         Icon(Icons.picture_as_pdf),

                          //         SizedBox(width: 8),

                          //         Text(
                          //           "Export PDF",
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.w700,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          // InkWell(
                          //   onTap: printPdf,

                          //   child: Container(
                          //     height: 58,
                          //     width: 150,

                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 22,
                          //     ),

                          //     decoration: BoxDecoration(
                          //       color: const Color(0xffFACC15),
                          //       borderRadius: BorderRadius.circular(14),
                          //     ),

                          //     child: const Row(
                          //       mainAxisSize: MainAxisSize.min,

                          //       children: [
                          //         Icon(Icons.print),

                          //         SizedBox(width: 8),

                          //         Text(
                          //           "Print",
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.w700,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        
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
  title: "Total Purchase",
  amount:
      "₹ ${totalPurchaseAmount.toStringAsFixed(2)}",
  growth: "",
  icon: Icons.shopping_cart,
  iconBg: const Color(0xffDCFCE7),
  growthColor: Colors.green,
),

ReportStatCard(
  title: "Purchase Orders",
  amount: "$totalOrders",
  growth: "",
  icon: Icons.receipt_long,
  iconBg: const Color(0xffE0F2FE),
  growthColor: Colors.blue,
),

ReportStatCard(
  title: "Total Trays",
  amount: "$totalTrays",
  growth: "",
  icon: Icons.inventory,
  iconBg: const Color(0xffFEF3C7),
  growthColor: Colors.orange,
),

ReportStatCard(
  title: "Total Eggs",
  amount: "$totalEggs",
  growth: "",
  icon: Icons.egg,
  iconBg: const Color(0xffF3E8FF),
  growthColor: Colors.purple,
), ],
                    ),

                    const SizedBox(height: 24),

                    RevenueChartCard(
                      chartData: ["chartData"] ,
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
                            "Top Suppliers",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 24),

                        ...supplierSummary.map((e) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 22,
    ),
    child: TopBranchTile(
      branch: e["supplier"],
      amount:
          "₹ ${e["amount"].toStringAsFixed(2)}",
      progress: 1,
    ),
  );
}),   ],
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
                            child:DataTable(
  columns: const [
    DataColumn(label: Text("PO ID")),
    DataColumn(label: Text("Supplier")),
    DataColumn(label: Text("Status")),
    DataColumn(label: Text("Amount")),
  ],
  rows: purchases.map((p) {

    final items = p["items"] ?? [];

    double amount = 0;

    for (var item in items) {
      amount +=
          (item["trays"] ?? 0) *
          (item["capacity"] ?? 30) *
          (double.tryParse(
                item["per_egg_price"]
                        ?.toString() ??
                    "0",
              ) ??
              0);
    }

    return DataRow(
      cells: [
        DataCell(Text("PO-${p["id"]}")),
        DataCell(
          Text(
            p["supplier_company_name"] ??
                "",
          ),
        ),
        DataCell(
          Text(
            p["purchase_status"] ?? "",
          ),
        ),
        DataCell(
          Text(
            "₹ ${amount.toStringAsFixed(2)}",
          ),
        ),
      ],
    );
  }).toList(),
) ),
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
