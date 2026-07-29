import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/report/data/report_service.dart'
    show ReportService;
import 'package:proteinova_connect/features/admin/report/screens/admin_report_dashboard_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_report_dashboard_shimmer.dart';

class WarehouseReportScreen extends StatefulWidget {
  const WarehouseReportScreen({super.key});

  @override
  State<WarehouseReportScreen> createState() => _WarehouseReportScreenState();
}

class _WarehouseReportScreenState extends State<WarehouseReportScreen> {
  int parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  final ReportService repository = ReportService();
  String branch = "All Branches";
  String zone = "All Zones";
  String status = "All Status";
  String reportCategory = "Warehouse Report";
  String selectedReport = "Warehouse Report";

  String fromDate = "";
  String toDate = "";
  List<dynamic> branchList = [];

  final ReportService reportService = ReportService();

  bool isLoading = true;

  Map<String, dynamic>? warehouseData;

  List<dynamic> warehouseStats = [];

  List<dynamic> branchDispatches = [];
  List<Map<String, dynamic>> dispatchVolume = [];
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
                                  value: fromDate.isEmpty
                                      ? "dd-mm-yyyy"
                                      : fromDate,
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
                                      fetchWarehouseReport();
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: buildDateField(
                                  title: "To Date",
                                  value: toDate.isEmpty ? "dd-mm-yyyy" : toDate,
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
                                      fetchWarehouseReport();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: buildDropdownField(
                          //         title: "Destination Branch",
                          //         value: branch,
                          //         items: [
                          //           "All Branches",
                          //           ...branchList
                          //               .map(
                          //                 (e) =>
                          //                     e["branch_name"]?.toString() ??
                          //                     "Unknown",
                          //               )
                          //               .toSet()
                          //               .toList(),
                          //         ],
                          //         onChanged: (v) {
                          //           setState(() {
                          //             branch = v!;
                          //           });
                          //           fetchWarehouseReport();
                          //         },
                          //       ),
                          //     ),

                          //     const SizedBox(width: 14),

                          //     Expanded(
                          //       child: buildDropdownField(
                          //         title: "Warehouse Zone",

                          //         value: zone,

                          //         items: const [
                          //           "All Zones",
                          //           "Zone A",
                          //           "Zone B",
                          //           "Zone C",
                          //         ],

                          //         onChanged: (v) {
                          //           setState(() {
                          //             zone = v!;
                          //           });
                          //         },
                          //       ),
                          //     ),

                          //     const SizedBox(width: 14),

                          //     Expanded(
                          //       child: buildDropdownField(
                          //         title: "Dispatch Status",

                          //         value: status,

                          //         items: const [
                          //           "All Status",
                          //           "Delivered",
                          //           "In Transit",
                          //           "Delayed",
                          //         ],

                          //         onChanged: (v) {
                          //           setState(() {
                          //             status = v!;
                          //           });
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 18),
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
                                      onTap: exportPdf,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: buildActionButton(
                                      title: "Print",
                                      icon: Icons.print,
                                      bgColor: const Color(0xffFACC15),
                                      onTap: printPdf,
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
                          children: warehouseStats.map((e) {
                            IconData getIcon(String name) {
                              switch (name) {
                                case "warehouse":
                                  return Icons.warehouse_outlined;
                                case "truck":
                                  return Icons.local_shipping_outlined;
                                case "check":
                                  return Icons.check_circle_outline;
                                case "clock":
                                  return Icons.access_time;
                                default:
                                  return Icons.inventory_2_outlined;
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

                            return WarehouseStatCard(
                              title: e["title"].toString(),
                              amount: e["amount"].toString(),
                              growth: e["growth"].toString(),
                              icon: getIcon(e["icon"]?.toString() ?? ""),
                              iconColor: iconColor,
                              // ignore: deprecated_member_use
                              iconBg: iconColor.withOpacity(0.1),
                              growthColor: e["growthColor"] != null
                                  ? (e["growthColor"] == "red"
                                        ? Colors.red
                                        : Colors.green)
                                  : (e["growth"].toString().contains("-") &&
                                            !e["growth"].toString().contains(
                                              "- ",
                                            )
                                        ? Colors.red
                                        : Colors.green),
                            );
                          }).toList(),
                        );
                      },
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

                              // TextButton(
                              //   onPressed: () {},

                              //   child: const Text("View All"),
                              // ),
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
                                String status = e["status"]
                                    .toString()
                                    .toUpperCase();

                                Color statusColor;

                                switch (status) {
                                  case "DELIVERED":
                                    statusColor = Colors.green;
                                    break;

                                  case "DELAYED":
                                    statusColor = Colors.red;
                                    break;

                                  default:
                                    statusColor = Colors.orange;
                                }

                                return buildRow(
                                  e["date"].toString(),
                                  e["dispatchId"].toString(),
                                  e["destination"].toString(),
                                  e["vehicle"].toString(),
                                  e["quantity"].toString(),
                                  e["status"].toString(),
                                  statusColor,
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

  // ─── PDF EXPORT & PRINT ──────────────────────────────────────────

  final NumberFormat indianFormat = NumberFormat.decimalPattern('en_IN');

  Future<pw.Document> _buildPdfDocument() async {
    final pdf = pw.Document();

    final dateRangeStr = (fromDate.isNotEmpty || toDate.isNotEmpty)
        ? "${fromDate.isEmpty ? 'Start' : fromDate} to ${toDate.isEmpty ? 'Now' : toDate}"
        : "All Time";

    // Extract summary stats
    String _statValue(String title) {
      for (final s in warehouseStats) {
        if (s['title']?.toString().toLowerCase() == title.toLowerCase()) {
          return s['amount']?.toString() ?? '0';
        }
      }
      return '0';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "PROTEINOVA",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      "Warehouse & Dispatch Report",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    "ADMIN REPORT",
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber900,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Branch: $branch  |  Zone: $zone  |  Period: $dateRangeStr",
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  "Generated: ${DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.now())}",
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.blue800, thickness: 1.5),
            pw.SizedBox(height: 12),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "ProteiNova System  -  Confidential",
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  "Page ${context.pageNumber} of ${context.pagesCount}",
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          // ── Warehouse Summary Stats ──
          pw.Text(
            "Warehouse Summary",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              // Build rows of 3 stats each
              for (int i = 0; i < warehouseStats.length; i += 3)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i == 0 ? PdfColors.blue50 : PdfColors.grey50,
                  ),
                  children: [
                    for (int j = i; j < i + 3; j++)
                      j < warehouseStats.length
                          ? _pdfStatCell(
                              warehouseStats[j]['title']
                                      ?.toString()
                                      .toUpperCase() ??
                                  '',
                              warehouseStats[j]['amount']?.toString() ?? '0',
                            )
                          : _pdfStatCell('', ''),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 18),

          // ── Dispatch by Branch Table ──
          if (branchDispatches.isNotEmpty) ...[
            pw.Text(
              "Dispatch by Branch",
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(2),
              },
              headers: ["#", "Branch Name", "Dispatched (Units)", "Share (%)"],
              data: branchDispatches.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final b = entry.value;
                final trays = (b['trays'] as num?)?.toInt() ?? 0;
                final totalTrays = branchDispatches.fold<int>(
                  0,
                  (sum, item) => sum + ((item['trays'] as num?)?.toInt() ?? 0),
                );
                final pct = totalTrays > 0 ? (trays / totalTrays * 100) : 0.0;
                return [
                  "$idx",
                  b['name']?.toString() ?? 'Unknown',
                  indianFormat.format(trays),
                  "${pct.toStringAsFixed(1)}%",
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 18),
          ],

          // ── Daily Dispatch Volume Table ──
          if (dispatchVolume.isNotEmpty) ...[
            pw.Text(
              "Daily Dispatch Volume",
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.indigo800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              headers: ["Day", "Dispatched (Units)"],
              data: dispatchVolume.map((item) {
                return [
                  item['day']?.toString() ?? '',
                  indianFormat.format(
                    (item['dispatched'] as num?)?.toInt() ?? 0,
                  ),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 18),
          ],

          // ── Recent Dispatch Log Table ──
          if (dispatchLogs.isNotEmpty) ...[
            pw.Text(
              "Recent Dispatch Log",
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 8,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey700,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 4,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(2),
              },
              headers: [
                "Date",
                "Dispatch ID",
                "Destination",
                "Vehicle No",
                "Qty (Units)",
                "Status",
              ],
              data: dispatchLogs.map((e) {
                return [
                  e['date']?.toString() ?? '',
                  e['dispatchId']?.toString() ?? '',
                  e['destination']?.toString() ?? '',
                  e['vehicle']?.toString() ?? '',
                  e['quantity']?.toString() ?? '0',
                  e['status']?.toString() ?? '',
                ];
              }).toList(),
            ),
          ],
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _pdfStatCell(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> exportPdf() async {
    try {
      final pdf = await _buildPdfDocument();
      final bytes = await pdf.save();
      final fileName =
          "warehouse_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";

      // Cache locally
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/$fileName");
        await file.writeAsBytes(bytes);
      } catch (_) {}

      // Native share/save dialog
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      debugPrint("PDF Export Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF Export Error: $e"),
          backgroundColor: const Color(0xffDC2626),
        ),
      );
    }
  }

  Future<void> printPdf() async {
    try {
      final pdf = await _buildPdfDocument();
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      debugPrint("Print Error: $e");
    }
  }

  Future<void> fetchWarehouseReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await repository.getWarehouseReport(
        startDate: fromDate.isEmpty ? null : fromDate,
        endDate: toDate.isEmpty ? null : toDate,
        branchId: branch == "All Branches" ? null : branch,
      );

      debugPrint("dispatchVolume = ${data["dispatchVolume"]}");
      debugPrint("dispatches = ${data["dispatches"]}");
      debugPrint("recentDispatches = ${data["recentDispatches"]}");

      final List dispatches =
          data["dispatches"] ?? data["recentDispatches"] ?? [];
      int parseInt(dynamic value) {
        if (value == null) return 0;
        return int.tryParse(value.toString().replaceAll(',', '')) ?? 0;
      }

      Map<String, int> dispatchByBranch = {};

      for (var item in dispatches) {
        final branch = item['destination'] ?? 'Unknown';

        final eggs = parseInt(item["total_eggs"] ?? item["quantity"]);

        dispatchByBranch.update(
          branch,
          (value) => value + eggs,
          ifAbsent: () => eggs,
        );
        print("RAW ITEM: $item");
        print("TYPE: ${item.runtimeType}");
        print("Branch: $branch | Eggs: $eggs");
      }

      print("Dispatch By Branch: $dispatchByBranch");

      final availableStock = parseInt(data["availableStock"] ?? 0);

      int totalDispatched = 0;
      int deliveredCount = 0;
      Set<String> activeDriversSet = {};

      for (var d in dispatches) {
        totalDispatched += parseInt(d["total_eggs"] ?? d["quantity"]);
        String status = d["status"]?.toString().toUpperCase() ?? "";
        if (status == "DELIVERED") {
          deliveredCount++;
        }
        if (status == "IN_TRANSIT" || status == "LOADING") {
          if (d["driver_name"] != null &&
              d["driver_name"].toString().isNotEmpty) {
            activeDriversSet.add(d["driver_name"].toString());
          }
        }
      }

      String onTimeRate = dispatches.isNotEmpty
          ? ((deliveredCount / dispatches.length) * 100).toStringAsFixed(1)
          : "100.0";

      int activeDrivers = activeDriversSet.length;

      setState(() {
        warehouseStats = [
          {
            "title": "Available Stock",
            "amount": NumberFormat.decimalPattern(
              'en_IN',
            ).format(availableStock),
            "growth": "Active Inventory",
            "icon": "warehouse",
            "color": "blue",
            "growthColor": "green",
          },
          {
            "title": "Total Dispatched (Units)",
            "amount": NumberFormat.decimalPattern(
              'en_IN',
            ).format(totalDispatched),
            "growth": "Dispatched in selection",
            "icon": "truck",
            "color": "green",
            "growthColor": "green",
          },
          {
            "title": "On-Time Delivery",
            "amount": "$onTimeRate%",
            "growth": "Based on delivered status",
            "icon": "check",
            "color": "orange",
            "growthColor": "green",
          },
          {
            "title": "Active Drivers",
            "amount": activeDrivers.toString(),
            "growth": "Currently active drivers",
            "icon": "clock",
            "color": "grey",
            "growthColor": "red",
          },
        ];

        dispatchVolume = List<Map<String, dynamic>>.from(
          data["dispatchVolume"] ?? [],
        );

        dispatchLogs = List<Map<String, dynamic>>.from(
          data["recentDispatches"],
        );

        branchDispatches = List<Map<String, dynamic>>.from(
          data["destinations"],
        );

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 8,
              //   ),

              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),

              //     border: Border.all(color: const Color(0xffE5E7EB)),
              //   ),

              //   child: const Row(
              //     children: [
              //       Text("7 Days"),
              //       SizedBox(width: 6),
              //       Icon(Icons.keyboard_arrow_down, size: 18),
              //     ],
              //   ),
              // ),
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
                  Icon(Icons.square, color: Color(0xffE5E7EB), size: 12),

                  SizedBox(width: 4),

                  Text("Requested (Units)", style: TextStyle(fontSize: 12)),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.square, color: Colors.blue, size: 12),

                  SizedBox(width: 4),

                  Text("Dispatched (Units)", style: TextStyle(fontSize: 12)),
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

              children: dispatchVolume.map((item) {
                final dispatched = (item["dispatched"] as num).toDouble();

                final maxValue = dispatchVolume
                    .map((e) => (e["dispatched"] as num).toDouble())
                    .reduce((a, b) => a > b ? a : b);

                return buildBar(
                  0,
                  (dispatched / maxValue) * 150,
                  item["day"].toString(),
                );
              }).toList(),
            ),
          ),

          // const SizedBox(height: 20),

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
          //           color: Colors.blue,
          //           fontWeight: FontWeight.w700,
          //         ),
          //       ),

          //       SizedBox(width: 10),

          //       Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget buildBranchDispatchCard() {
    debugPrint("branchDispatches = $branchDispatches");
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dispatch by Branch",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 30),

          ...branchDispatches.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item["name"].toString(),
                          style: AppTextStyles.headingText16,
                        ),
                      ),

                      Text(
                        "${NumberFormat.decimalPattern('en_IN').format(item["trays"] ?? 0)} Units",
                        style: AppTextStyles.headingText16,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: ((item["progress"] ?? 0) as num).toDouble(),
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE9EEF6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2F5BEA),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
                child: Icon(icon, color: iconColor, size: 16),
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
                    growthColor == Colors.red
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
