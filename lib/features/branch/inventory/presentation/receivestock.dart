import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Receivestock extends StatefulWidget {
  final dynamic dispatchid;
  const Receivestock({super.key, this.dispatchid});

  @override
  State<Receivestock> createState() => _ReceivestockState();
}

class _ReceivestockState extends State<Receivestock> {
  bool isLoading = true;
  bool isSubmitting = false;
  int branchId = 1;

  Map<String, dynamic> receiveInfo = {};
  Map<String, dynamic> summary = {};
  List<dynamic> receivedItems = [];
  Map<String, int> damagedTrays = {}; // category/product -> damaged eggs count
  final Map<String, TextEditingController> _damagedControllers = {};
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  @override
  void dispose() {
    for (var controller in _damagedControllers.values) {
      controller.dispose();
    }
    notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        branchId = prefs.getInt("branch_id") ?? 1;
      });
      fetchReceiveDetails();
    }
  }

  Future<void> fetchReceiveDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/branch/incoming-stock/$branchId/dispatch/${widget.dispatchid}",
        ),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            receiveInfo = data["receive_info"] ?? {};
            summary = data["summary"] ?? {};
            receivedItems = data["received_items"] ?? [];
            isLoading = false;
          });

          // Setup Controllers and listeners
          for (var item in receivedItems) {
            final String product = item["product"] ?? "";
            final int maxEggs = item["eggs"] ?? 0;

            if (!_damagedControllers.containsKey(product)) {
              final controller = TextEditingController(text: "0");
              _damagedControllers[product] = controller;
              damagedTrays[product] = 0;

              controller.addListener(() {
                final val = int.tryParse(controller.text) ?? 0;
                if (val < 0) {
                  controller.text = "0";
                  controller.selection = const TextSelection.collapsed(
                    offset: 1,
                  );
                } else if (val > maxEggs) {
                  controller.text = maxEggs.toString();
                  controller.selection = TextSelection.collapsed(
                    offset: maxEggs.toString().length,
                  );
                }
                if (mounted) {
                  setState(() {
                    damagedTrays[product] = int.tryParse(controller.text) ?? 0;
                  });
                }
              });
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to fetch details: ${response.statusCode}"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching details: $e")));
      }
    }
  }

  Future<void> handleArrival() async {
    try {
      final response = await http.put(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/branch/incoming-stock/$branchId/dispatch/${widget.dispatchid}/arrival",
        ),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Arrival marked successfully!")),
          );
        }
        fetchReceiveDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to mark arrival: ${response.statusCode}"),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error marking arrival: $e")));
      }
    }
  }

  Future<void> handleConfirmReceive() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      if (receivedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("CRITICAL ERROR: Receive data is missing or empty!"),
          ),
        );
        setState(() {
          isSubmitting = false;
        });
        return;
      }

      final items = receivedItems.map((item) {
        final String product = item["product"] ?? "";
        final int damagedEggs = damagedTrays[product] ?? 0;

        return {
          "egg_category_grade": product,
          "damaged_eggs": damagedEggs,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/branch/incoming-stock/$branchId/dispatch/${widget.dispatchid}/receive",
        ),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "dispatch_id": widget.dispatchid.toString(),
          "items": items,
          "notes": notesController.text,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resData["message"] ?? "Stock received successfully!",
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final resData = jsonDecode(response.body);
        final errorMsg = resData["error"] ?? "Failed to confirm receive";
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("SERVER ERROR: $errorMsg")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error confirming receive: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  String formatLocalDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return "N/A";
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  String formatNumber(dynamic value) {
    if (value == null) return "0";
    final number = num.tryParse(value.toString()) ?? 0;
    return NumberFormat('#,##,###').format(number);
  }

  String _numberToWordsINR(double number) {
    if (number <= 0) return "INR Zero Only";
    final int amount = number.floor();
    final units = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
      "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"
    ];
    final tens = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];

    String convertLessThanThousand(int n) {
      if (n == 0) return "";
      if (n < 20) return units[n];
      if (n < 100) return "${tens[n ~/ 10]} ${units[n % 10]}".trim();
      return "${units[n ~/ 100]} Hundred ${convertLessThanThousand(n % 100)}".trim();
    }

    String convert(int n) {
      if (n == 0) return "Zero";
      String res = "";
      if (n >= 10000000) {
        res += "${convert(n ~/ 10000000)} Crore ";
        n %= 10000000;
      }
      if (n >= 100000) {
        res += "${convert(n ~/ 100000)} Lakh ";
        n %= 100000;
      }
      if (n >= 1000) {
        res += "${convert(n ~/ 1000)} Thousand ";
        n %= 1000;
      }
      if (n > 0) {
        res += convertLessThanThousand(n);
      }
      return res.trim();
    }

    return "INR ${convert(amount)} Only";
  }

  pw.Widget _buildPdfGridRow(String label1, String val1, String label2, String val2) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(3),
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 0.5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(label1, style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey800)),
                  if (val1.isNotEmpty)
                    pw.Text(val1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7)),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(label2, style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey800)),
                  if (val2.isNotEmpty)
                    pw.Text(val2, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTableCell(String text, {bool isHeader = false, bool isBold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 7 : 6.5,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _handleDownloadBill() async {
    try {
      final logoBytes = await rootBundle.load('assets/Logo@3x.png');
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final ttfFont = pw.Font.ttf(fontData);
      final boldFontData = await rootBundle.load("assets/fonts/NotoSans-Bold.ttf");
      final ttfBoldFont = pw.Font.ttf(boldFontData);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: ttfFont,
          bold: ttfBoldFont,
        ),
      );

      final String invoiceNo = "RC/${receiveInfo["receive_no"] ?? widget.dispatchid}/${DateTime.now().year}";
      final String datedStr = DateFormat('dd MMM yyyy').format(DateTime.now());
      final String branchName = receiveInfo["branch_name"] ?? receiveInfo["from_supplier"] ?? "Branch Office";
      final String driverName = receiveInfo["driver_name"] ?? "N/A";
      final String vehicleNumber = receiveInfo["vehicle_number"] ?? "N/A";

      double grandTotal = 0.0;
      final List<List<String>> tableData = [];

      for (int i = 0; i < receivedItems.length; i++) {
        final item = receivedItems[i];
        final String prodName = item["product"]?.toString() ?? "";
        final num eggsCount = item["eggs"] ?? 0;
        final num pricePerEgg = item["price_per_egg"] ?? 5.38;
        final double lineTotal = (eggsCount * pricePerEgg).toDouble();
        grandTotal += lineTotal;

        tableData.add([
          "${i + 1}",
          prodName,
          "0407",
          "$eggsCount Nos",
          pricePerEgg.toStringAsFixed(2),
          "Nos",
          lineTotal.toStringAsFixed(2),
        ]);
      }

      final num plasticTrays = summary["plastic_trays"] ?? 0;
      if (plasticTrays > 0) {
        tableData.add([
          "${tableData.length + 1}",
          "Empty Plastic Trays",
          "-",
          "$plasticTrays Nos",
          "0.00",
          "Nos",
          "0.00",
        ]);
      }

      final num paperTrays = summary["paper_trays"] ?? 0;
      if (paperTrays > 0) {
        tableData.add([
          "${tableData.length + 1}",
          "Empty Paper Trays",
          "-",
          "$paperTrays Nos",
          "0.00",
          "Nos",
          "0.00",
        ]);
      }

      final String amountWords = _numberToWordsINR(grandTotal);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // 1. TOP HEADER BAR
                  pw.Container(
                    color: PdfColor.fromHex("#6b95ca"),
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      "Invoice",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13,
                        color: PdfColors.black,
                      ),
                    ),
                  ),

                  // 2. MASTER TOP GRID
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // LEFT COLUMN (50%)
                        pw.Expanded(
                          flex: 5,
                          child: pw.Container(
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                                  ),
                                  child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 45,
                                        height: 45,
                                        color: PdfColor.fromHex("#ffcc00"),
                                        padding: const pw.EdgeInsets.all(3),
                                        child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                                      ),
                                      pw.SizedBox(width: 6),
                                      pw.Expanded(
                                        child: pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text("PROTEINOVA FOOD PRODUCTS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                                            pw.Text("PRIVATE LIMITED", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                                            pw.SizedBox(height: 2),
                                            pw.Text("141/40C, KURINJI TOWER, SALEM ROAD, NAMAKKAL", style: const pw.TextStyle(fontSize: 6.5)),
                                            pw.Text("GSTIN/UIN 33AAQCP9601H1Z7", style: const pw.TextStyle(fontSize: 6.5)),
                                            pw.Text("TAMILNADU 637001", style: const pw.TextStyle(fontSize: 6.5)),
                                            pw.Text("Contact Details: 9787896996", style: const pw.TextStyle(fontSize: 6.5)),
                                            pw.Text("e-Mail:proteinovafoods@gmail.com", style: const pw.TextStyle(fontSize: 6.5)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  decoration: const pw.BoxDecoration(
                                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                                  ),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text("Consignee (Ship to)", style: pw.TextStyle(decoration: pw.TextDecoration.underline, fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(branchName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                                      pw.Text("Contact: $driverName", style: const pw.TextStyle(fontSize: 6.5)),
                                      pw.Text("State Name : TAMILNADU, Code : 33", style: const pw.TextStyle(fontSize: 6.5)),
                                    ],
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text("Buyer (Bill to)", style: pw.TextStyle(decoration: pw.TextDecoration.underline, fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(branchName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                                      pw.Text("Contact: $driverName", style: const pw.TextStyle(fontSize: 6.5)),
                                      pw.Text("State Name : TAMILNADU, Code : 33", style: const pw.TextStyle(fontSize: 6.5)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // RIGHT COLUMN (50%)
                        pw.Expanded(
                          flex: 5,
                          child: pw.Column(
                            children: [
                              _buildPdfGridRow("Invoice No.", invoiceNo, "Dated", datedStr),
                              _buildPdfGridRow("Delivery Note", "", "Mode/Terms of Payment", "Internal Transfer"),
                              _buildPdfGridRow("Reference No. & Date.", "", "Other References", ""),
                              _buildPdfGridRow("Buyer's Order No.", "", "Dated", ""),
                              _buildPdfGridRow("Dispatch Doc No.", "", "Delivery Note Date", ""),
                              _buildPdfGridRow("Dispatched through", "", "Destination", branchName),
                              _buildPdfGridRow("Bill of Lading/LR-RR No.", "", "Motor Vehicle No.", vehicleNumber),
                              pw.Container(
                                width: double.infinity,
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Terms of Delivery", style: const pw.TextStyle(fontSize: 6.5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. GOODS TABLE
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                    columnWidths: const {
                      0: pw.FixedColumnWidth(26),
                      1: pw.FlexColumnWidth(3),
                      2: pw.FixedColumnWidth(40),
                      3: pw.FixedColumnWidth(50),
                      4: pw.FixedColumnWidth(40),
                      5: pw.FixedColumnWidth(26),
                      6: pw.FixedColumnWidth(55),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex("#fce8b3")),
                        children: [
                          _pdfTableCell("Sl. No.", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("Description of Goods", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("HSN/SAC", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("Quantity", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("Rate", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("per", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("Amount", isHeader: true, align: pw.TextAlign.center),
                        ],
                      ),
                      ...tableData.map((row) => pw.TableRow(
                        children: [
                          _pdfTableCell(row[0], align: pw.TextAlign.center),
                          _pdfTableCell(row[1], align: pw.TextAlign.left, isBold: true),
                          _pdfTableCell(row[2], align: pw.TextAlign.center),
                          _pdfTableCell(row[3], align: pw.TextAlign.right, isBold: true),
                          _pdfTableCell(row[4], align: pw.TextAlign.right),
                          _pdfTableCell(row[5], align: pw.TextAlign.center),
                          _pdfTableCell(row[6], align: pw.TextAlign.right, isBold: true),
                        ],
                      )),
                      pw.TableRow(
                        children: [
                          _pdfTableCell(""),
                          _pdfTableCell("Total", align: pw.TextAlign.right, isBold: true),
                          _pdfTableCell(""),
                          _pdfTableCell("${summary["total_eggs"] ?? 0} Nos", align: pw.TextAlign.right, isBold: true),
                          _pdfTableCell(""),
                          _pdfTableCell(""),
                          _pdfTableCell("₹ ${grandTotal.toStringAsFixed(2)}", align: pw.TextAlign.right, isBold: true),
                        ],
                      ),
                    ],
                  ),

                  // 4. AMOUNT IN WORDS
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Amount Chargeable (in words)", style: const pw.TextStyle(fontSize: 6.5)),
                        pw.SizedBox(height: 2),
                        pw.Text(amountWords, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                      ],
                    ),
                  ),

                  // 5. TAX TABLE
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(2),
                      2: pw.FlexColumnWidth(1),
                      3: pw.FlexColumnWidth(1),
                      4: pw.FlexColumnWidth(1),
                      5: pw.FlexColumnWidth(1),
                      6: pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex("#fce8b3")),
                        children: [
                          _pdfTableCell("HSN/SAC", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("Taxable", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("CGST Rate", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("CGST Amount", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("SGST Rate", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("SGST Amount", isHeader: true, align: pw.TextAlign.center),
                          _pdfTableCell("Total Tax Amount", isHeader: true, align: pw.TextAlign.center),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _pdfTableCell("HSN 0407", align: pw.TextAlign.center),
                          _pdfTableCell(grandTotal.toStringAsFixed(2), align: pw.TextAlign.right),
                          _pdfTableCell("0", align: pw.TextAlign.center),
                          _pdfTableCell("0.00", align: pw.TextAlign.right),
                          _pdfTableCell("0", align: pw.TextAlign.center),
                          _pdfTableCell("0.00", align: pw.TextAlign.right),
                          _pdfTableCell("0.00", align: pw.TextAlign.right),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _pdfTableCell("Total", isBold: true, align: pw.TextAlign.center),
                          _pdfTableCell(grandTotal.toStringAsFixed(2), isBold: true, align: pw.TextAlign.right),
                          _pdfTableCell("0", isBold: true, align: pw.TextAlign.center),
                          _pdfTableCell("0.00", isBold: true, align: pw.TextAlign.right),
                          _pdfTableCell("0", isBold: true, align: pw.TextAlign.center),
                          _pdfTableCell("0.00", isBold: true, align: pw.TextAlign.right),
                          _pdfTableCell("0.00", isBold: true, align: pw.TextAlign.right),
                        ],
                      ),
                    ],
                  ),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(3),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                    ),
                    child: pw.Text("Tax Amount (in words) : INR Zero Only", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6.5)),
                  ),

                  // 6. DECLARATION & SIGNATURE
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("Declaration", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                                    pw.SizedBox(height: 2),
                                    pw.Text("We declare that this invoice shows the actual price of the goods described and that all particulars are true and correct.", style: const pw.TextStyle(fontSize: 6)),
                                  ],
                                ),
                                pw.Text("Customer's Seal and Signature", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6.5)),
                              ],
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 5,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text("Authorised Signatory", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final String rawRecNo = (receiveInfo["receive_no"] ?? widget.dispatchid ?? "01").toString().replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final fileName = "ProteinOva_Receive_$rawRecNo.pdf";
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF Invoice saved to ${file.path}"),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }

      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving/opening PDF: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final String status = receiveInfo["status"] ?? "";
    final bool isArrived = status == "ARRIVAL" || status == "DELIVERED";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Back Button & Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: AppColors.background,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.arrow_back,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Back to Inventory",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Receive Stock: ",
                                  style: AppTextStyles.headingText22.copyWith(
                                    fontSize: isDesktop ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: receiveInfo["receive_no"] ?? "",
                                  style: AppTextStyles.headingText22.copyWith(
                                    fontSize: isDesktop ? 24 : 20,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _handleDownloadBill,
                                icon: const Icon(Icons.picture_as_pdf, size: 16),
                                label: const Text("Download Bill"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                              if (!isArrived)
                                ElevatedButton(
                                  onPressed: handleArrival,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Mark Arrival",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                              else if (status == "ARRIVAL")
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Arrived",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Manage and receive incoming shipments from warehouse to update branch inventory",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Row 1 Layout: side-by-side on desktop/tablet, stacked on mobile
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildReceivedInfoCard(),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 4,
                                  child: _buildReceivedItemsCard(),
                                ),
                                const SizedBox(width: 24),
                                Expanded(flex: 3, child: _buildSummaryCard()),
                              ],
                            )
                          : Column(
                              children: [
                                _buildReceivedInfoCard(),
                                const SizedBox(height: 24),
                                _buildReceivedItemsCard(),
                                const SizedBox(height: 24),
                                _buildSummaryCard(),
                              ],
                            ),

                      const SizedBox(height: 24),

                      // Row 2 Layout: Inspection Table
                      _buildInspectionCard(isDesktop),

                      const SizedBox(height: 24),

                      // Row 3 Layout: Notes & Bottom Action buttons
                      _buildNotesAndActionsSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildReceivedInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Received Info",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Table(
            children: [
              TableRow(
                children: [
                  _buildLabelValueCell(
                    "Dispatch Code",
                    receiveInfo["dispatch_code"] ?? "N/A",
                  ),
                  _buildLabelValueCell(
                    "Dispatch Date",
                    formatLocalDate(receiveInfo["dispatch_date"]),
                  ),
                ],
              ),
              const TableRow(
                children: [SizedBox(height: 16), SizedBox(height: 16)],
              ),
              TableRow(
                children: [
                  _buildLabelValueCell(
                    "Vehicle No.",
                    receiveInfo["vehicle_number"] ?? "N/A",
                  ),
                  _buildLabelValueCell(
                    "Driver Name",
                    receiveInfo["driver_name"] ?? "N/A",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "From",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  receiveInfo["from_supplier"] ?? "N/A",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValueCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Received Items",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(0.8), // Id
              1: FlexColumnWidth(2.2), // Product
              2: FlexColumnWidth(1.2), // Tray Type
              3: FlexColumnWidth(1.0), // Trays
              4: FlexColumnWidth(1.2), // Eggs
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                ),
                children: [
                  _buildTableCell("Id", isHeader: true),
                  _buildTableCell("Product", isHeader: true),
                  _buildTableCell("Tray Type", isHeader: true),
                  _buildTableCell(
                    "Trays",
                    isHeader: true,
                    textAlign: TextAlign.center,
                  ),
                  _buildTableCell(
                    "Eggs",
                    isHeader: true,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              ...receivedItems.map((item) {
                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  children: [
                    _buildTableCell(item["id"].toString()),
                    _buildTableCell(item["product"] ?? "N/A"),
                    _buildTableCell(item["tray_type"] ?? "N/A"),
                    _buildTableCell(
                      item["trays"].toString(),
                      textAlign: TextAlign.center,
                    ),
                    _buildTableCell(
                      formatNumber(item["eggs"]),
                      textAlign: TextAlign.right,
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Total Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "${summary["total_trays"] ?? 0} Trays",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      "${formatNumber(summary["total_eggs"])} Eggs",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Shipment Summary",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              Icon(Icons.description_outlined, color: Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          _buildSummaryRowItem("Total Trays", summary["total_trays"]),
          _buildSummaryRowItem(
            "Total Eggs",
            formatNumber(summary["total_eggs"]),
          ),
          _buildSummaryRowItem("Plastic Trays", summary["plastic_trays"]),
          _buildSummaryRowItem("Paper Trays", summary["paper_trays"]),
          _buildSummaryRowItem("Empty Trays", summary["empty_trays"]),
        ],
      ),
    );
  }

  Widget _buildSummaryRowItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          Text(
            (value ?? 0).toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tray Details (Inspection)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (isDesktop)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5), // Grade
                1: FlexColumnWidth(1.5), // Type
                2: FlexColumnWidth(1.5), // Expected
                3: FlexColumnWidth(1.8), // Damaged Input
                4: FlexColumnWidth(1.5), // Good Computed
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                  ),
                  children: [
                    _buildTableCell("Product Grade", isHeader: true),
                    _buildTableCell(
                      "Tray Type",
                      isHeader: true,
                      textAlign: TextAlign.center,
                    ),
                    _buildTableCell(
                      "Expected (Eggs)",
                      isHeader: true,
                      textAlign: TextAlign.center,
                    ),
                    _buildTableCell(
                      "Damaged (Eggs)",
                      isHeader: true,
                      textAlign: TextAlign.center,
                    ),
                    _buildTableCell(
                      "Good (Eggs)",
                      isHeader: true,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                ...receivedItems.map((item) {
                  final String product = item["product"] ?? "";
                  final int expected = item["eggs"] ?? 0;
                  final int damaged = damagedTrays[product] ?? 0;
                  final int good = expected - damaged;
                  final controller = _damagedControllers[product];

                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    children: [
                      _buildTableCell(product),
                      _buildTableCell(
                        item["tray_type"] ?? "N/A",
                        textAlign: TextAlign.center,
                      ),
                      _buildTableCell(
                        formatNumber(expected),
                        textAlign: TextAlign.center,
                      ),
                      // Damaged input
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 100,
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Good eggs
                      _buildTableCell(
                        formatNumber(good),
                        textAlign: TextAlign.center,
                        textColor: Colors.green,
                        isBold: true,
                      ),
                    ],
                  );
                }),
              ],
            )
          else
            Column(
              children: receivedItems.map((item) {
                final String product = item["product"] ?? "";
                final int expected = item["eggs"] ?? 0;
                final int damaged = damagedTrays[product] ?? 0;
                final int good = expected - damaged;
                final controller = _damagedControllers[product];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInspectionStackItem(
                              "Tray Type",
                              item["tray_type"] ?? "N/A",
                            ),
                          ),
                          Expanded(
                            child: _buildInspectionStackItem(
                              "Expected Eggs",
                              formatNumber(expected),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Damaged (Eggs)",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 8,
                                          ),
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Good (Eggs)",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  formatNumber(good),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          // Warning box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Damage trays will be excluded from your usable stock and logged for audit.",
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionStackItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    TextAlign textAlign = TextAlign.left,
    Color? textColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: isHeader
              ? FontWeight.bold
              : (isBold ? FontWeight.bold : FontWeight.normal),
          color: isHeader
              ? const Color(0xFF64748B)
              : (textColor ?? const Color(0xFF1E293B)),
          fontSize: isHeader ? 12 : 13,
        ),
      ),
    );
  }

  Widget _buildNotesAndActionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter any additional notes...",
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isSubmitting ? null : handleConfirmReceive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        children: const [
                          Icon(Icons.verified_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Confirm Receive",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
}
