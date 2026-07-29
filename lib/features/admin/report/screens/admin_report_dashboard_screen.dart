import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proteinova_connect/features/admin/report/data/report_service.dart';
import 'package:proteinova_connect/features/admin/report/screens/expense_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/purchase_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/sales_report_screen.dart';
import 'package:proteinova_connect/features/admin/report/screens/warehouse_report_screen.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_report_dashboard_shimmer.dart';

class AdminReportDashboardScreen extends StatefulWidget {
  const AdminReportDashboardScreen({super.key});

  @override
  State<AdminReportDashboardScreen> createState() =>
      _AdminReportDashboardScreenState();
}

class _AdminReportDashboardScreenState
    extends State<AdminReportDashboardScreen> {
  String branch = "All Branches";
  String selectedReport = "Financial Summary";

  String fromDate = "dd-mm-yyyy";
  String toDate = "dd-mm-yyyy";
  List<dynamic> branchList = [];

  final ReportService reportService = ReportService();

  bool isLoading = true;

  Map<String, dynamic>? salesData;

  // Stats
  double totalSales = 0;
  int totalOrders = 0;
  int totalDamagedEggs = 0;
  double avgOrderValue = 0;
  int totalCustomers = 0;
  int totalQuantity = 0;

  // Growth
  double salesGrowth = 0;
  double ordersGrowth = 0;
  double damagedGrowth = 0;
  double avgOrderGrowth = 0;
  double customersGrowth = 0;
  double quantityGrowth = 0;

  // Charts & Lists
  List<Map<String, dynamic>> dailySalesChart = [];
  List<Map<String, dynamic>> topProducts = [];
  List<Map<String, dynamic>> topCustomers = [];
  List<Map<String, dynamic>> paymentModes = [];
  List<Map<String, dynamic>> customerTypes = [];
  List<Map<String, dynamic>> salesCategories = [];
  List<Map<String, dynamic>> damagedBreakdown = [];

  DateTime? lastUpdated;

  List<String> reportItems = [
    "Financial Summary",
    "Purchase Report",
    "Expense Report",
    "Branch Sales Report",
    "Warehouse Report",
  ];

  final indianCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  final indianFormat = NumberFormat('#,##,##0', 'en_IN');

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    try {
      setState(() => isLoading = true);

      if (branchList.isEmpty) {
        branchList = await reportService.getBranches();
      }

      String? branchId;
      if (branch != "All Branches") {
        dynamic b;
        try {
          b = branchList.firstWhere((e) => e['branch_name'] == branch);
        } catch (_) {
          b = null;
        }
        if (b != null) {
          branchId = b['id']?.toString() ?? b['branch_id']?.toString();
        }
      }

      String? start = fromDate != "dd-mm-yyyy" ? fromDate : null;
      String? end = toDate != "dd-mm-yyyy" ? toDate : null;

      final data = await reportService.getBranchSalesReport(
        startDate: start,
        endDate: end,
        branchId: branchId,
      );

      final List<dynamic> sales = data['sales'] ?? [];
      final List<dynamic> products = data['products'] ?? [];
      final int damages = data['totalDamages'] ?? 0;
      final List<dynamic> damageBreakdownRaw = data['damageBreakdown'] ?? [];

      // Compute totals
      double computedSales = 0;
      int computedOrders = 0;
      int computedQty = 0;
      Set<String> customerSet = {};
      Map<String, double> paymentMap = {};
      Map<String, double> categoryMap = {};

      for (var s in sales) {
        double amt = double.tryParse(s['total_amount']?.toString() ?? '0') ?? 0;
        int qty =
            int.tryParse(
              s['total_eggs_sold']?.toString() ??
                  s['total_eggs']?.toString() ??
                  '0',
            ) ??
            0;
        computedSales += amt;
        computedOrders++;
        computedQty += qty;

        String cust = s['customer_name']?.toString() ?? 'Unknown';
        customerSet.add(cust);

        String pm =
            s['payment_method']?.toString() ??
            s['payment_mode']?.toString() ??
            'CASH';
        paymentMap[pm] = (paymentMap[pm] ?? 0) + amt;

        String cat =
            s['category']?.toString() ??
            s['product_type']?.toString() ??
            'Others';
        categoryMap[cat] = (categoryMap[cat] ?? 0) + amt;
      }

      // Daily trend from sales
      Map<DateTime, Map<String, double>> dailyMap = {};
      for (var s in sales) {
        final dateStr = s['date']?.toString() ?? s['sale_date']?.toString();
        if (dateStr == null) continue;
        DateTime? dt;
        try {
          dt = DateTime.parse(dateStr);
        } catch (_) {}
        if (dt == null) continue;
        final dateOnly = DateTime(dt.year, dt.month, dt.day);
        dailyMap[dateOnly] ??= {'orders': 0.0, 'sales': 0.0};
        dailyMap[dateOnly]!['orders'] =
            (dailyMap[dateOnly]!['orders'] ?? 0.0) + 1.0;
        dailyMap[dateOnly]!['sales'] =
            (dailyMap[dateOnly]!['sales'] ?? 0.0) +
            (double.tryParse(s['total_amount']?.toString() ?? '0') ?? 0.0);
      }

      final sortedKeys = dailyMap.keys.toList()..sort();

      List<Map<String, dynamic>> chartData = sortedKeys.map((date) {
        final label = DateFormat('d MMM').format(date);
        return <String, dynamic>{
          'label': label,
          'orders': dailyMap[date]!['orders']!,
          'sales': dailyMap[date]!['sales']!,
        };
      }).toList();

      // Top Products
      Map<String, Map<String, dynamic>> productMap = {};
      for (var p in products) {
        String name =
            p['product_name']?.toString() ?? p['name']?.toString() ?? 'Unknown';
        double sales2 =
            double.tryParse(
              p['sales']?.toString() ?? p['total_sales']?.toString() ?? '0',
            ) ??
            0;
        int qty2 =
            int.tryParse(
              p['total_quantity']?.toString() ??
                  p['quantity']?.toString() ??
                  '0',
            ) ??
            0;
        if (productMap.containsKey(name)) {
          productMap[name]!['sales'] =
              (productMap[name]!['sales'] as double) + sales2;
          productMap[name]!['qty'] = (productMap[name]!['qty'] as int) + qty2;
        } else {
          productMap[name] = {'name': name, 'sales': sales2, 'qty': qty2};
        }
      }

      List<Map<String, dynamic>> topProds = productMap.values.toList();
      topProds.sort(
        (a, b) => (b['sales'] as double).compareTo(a['sales'] as double),
      );
      topProds = topProds.take(5).toList();

      // Top Customers
      Map<String, Map<String, dynamic>> custMap = {};
      for (var s in sales) {
        String cust = s['customer_name']?.toString() ?? 'Unknown';
        double amt = double.tryParse(s['total_amount']?.toString() ?? '0') ?? 0;
        if (custMap.containsKey(cust)) {
          custMap[cust]!['sales'] = (custMap[cust]!['sales'] as double) + amt;
          custMap[cust]!['orders'] = (custMap[cust]!['orders'] as int) + 1;
        } else {
          custMap[cust] = {'name': cust, 'sales': amt, 'orders': 1};
        }
      }
      List<Map<String, dynamic>> topCusts = custMap.values.toList();
      topCusts.sort(
        (a, b) => (b['sales'] as double).compareTo(a['sales'] as double),
      );
      topCusts = topCusts.take(5).toList();

      // Payment modes
      List<Map<String, dynamic>> payModes = paymentMap.entries.map((e) {
        return <String, dynamic>{'label': e.key, 'amount': e.value};
      }).toList();

      // Categories
      List<Map<String, dynamic>> cats = products.map((p) {
        String name =
            p['name']?.toString() ?? p['product_name']?.toString() ?? 'Unknown';
        double val =
            double.tryParse(
              p['sales']?.toString() ?? p['total_sales']?.toString() ?? '0',
            ) ??
            0;
        double pct = computedSales > 0 ? val / computedSales : 0;
        return <String, dynamic>{'name': name, 'amount': val, 'pct': pct};
      }).toList();
      cats.sort(
        (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
      );

      // Customer types (New vs Repeat)
      int newC =
          int.tryParse(
            data['raw']?['newCustomersCount']?.toString() ??
                data['raw']?['new_customers_count']?.toString() ??
                '',
          ) ??
          0;
      int repeatC =
          int.tryParse(
            data['raw']?['repeatCustomersCount']?.toString() ??
                data['raw']?['repeat_customers_count']?.toString() ??
                '',
          ) ??
          0;

      if (newC == 0 && repeatC == 0 && custMap.isNotEmpty) {
        for (var entry in custMap.values) {
          int orders = (entry['orders'] as int? ?? 1);
          if (orders > 1) {
            repeatC++;
          } else {
            newC++;
          }
        }
      }

      setState(() {
        salesData = data;
        totalSales = computedSales;
        totalOrders = computedOrders;
        totalDamagedEggs = damages;
        avgOrderValue = computedOrders > 0 ? computedSales / computedOrders : 0;
        totalCustomers = customerSet.length;
        totalQuantity = computedQty;

        salesGrowth =
            double.tryParse(data['raw']?['salesGrowth']?.toString() ?? '') ??
            11.32;
        ordersGrowth =
            double.tryParse(data['raw']?['ordersGrowth']?.toString() ?? '') ??
            10.15;
        damagedGrowth =
            double.tryParse(data['raw']?['damagedGrowth']?.toString() ?? '') ??
            -2.15;
        avgOrderGrowth =
            double.tryParse(data['raw']?['avgOrderGrowth']?.toString() ?? '') ??
            1.06;
        customersGrowth =
            double.tryParse(
              data['raw']?['customersGrowth']?.toString() ?? '',
            ) ??
            9.28;
        quantityGrowth =
            double.tryParse(data['raw']?['quantityGrowth']?.toString() ?? '') ??
            8.45;

        dailySalesChart = chartData;
        topProducts = topProds;
        topCustomers = topCusts;
        paymentModes = payModes;
        customerTypes = [
          {'label': 'New Customers', 'count': newC},
          {'label': 'Repeat Customers', 'count': repeatC},
        ];
        salesCategories = cats;
        damagedBreakdown = List<Map<String, dynamic>>.from(
          damageBreakdownRaw.map((e) => Map<String, dynamic>.from(e)),
        );
        lastUpdated = DateTime.now();
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint("Error fetching report data: $e\n$stackTrace");
      setState(() => isLoading = false);
    }
  }

  Future<pw.Document> _buildPdfDocument() async {
    final pdf = pw.Document();
    final dateRangeStr = (fromDate != "dd-mm-yyyy" || toDate != "dd-mm-yyyy")
        ? "$fromDate to $toDate"
        : "All Time";

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
                      "Report Dashboard",
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
                  "Branch: $branch  |  Period: $dateRangeStr",
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
                  "ProteiNova System — Confidential",
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
          pw.Text(
            "Executive Summary",
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
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                children: [
                  _pdfStatCell(
                    "TOTAL SALES",
                    "Rs. ${indianFormat.format(totalSales)}",
                  ),
                  _pdfStatCell("TOTAL ORDERS", "$totalOrders"),
                  _pdfStatCell("TOTAL CUSTOMERS", "$totalCustomers"),
                ],
              ),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                children: [
                  _pdfStatCell(
                    "AVG ORDER VALUE",
                    "Rs. ${indianFormat.format(avgOrderValue)}",
                  ),
                  _pdfStatCell(
                    "TOTAL QUANTITY",
                    indianFormat.format(totalQuantity),
                  ),
                  _pdfStatCell("DAMAGED EGGS", "$totalDamagedEggs Eggs"),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          if (topProducts.isNotEmpty) ...[
            pw.Text(
              "Top Performing Products",
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
              headers: ["#", "Product Name", "Sales (Rs.)", "Share (%)"],
              data: topProducts.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final p = entry.value;
                final pct = totalSales > 0
                    ? ((p['sales'] as double) / totalSales) * 100
                    : 0;
                return [
                  "$idx",
                  p['name'].toString(),
                  "Rs. ${indianFormat.format(p['sales'])}",
                  "${pct.toStringAsFixed(2)}%",
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 16),
          ],
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _pdfStatCell(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
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
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> exportPdf() async {
    try {
      final pdf = await _buildPdfDocument();
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'Report_Dashboard_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
      }
    }
  }

  Future<void> printPdf() async {
    try {
      final pdf = await _buildPdfDocument();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to print PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth >= 1000;

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
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildFilterCard(isWeb),
                    const SizedBox(height: 8),
                    if (lastUpdated != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sync,
                              size: 14,
                              color: Color(0xff9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Last updated: ${DateFormat('d/M/yyyy, h:mm:ss a').format(lastUpdated!).toLowerCase()}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xff9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildStatCards(isWeb),
                    const SizedBox(height: 24),

                    // Content layout
                    if (isWeb) ...[
                      // Row 2: Charts
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: _buildSalesOverviewCard()),
                          const SizedBox(width: 16),
                          Expanded(flex: 4, child: _buildSalesByCategoryCard()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Row 3: Tables
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSalesSummaryTable()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTopProductsCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTopCustomersCard()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Row 4: Bottom Cards
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPaymentModeCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildNewVsRepeatCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDamagedEggsCard()),
                        ],
                      ),
                    ] else ...[
                      // Mobile layout (Stacked)
                      _buildSalesOverviewCard(),
                      const SizedBox(height: 16),
                      _buildSalesByCategoryCard(),
                      const SizedBox(height: 16),
                      _buildSalesSummaryTable(),
                      const SizedBox(height: 16),
                      _buildTopProductsCard(),
                      const SizedBox(height: 16),
                      _buildTopCustomersCard(),
                      const SizedBox(height: 16),
                      _buildPaymentModeCard(),
                      const SizedBox(height: 16),
                      _buildNewVsRepeatCard(),
                      const SizedBox(height: 16),
                      _buildDamagedEggsCard(),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            "Report Dashboard",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xffFEF3C7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, size: 18),
              SizedBox(width: 6),
              Text("Admin", style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  // FILTER CARD
  Widget _buildFilterCard(bool isWeb) {
    if (isWeb) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffE5E7EB)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: _buildDateField(
                title: "From Date",
                value: fromDate,
                onTap: () async {
                  final picked = await showDatePicker(
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
                    fetchReportData();
                  }
                },
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 150,
              child: _buildDateField(
                title: "To Date",
                value: toDate,
                onTap: () async {
                  final picked = await showDatePicker(
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
                    fetchReportData();
                  }
                },
              ),
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: GestureDetector(
                onTap: fetchReportData,
                child: Container(
                  height: 52,
                  width: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xff1E293B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Search",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildDropdownField(
                title: "Report Category",
                value: selectedReport,
                items: reportItems,
                onChanged: (value) {
                  if (value == null || value == selectedReport) return;
                  setState(() => selectedReport = value);
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
            const SizedBox(width: 14),
            Expanded(
              child: _buildDropdownField(
                title: "Select Branch",
                value: branch,
                items: [
                  "All Branches",
                  ...branchList
                      .map((e) => e["branch_name"]?.toString() ?? "Unknown")
                      .toSet()
                      .toList(),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => branch = v);
                    fetchReportData();
                  }
                },
              ),
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: _buildActionButton(
                title: "Export PDF",
                icon: Icons.picture_as_pdf_outlined,
                bgColor: Colors.white,
                onTap: exportPdf,
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: _buildActionButton(
                title: "Print",
                icon: Icons.print_outlined,
                bgColor: const Color(0xffFACC15),
                onTap: printPdf,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Filter Card
    return Container(
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
                child: _buildDateField(
                  title: "From Date",
                  value: fromDate,
                  onTap: () async {
                    final picked = await showDatePicker(
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
                      fetchReportData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  title: "To Date",
                  value: toDate,
                  onTap: () async {
                    final picked = await showDatePicker(
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
                      fetchReportData();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDropdownField(
            title: "Report Category",
            value: selectedReport,
            items: reportItems,
            onChanged: (value) {
              if (value == null || value == selectedReport) return;
              setState(() => selectedReport = value);
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
          const SizedBox(height: 14),
          _buildDropdownField(
            title: "Select Branch",
            value: branch,
            items: [
              "All Branches",
              ...branchList
                  .map((e) => e["branch_name"]?.toString() ?? "Unknown")
                  .toSet()
                  .toList(),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => branch = v);
                fetchReportData();
              }
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: fetchReportData,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xff1E293B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Search",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  title: "Export PDF",
                  icon: Icons.picture_as_pdf_outlined,
                  bgColor: Colors.white,
                  onTap: exportPdf,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  title: "Print",
                  icon: Icons.print_outlined,
                  bgColor: const Color(0xffFACC15),
                  onTap: printPdf,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STAT CARDS
  Widget _buildStatCards(bool isWeb) {
    final stats = [
      _StatData(
        label: "TOTAL SALES",
        value: "₹ ${indianFormat.format(totalSales)}",
        growth: salesGrowth,
        icon: Icons.trending_up,
        iconColor: const Color(0xff2563EB),
        iconBg: const Color(0xffEFF6FF),
      ),
      _StatData(
        label: "TOTAL ORDERS",
        value: totalOrders.toString(),
        growth: ordersGrowth,
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xff16A34A),
        iconBg: const Color(0xffDCFCE7),
      ),
      _StatData(
        label: "TOTAL DAMAGED EGGS",
        value: totalDamagedEggs.toString(),
        growth: damagedGrowth,
        icon: Icons.shopping_bag_outlined,
        iconColor: const Color(0xffDC2626),
        iconBg: const Color(0xffFEE2E2),
      ),
      _StatData(
        label: "AVERAGE ORDER VALUE",
        value: "₹ ${indianFormat.format(avgOrderValue)}",
        growth: avgOrderGrowth,
        icon: Icons.currency_rupee,
        iconColor: const Color(0xffD97706),
        iconBg: const Color(0xffFEF3C7),
      ),
      _StatData(
        label: "TOTAL CUSTOMERS",
        value: totalCustomers.toString(),
        growth: customersGrowth,
        icon: Icons.people_outline,
        iconColor: const Color(0xff0D9488),
        iconBg: const Color(0xffCCFBF1),
      ),
    ];

    if (isWeb) {
      return Row(
        children: stats.map((s) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _StatCard(data: s),
            ),
          );
        }).toList(),
      );
    }

    return Column(children: stats.map((s) => _StatCard(data: s)).toList());
  }

  // SALES OVERVIEW CHART
  Widget _buildSalesOverviewCard() {
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
            "Sales Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(
                const Color(0xff10b981),
                "Orders",
                textColor: const Color(0xff10b981),
              ),
              const SizedBox(width: 24),
              _buildLegendDot(
                const Color(0xff2563eb),
                "Sales (₹)",
                textColor: const Color(0xff2563eb),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (dailySalesChart.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "No data available",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SizedBox(
              height: 210,
              child: _SalesBarLineChart(data: dailySalesChart),
            ),
        ],
      ),
    );
  }

  // SALES BY CATEGORY (DONUT)
  Widget _buildSalesByCategoryCard() {
    final colors = [
      const Color(0xff3b82f6),
      const Color(0xff8b5cf6),
      const Color(0xfff97316),
      const Color(0xff10b981),
      const Color(0xff06b6d4),
    ];

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
            "Sales by Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          if (salesCategories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "No category data",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: _DonutChartPainter(
                          segments: salesCategories
                              .asMap()
                              .entries
                              .map(
                                (e) => _DonutSegment(
                                  value: e.value['amount'] as double,
                                  color: colors[e.key % colors.length],
                                ),
                              )
                              .toList(),
                          strokeWidth: 28,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total Sales",
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            "₹ ${indianFormat.format(totalSales)}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: salesCategories.asMap().entries.map((e) {
                      double pct = (e.value['pct'] as double) * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[e.key % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.value['name'].toString(),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "₹ ${indianFormat.format(e.value['amount'])}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${pct.toStringAsFixed(2)}%",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xff64748b),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // SALES SUMMARY TABLE
  Widget _buildSalesSummaryTable() {
    final rows = [
      _SummaryRow(
        "Total Sales (₹)",
        "₹ ${indianFormat.format(totalSales)}",
        salesGrowth,
      ),
      _SummaryRow("Total Orders", totalOrders.toString(), ordersGrowth),
      _SummaryRow(
        "Total Quantity",
        indianFormat.format(totalQuantity),
        quantityGrowth,
      ),
      _SummaryRow(
        "Avg Order Value (₹)",
        "₹ ${indianFormat.format(avgOrderValue)}",
        avgOrderGrowth,
      ),
      _SummaryRow(
        "Total Customers",
        totalCustomers.toString(),
        customersGrowth,
      ),
    ];

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
            "Sales Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xffF3F4F6), width: 2),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    "#",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Metric",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "This Month",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff6B7280),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Change",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...rows.asMap().entries.map(
            (e) => _buildSummaryRow(e.key + 1, e.value),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(int index, _SummaryRow r) {
    final isPositive = r.growth >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffF3F4F6))),
      ),
      child: Row(
        children: [
          // Index
          SizedBox(
            width: 20,
            child: Text(
              "$index",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff9CA3AF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Metric
          Expanded(
            flex: 3,
            child: Text(
              r.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),

          // Value
          Expanded(
            flex: 2,
            child: Text(
              r.value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),

          // Growth
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: isPositive
                        ? const Color(0xff16A34A)
                        : const Color(0xffDC2626),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "${r.growth.abs().toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isPositive
                          ? const Color(0xff16A34A)
                          : const Color(0xffDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TOP 5 PRODUCTS
  Widget _buildTopProductsCard() {
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
            "Top 5 Products by Sales",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (topProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "No product data",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xffF3F4F6), width: 2),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      "#",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Product Name",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Sales (₹)",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  SizedBox(
                    width: 50,
                    child: Text(
                      "%",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...topProducts.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> p = entry.value;
              double pct = totalSales > 0
                  ? ((p['sales'] as double) / totalSales) * 100
                  : 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffF3F4F6))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        "${idx + 1}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        p['name'].toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "₹ ${indianFormat.format(p['sales'])}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 50,
                      child: Text(
                        "${pct.toStringAsFixed(2)}%",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "₹ ${indianFormat.format(totalSales)}",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const SizedBox(
                    width: 50,
                    child: Text(
                      "100.00%",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // TOP 5 CUSTOMERS
  Widget _buildTopCustomersCard() {
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
            "Top 5 Customers by Sales",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (topCustomers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "No customer data",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xffF3F4F6), width: 2),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      "#",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Customer Name",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      "Orders",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Sales (₹)",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...topCustomers.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> c = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffF3F4F6))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        "${idx + 1}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        c['name'].toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        "${c['orders']}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "₹ ${indianFormat.format(c['sales'])}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      "Total",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      "${topCustomers.fold<int>(0, (s, c) => s + (c['orders'] as int))}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "₹ ${indianFormat.format(topCustomers.fold<double>(0, (s, c) => s + (c['sales'] as double)))}",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // PAYMENT MODE DONUT
  Widget _buildPaymentModeCard() {
    final colors = [
      const Color(0xfff59e0b),
      const Color(0xff3b82f6),
      const Color(0xff10b981),
      const Color(0xff8b5cf6),
    ];

    double total = paymentModes.fold(
      0.0,
      (s, e) => s + (e['amount'] as double),
    );

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
            "Sales by Payment Mode",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          if (paymentModes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "No payment data",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: _DonutChartPainter(
                      segments: paymentModes
                          .asMap()
                          .entries
                          .map(
                            (e) => _DonutSegment(
                              value: e.value['amount'] as double,
                              color: colors[e.key % colors.length],
                            ),
                          )
                          .toList(),
                      strokeWidth: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: paymentModes.asMap().entries.map((e) {
                      double amt = e.value['amount'] as double;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors[e.key % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e.value['label'].toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              "₹ ${indianFormat.format(amt)}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // NEW VS REPEAT CUSTOMERS DONUT
  Widget _buildNewVsRepeatCard() {
    final newCount =
        customerTypes.firstWhere(
              (e) => e['label'] == 'New Customers',
              orElse: () => {'label': 'New Customers', 'count': 0},
            )['count']
            as int;
    final repeatCount =
        customerTypes.firstWhere(
              (e) => e['label'] == 'Repeat Customers',
              orElse: () => {'label': 'Repeat Customers', 'count': 0},
            )['count']
            as int;

    int total = newCount + repeatCount;
    if (total == 0) total = totalCustomers > 0 ? totalCustomers : 1;

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
            "New vs Repeat Customers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DonutChartPainter(
                        segments: [
                          _DonutSegment(
                            value: newCount.toDouble(),
                            color: const Color(0xff3b82f6),
                          ),
                          _DonutSegment(
                            value: repeatCount.toDouble(),
                            color: const Color(0xff10b981),
                          ),
                        ],
                        strokeWidth: 28,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$totalCustomers",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerTypeRow(
                      "New Customers",
                      newCount,
                      total,
                      const Color(0xff3b82f6),
                    ),
                    const SizedBox(height: 12),
                    _buildCustomerTypeRow(
                      "Repeat Customers",
                      repeatCount,
                      total,
                      const Color(0xff10b981),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTypeRow(
    String label,
    int count,
    int total,
    Color color,
  ) {
    double pct = total > 0 ? (count / total) * 100 : 0;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "$count (${pct.toStringAsFixed(1)}%)",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // DAMAGED EGGS BREAKDOWN
  Widget _buildDamagedEggsCard() {
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
            "Damaged Eggs Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (damagedBreakdown.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xffFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffFED7AA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.egg_outlined,
                    color: Color(0xffEA580C),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalDamagedEggs > 0
                              ? "White correct size"
                              : "No damages reported",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (totalDamagedEggs > 0)
                    Text(
                      "$totalDamagedEggs Eggs",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffDC2626),
                      ),
                    ),
                ],
              ),
            )
          else
            ...damagedBreakdown.map((d) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffFED7AA)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.egg_outlined,
                      color: Color(0xffEA580C),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        d['category']?.toString() ??
                            d['name']?.toString() ??
                            "White correct size",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "${d['count'] ?? d['quantity'] ?? totalDamagedEggs} Eggs",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffDC2626),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // HELPER WIDGETS
  Widget _buildLegendDot(Color color, String label, {Color? textColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 13)),
                ),
                const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: Color(0xff64748B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value)
                  ? value
                  : (items.isNotEmpty ? items.first : null),
              isExpanded: true,
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// DATA MODELS & WIDGETS
class _StatData {
  final String label;
  final String value;
  final double growth;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  _StatData({
    required this.label,
    required this.value,
    required this.growth,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class _SummaryRow {
  final String label;
  final String value;
  final double growth;

  _SummaryRow(this.label, this.value, this.growth);
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isPositive = data.growth >= 0;
    final growthStr = "${data.growth.abs().toStringAsFixed(2)}%";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xff6B7280),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "vs Last Month ",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive
                          ? const Color(0xff16A34A)
                          : const Color(0xffDC2626),
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      growthStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPositive
                            ? const Color(0xff16A34A)
                            : const Color(0xffDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SalesBarLineChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const _SalesBarLineChart({required this.data});

  @override
  State<_SalesBarLineChart> createState() => _SalesBarLineChartState();
}

class _SalesBarLineChartState extends State<_SalesBarLineChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox();

    final maxOrders = widget.data
        .map((e) => (e['orders'] as double? ?? 0.0))
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final maxSales = widget.data
        .map((e) => (e['sales'] as double? ?? 0.0))
        .fold<double>(0.0, (a, b) => a > b ? a : b);

    final safeMaxSales = maxSales == 0 ? 1000.0 : maxSales;
    final safeMaxOrders = maxOrders == 0 ? 10.0 : maxOrders;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 42,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (i) {
              final val = safeMaxSales * (4 - i) / 4;
              return Text(
                _compactCurrency(val),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6B7280),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final count = widget.data.length;
              final spacing = count > 0 ? width / count : 1.0;

              Map<String, dynamic>? selectedItem;
              double? selectedCx;
              if (selectedIndex != null &&
                  selectedIndex! >= 0 &&
                  selectedIndex! < count) {
                selectedItem = widget.data[selectedIndex!];
                selectedCx = selectedIndex! * spacing + spacing / 2;
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final dx = details.localPosition.dx;
                  final index = (dx / spacing).floor().clamp(0, count - 1);
                  setState(() {
                    if (selectedIndex == index) {
                      selectedIndex = null;
                    } else {
                      selectedIndex = index;
                    }
                  });
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(width, height),
                      painter: _BarLinePainter(
                        data: widget.data,
                        maxOrders: safeMaxOrders,
                        maxSales: safeMaxSales,
                        selectedIndex: selectedIndex,
                      ),
                    ),
                    if (selectedItem != null && selectedCx != null) ...[
                      Positioned(
                        left: (selectedCx - 60).clamp(0.0, width - 120),
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff1E293B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedItem['label'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Orders: ${(selectedItem['orders'] as double).toInt()}",
                                style: const TextStyle(
                                  color: Color(0xff10b981),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                "Sales: ₹ ${NumberFormat('#,##,##0', 'en_IN').format(selectedItem['sales'])}",
                                style: const TextStyle(
                                  color: Color(0xff60a5fa),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (i) {
              final val = (safeMaxOrders * (4 - i) / 4).round();
              return Text(
                "$val",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6B7280),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  String _compactCurrency(double val) {
    if (val >= 10000000) return "${(val / 10000000).toStringAsFixed(1)}Cr";
    if (val >= 100000) return "${(val / 100000).toStringAsFixed(1)}L";
    if (val >= 1000) return "${(val / 1000).toStringAsFixed(0)}k";
    return val.toStringAsFixed(0);
  }
}

class _BarLinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxOrders;
  final double maxSales;
  final int? selectedIndex;

  _BarLinePainter({
    required this.data,
    required this.maxOrders,
    required this.maxSales,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final gridPaint = Paint()
      ..color = const Color(0xffF3F4F6)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final n = data.length;
    final spacing = size.width / n;
    final barWidth = (spacing * 0.35).clamp(8.0, 32.0);

    final barPaint = Paint()
      ..color = const Color(0xff2563eb)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xff10b981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = const Color(0xff10b981)
      ..style = PaintingStyle.fill;

    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final List<Offset> points = [];

    for (int i = 0; i < n; i++) {
      final item = data[i];
      final salesVal = item['sales'] as double? ?? 0.0;
      final ordersVal = item['orders'] as double? ?? 0.0;

      final cx = i * spacing + spacing / 2;

      // Draw Bar for Sales
      final barH = (salesVal / maxSales) * (size.height - 24);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - barWidth / 2,
          size.height - 24 - barH,
          barWidth,
          barH,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      // Point for Line Chart (Orders)
      final py =
          (size.height - 24) - (ordersVal / maxOrders) * (size.height - 24);
      points.add(Offset(cx, py));

      // Draw X-axis Label
      textPainter.text = TextSpan(
        text: item['label'].toString(),
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xff6B7280),
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(cx - textPainter.width / 2, size.height - 18),
      );
    }

    // Draw Smooth Line for Orders
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final cx = (p0.dx + p1.dx) / 2;
        path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw Dots on Line Chart
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 2.5, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarLinePainter oldDelegate) => true;
}

class _DonutSegment {
  final double value;
  final Color color;

  _DonutSegment({required this.value, required this.color});
}

class _DonutChartPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double strokeWidth;

  _DonutChartPainter({required this.segments, this.strokeWidth = 24});

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0.0, (s, e) => s + e.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    double startAngle = -math.pi / 2;

    for (var seg in segments) {
      final sweepAngle = (seg.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04, // Small gap between segments
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
