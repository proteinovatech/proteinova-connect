import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/report/data/report_service.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_report_dashboard_shimmer.dart';

class PurchaseReport extends StatefulWidget {
  const PurchaseReport({super.key});

  @override
  State<PurchaseReport> createState() => _PurchaseReportState();
}

class _PurchaseReportState extends State<PurchaseReport> {
  String viewMode = "Monthly";
  String supplier = "All Suppliers";
  String eggType = "All Types";
  String reportCategory = "Purchase Report";
  String selectedReport = "Purchase Report";

  String fromDate = "dd-mm-yyyy";
  String toDate = "dd-mm-yyyy";

  final ReportService reportService = ReportService();

  bool isLoading = true;

  Map<String, dynamic>? purchaseData;

  List<dynamic> purchaseStats = [];

  List<dynamic> suppliers = [];
  List<dynamic> spendBySupplier = [];

  List<dynamic> volumeBySupplier = [];

  List<dynamic> supplierList = [];
  List<dynamic> branches = [];
  String? selectedBranch;
   List<dynamic> totalOrdersList = [];
  List<dynamic> avgUnitCost = [];
  List<dynamic> monthlySummary = [];
  List<Map<String, dynamic>> monthlyTrend = [];
  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];
  final indianCurrency = NumberFormat('#,##,##0', 'en_IN');
  void showPurchaseBottomSheet({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> rows,
  }) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
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
                          fontSize: 26,
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),

                child: Text(
                  subtitle,

                  style: const TextStyle(color: Color(0xff64748B)),
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
                                  "DATE",

                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xff94A3B8),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "SUPPLIER",

                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xff94A3B8),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  "CATEGORY",

                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xff94A3B8),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  "VALUE",

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

                        ...rows.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
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
                                    e["date"].toString(),

                                    style: AppTextStyles.bodyText12
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    e["supplier_company_name"].toString(),

                                    style:AppTextStyles.bodyText12dark
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    e["category"].toString(),

                                    style: AppTextStyles.bodyText12
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    e["value"].toString(),

                                    style: AppTextStyles.bodyText12dark
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

    fetchPurchaseReport();
     fetchBranches();
  }
  Future<void> fetchBranches() async {
  try {
    final data = await reportService.getBranches();

    setState(() {
      branches = data;

      if (branches.isNotEmpty) {
        selectedBranch = branches.first["name"];
      }
    });
  } catch (e) {
    debugPrint("Error loading branches: $e");
  }
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
                                "Purchase",

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

                      child:
                       Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
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
    "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year.toString().substring(2)}";});
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
    "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year.toString().substring(2)}"; });
          }
        },
      ),
    ),

    const SizedBox(width: 10),
   SizedBox(
  width: 56,
  height: 56,
  child: ElevatedButton(
    onPressed: fetchPurchaseReport,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xffFACC15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: const Icon(
      Icons.search,
      color: Colors.black,
    ),
  ),
),
  ],
),
                 
                          
                      
                          buildDropdownField(
                            title: "View Mode",
                            value: viewMode,
                            items: const ["Monthly", "Weekly", "Yearly"],
                            onChanged: (v) {
                              setState(() {
                                viewMode = v!;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

//                           Row(
//                             children: [
//    Expanded(
//   child: buildDropdownField(
//     title: "Branch",
//     value: selectedBranch??"All Branches",
//      items: [
//       "All Branches",
//       ...branches
//           .map<String>((e) => e["branch_name"].toString())
//           .toSet()
//           .toList(),
//     ],
//     onChanged: (v) {
//       setState(() {
//         selectedBranch = v;
//       });
//     },
//   ),
// ),                            const SizedBox(width: 14),

//                               Expanded(
//                                 child: buildDropdownField(
//                                   title: "Egg Type",

//                                   value: eggType,

//                                   items: const [
//                                     "All Types",

//                                     "White Egg",

//                                     "Brown Egg",
//                                   ],

//                                   onChanged: (v) {
//                                     setState(() {
//                                       eggType = v!;
//                                     });
//                                   },
//                                 ),
//                               ),

//                               const SizedBox(width: 14),

//                               Expanded(
//                                 child: buildDropdownField(
//                                   title: "Report Category",

//                                   value: selectedReport,

//                                   items: reportItems,

//                                   onChanged: (value) {
//                                     if (value == selectedReport) return;
//                                     setState(() {
//                                       selectedReport = value!;
//                                     });

//                                     Widget? nextScreen;
//                                     if (value == "Financial Summary") {
//                                       nextScreen =
//                                           const AdminReportDashboardScreen();
//                                     } else if (value == "Purchase Report") {
//                                       nextScreen = const PurchaseReport();
//                                     } else if (value == "Expense Report") {
//                                       nextScreen = const ExpenseReportScreen();
//                                     } else if (value == "Branch Sales Report") {
//                                       nextScreen = const SalesReportScreen();
//                                     } else if (value == "Warehouse Report") {
//                                       nextScreen =
//                                           const WarehouseReportScreen();
//                                     }

//                                     if (nextScreen != null) {
//                                       Navigator.pushReplacement(
//                                         context,
//                                         PageRouteBuilder(
//                                           pageBuilder: (_, __, ___) =>
//                                               nextScreen!,
//                                           transitionDuration: Duration.zero,
//                                           reverseTransitionDuration:
//                                               Duration.zero,
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),

                          // const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

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
                      crossAxisCount: MediaQuery.of(context).size.width > 1000
                          ? 4
                          : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: MediaQuery.of(context).size.width > 1000
                          ? 2.0
                          : 1.3,
                      children: purchaseStats.map((e) {
                        IconData getIcon(String name) {
                          switch (name) {
                            case "money":
                              return Icons.currency_rupee;
                            case "box":
                              return Icons.inventory_2;
                            case "calculator":
                              return Icons.calculate;
                            case "people":
                              return Icons.group;
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

                        return PurchaseStatCard(
                          title: e["title"].toString(),

                         amount: e["title"].toString().contains("Spend")
    ? "₹ ${indianCurrency.format(
        double.tryParse(e["amount"]?.toString() ?? "0") ?? 0,
      )}"
    : e["amount"].toString(),

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

                          onTap: () {
                            if (e["title"] == "Total Spend") {
                              showPurchaseBottomSheet(
                                title: "Spend by Supplier",

                                subtitle:
                                    "Detailed purchase data for your selection",

                                 rows: monthlySummary.map<Map<String, dynamic>>((e) {
    return {
      "date": DateFormat("dd/MM/yyyy").format(
        DateTime.parse(e["date"]),
      ),
      "supplier_company_name": e["supplier_company_name"] ?? "",
      "category": e["category"] ?? "",
      "value":
          "₹ ${NumberFormat('#,##,##0', 'en_IN').format(
        double.tryParse(e["total_amount"].toString()) ?? 0,
      )}",
    };
  }).toList(),
                              );
                            } else if (e["title"] == "Purchase Volume" ||
                                e["title"] == "Total Volume (Units)") {
                              showPurchaseBottomSheet(
                                title: "Volume by Supplier",

                                subtitle:
                                    "Detailed purchase data for your selection",

                            rows: monthlySummary.map<Map<String, dynamic>>((e) {
  return {
    "date": DateFormat("dd/MM/yyyy").format(
      DateTime.parse(e["date"].toString()),
    ),
    "supplier_company_name":
        e["supplier_company_name"]?.toString() ?? "",
    "category": e["category"]?.toString() ?? "",
    "value": e["total_trays"]?.toString() ?? "",
  };
}).toList(),
                              );
                            } else if (e["title"] == "Supplier Count" ||
                                e["title"] == "Active Suppliers") {
                              showPurchaseBottomSheet(
                                title: "Supplier List",

                                subtitle:
                                    "Detailed purchase data for your selection",

rows: supplierList.map<Map<String, dynamic>>((supplier) {
  final supplierName = supplier["name"].toString();

  // Find the first purchase of this supplier
  final supplierData = monthlySummary.firstWhere(
    (order) => order["supplier_name"]?.toString() == supplierName,
    orElse: () => <String, dynamic>{},
  );

  final totalOrders = monthlySummary.where((order) {
    return order["supplier_name"]?.toString() == supplierName;
  }).length;

  return {
    "date": "-",
    "supplier_company_name":
        supplierData["supplier_company_name"]?.toString() ?? "-",
    "category": "-",
    "value": totalOrders.toString(),
  };
}).toList(), );
                            } else if (e["title"] == "Total Orders") {
                              showPurchaseBottomSheet(
                                title: "Total Orders",

                                subtitle:
                                    "Detailed purchase orders",

 rows: monthlySummary.map<Map<String, dynamic>>((e) {
  return {
    "date": DateFormat("dd/MM/yyyy").format(
      DateTime.parse(e["date"].toString()),
    ),
    "supplier_company_name":
        e["supplier_company_name"]?.toString() ?? "",
    "category": e["category"]?.toString() ?? "",
     "value":
          "₹ ${NumberFormat('#,##,##0', 'en_IN').format(
        double.tryParse(e["total_amount"].toString()) ?? 0,
      )}",
  };
}).toList(),                      );
                            }
                          },
                        );
                      }).toList(),
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

                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                  
                                  
                                    children: [
                                      ...monthlyTrend.map((e) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: buildBar(
                                          double.tryParse(e["spend"].toString()) ?? 0,
                                          double.tryParse(e["volume"].toString()) ?? 0,
                                        e["month"].toString(),
                                      ),
                                    );
                                  }),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Container(
                              //   height: 54,

                              //   decoration: BoxDecoration(
                              //     color: const Color(0xffF3F4F6),

                              //     borderRadius: BorderRadius.circular(14),
                              //   ),

                              //   child: const Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,

                              //     children: [
                              //       Text(
                              //         "View Details",

                              //         style: TextStyle(
                              //           fontWeight: FontWeight.w700,
                              //         ),
                              //       ),

                              //       SizedBox(width: 10),

                              //       Icon(Icons.arrow_forward_ios, size: 16),
                              //     ],
                              //   ),
                              // ),
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

                              ...suppliers.map((e) {
                                return buildSupplierRow(
                                  e["name"].toString(),
                                  "₹ ${indianCurrency.format(
                               double.tryParse(e["amount"]?.toString() ?? "0") ?? 0,
                                )}",
                                  double.tryParse(e["progress"].toString()) ??
                                      0.0,
                                );
                              }),
                             
                              
                             
                              const SizedBox(height: 28),

                              // Container(
                              //   height: 54,

                              //   decoration: BoxDecoration(
                              //     color: const Color(0xffF3F4F6),

                              //     borderRadius: BorderRadius.circular(14),
                              //   ),

                              //   child: const Row(
                              //     mainAxisAlignment: MainAxisAlignment.center,

                              //     children: [
                              //       Text(
                              //         "View All",

                              //         style: TextStyle(
                              //           fontWeight: FontWeight.w700,
                              //         ),
                              //       ),

                              //       SizedBox(width: 10),

                              //       Icon(Icons.arrow_forward_ios, size: 16),
                              //     ],
                              //   ),
                              // ),
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
                          const Center(
                            child: Text(
                              "Month-wise Purchase Summary",

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: DataTable(
                              columnSpacing: 90,

                              headingRowHeight: 56,

                              dataRowMinHeight: 56,

                              dataRowMaxHeight: 64,

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
                                    "PURCHASE ID",

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
                                    "SUPPLIER",

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
                                    "TOTAL TRAYS",

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
                                    "TOTAL AMOUNT",

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

                              rows: monthlySummary.map<DataRow>((e) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
  e["date"] != null
      ? DateFormat('dd/MM/yyyy').format(
          DateTime.parse(e["date"].toString()),
        )
      : (e["period"]?.toString() ?? ""),
),
                                    ),

                                    DataCell(
                                      Text(
                                        e["purchaseId"]?.toString() ??
                                            e["purchase_id"]?.toString() ??
                                            e["id"]?.toString() ??
                                            "-",
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        e["supplier"]?.toString() ??
                                            e["supplier_name"]?.toString() ??
                                            "-",
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        "${e["total_trays"] ??e["quantity"] ?? e["qty"] ?? e["trays"] ?? 0}",
                                      ),
                                    ),

                                    DataCell(
                                      Text(
  "₹ ${NumberFormat('#,##,##0', 'en_IN').format(
    double.tryParse(
      (e["totalAmount"] ??
       e["total_amount"] ??
       e["totalSpend"] ??
       e["total_spend"] ??
       0).toString(),
    ) ?? 0,
  )}",
),
                                    ),

                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),

                                        decoration: BoxDecoration(
                                          color: const Color(0xffF1F5F9),

                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),

                                        child: Text(
                                          e["status"]?.toString() ?? "RECEIVED",

                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff475569),
                                          ),
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

  Future<void> fetchPurchaseReport() async {
    try {
      setState(() {
        isLoading = true;
      });

      String? start = fromDate != "dd-mm-yyyy" ? fromDate : null;
      String? end = toDate != "dd-mm-yyyy" ? toDate : null;

      final data = await reportService.getPurchaseReport(
        startDate: start,
        endDate: end,
      );

print("PURCHASE REPORT DATA = $data");
      setState(() {
        purchaseData = data;
    
        purchaseStats = data["stats"] ?? [];
        final int totalOrders =
    (data["monthlySummary"] as List?)?.length ?? 0;
        for (var stat in purchaseStats) {
  if (stat["title"] == "Avg Unit Cost") {
    stat["title"] = "Total Orders";
    stat["amount"] = totalOrders.toString();
    break;
  }
}

        suppliers = data["suppliers"] ?? [];

        monthlySummary = data["monthlySummary"] ?? [];
        debugPrint(monthlySummary.toString());
        spendBySupplier = data["spendBySupplier"] ?? [];

        volumeBySupplier =
            data["volumeBySupplier"] ??
            suppliers.map((e) {
              return {"name": e["name"], "value": e["volume"] ?? 0};
            }).toList();

        supplierList =
            data["supplierList"] ??
            suppliers.map((e) {
              return {"name": e["name"], "value": e["count"] ?? 1};
            }).toList();
           
        totalOrdersList = data["totalOrders"] ?? [];
         monthlyTrend =
      List<Map<String, dynamic>>.from(
        data["monthlyTrend"] ?? [],
      );

        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
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
               return DropdownMenuItem<String>(
    value: e,
    child: Row(
      children: [
        Expanded(
          child: Text(
            e,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
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
    height: 52, // reduced height
    width: 135,

    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xffE5E7EB)),
    ),

    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18, // reduced icon size
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13, // reduced text size
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget buildBar(double spend, double volume, String month) {
     double maxValue = 1;

  for (var e in monthlyTrend) {
    double value =
        double.tryParse(e["spend"].toString()) ?? 0;

    if (value > maxValue) {
      maxValue = value;
    }
  }

  double spendHeight = (spend / maxValue) * 140;
  double volumeHeight = (volume / maxValue) * 140;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Container(
              width: 14,
              height: spendHeight,

              decoration: BoxDecoration(
                color: Colors.blue,

                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 6),

            Container(
              width: 14,
              height: volumeHeight,

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
  final Color iconColor;
  final Color iconBg;
  final Color growthColor;
  final VoidCallback? onTap;
  const PurchaseStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.growth,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.growthColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

    child: Container(
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

          const SizedBox(width: 8),

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

      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (growth != "-")
            Icon(
              growth.contains("-")
                  ? Icons.trending_down
                  : Icons.trending_up,
              size: 14, // reduced
              color: growthColor,
            ),

          if (growth != "-") const SizedBox(width: 3),

          Expanded(
            child: Text(
              growth == "-"
                  ? "- 0.0% vs last period"
                  : "$growth vs last period",

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
          ),
        ],
      ),
    ],
  ),
), );
  }
}
