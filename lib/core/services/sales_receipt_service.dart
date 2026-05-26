import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proteinova_connect/features/branch/sales/data/model/sales_item_model.dart';

class SalesReceiptService {
  static Future<void> generateAndPrintFromMap(
    Map<String, dynamic> order, {
    bool isThermal = true,
  }) async {
    final List<SalesItem> items = (order['items'] as List? ?? []).map((item) {
      return SalesItem(
        eggCategoryGrade: item['egg_category_grade'] ?? "Eggs",
        eggs: item['total_eggs'] ?? 0,
        price:
            (item['rate_per_tray'] ?? 0) /
            30, // Rough estimate if only tray rate available
        total: (item['subtotal'] ?? 0).toDouble(),
      );
    }).toList();

    return generateAndPrintReceipt(
      saleId: order['invoice_no'] ?? order['order_id'] ?? "N/A",
      customerName:
          order['customer_name'] ?? order['customer'] ?? "Walk-in Customer",
      customerNumber: order['customer_phone'] ?? "",
      date:
          order['created_at'] ??
          order['date'] ??
          DateTime.now().toIso8601String(),
      items: items,
      subtotal: (order['total_amount'] ?? 0).toDouble(),
      discount: (order['discount_amount'] ?? 0).toDouble(),
      total: (order['net_amount'] ?? order['amount'] ?? 0).toDouble(),
      paymentMethod: order['payment_method'] ?? "CASH",
      branchName: order['branch_name'] ?? order['sold_location'],
      trayCharges: (order['tray_charges'] ?? 0).toDouble(),
      isThermal: isThermal,
    );
  }

  static Future<void> generateAndPrintReceipt({
    required String saleId,
    required String customerName,
    required String customerNumber,
    required String date,
    required List<SalesItem> items,
    required double subtotal,
    required double discount,
    required double total,
    required String paymentMethod,
    String? branchName,
    double trayCharges = 0.0,
    bool isThermal = true,
  }) async {
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/Logo@3x.png')).buffer.asUint8List(),
    );
    final ttfRegular = await PdfGoogleFonts.notoSansRegular();
    final ttfBold = await PdfGoogleFonts.notoSansBold();
    final theme = pw.ThemeData.withFont(base: ttfRegular, bold: ttfBold);
    if (!isThermal) {
      final pdfBytes = await generateReceiptPdf(
        saleId: saleId,
        customerName: customerName,
        customerNumber: customerNumber,
        date: date,
        items: items,
        subtotal: subtotal,
        discount: discount,
        total: total,
        paymentMethod: paymentMethod,
        branchName: branchName,
        trayCharges: trayCharges,
      );
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Invoice_$saleId',
      );
      return;
    }

    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /// LOGO LEFT SIDE
                  pw.Container(width: 35, height: 35, child: pw.Image(logo)),

                  pw.SizedBox(width: 12),

                  /// SHOP DETAILS
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "PROTEINOVA",
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 2),

                        pw.Text(
                          "PURE PROTEIN, PURE POWER",
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Text("Receipt : $saleId"),
              pw.Text("Date: $date"),
              pw.Text("Customer: $customerName"),
              if (customerNumber.isNotEmpty) pw.Text("Phone: $customerNumber"),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      "Item",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      "Qty",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "Total",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              ...items
                  .where((i) => i.eggs > 0)
                  .map(
                    (item) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              item.eggCategoryGrade,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              "${item.eggs}",
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              "₹ ${item.total.toStringAsFixed(2)}",
                              style: const pw.TextStyle(fontSize: 10),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Subtotal:"),
                  pw.Text("₹ ${subtotal.toStringAsFixed(2)}"),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Discount:"),
                  pw.Text("₹ ${discount.toStringAsFixed(2)}"),
                ],
              ),
              if (trayCharges > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Tray Charges:"),
                    pw.Text("₹ ${trayCharges.toStringAsFixed(2)}"),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("SGST:", style: const pw.TextStyle(fontSize: 8)),
                  pw.Text("₹ 0.00", style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("CGST:", style: const pw.TextStyle(fontSize: 8)),
                  pw.Text("₹ 0.00", style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Grand Total:",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    "₹ ${(total.ceilToDouble()).toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("Payment Mode: $paymentMethod"),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Thank you for choosing Proteinova!",
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_$saleId',
    );
  }

  static Future<Uint8List> generateReceiptPdf({
    required String saleId,
    required String customerName,
    required String customerNumber,
    required String date,
    required List<SalesItem> items,
    required double subtotal,
    required double discount,
    required double total,
    required String paymentMethod,
    String? branchName,
    double trayCharges = 0.0,
  }) async {
    final ttfRegular = await PdfGoogleFonts.notoSansRegular();
    final ttfBold = await PdfGoogleFonts.notoSansBold();
    final theme = pw.ThemeData.withFont(base: ttfRegular, bold: ttfBold);
    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      branchName ?? "PROTEINOVA",
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (branchName != null)
                      pw.Text(
                        "PROTEINOVA - Freshness Delivered",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      )
                    else
                      pw.Text(
                        "Freshness Delivered",
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Billed To:",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(customerName),
                      if (customerNumber.isNotEmpty) pw.Text(customerNumber),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Receipt Details:",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text("ID: #$saleId"),
                      pw.Text("Date: $date"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Product Description",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Quantity (Eggs)",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Rate/Egg",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Amount",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  ...items
                      .where((i) => i.eggs > 0)
                      .map(
                        (item) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(item.eggCategoryGrade),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                "${item.eggs}",
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                " ₹ ${item.price.toStringAsFixed(2)}",
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                "₹ ${item.total.toStringAsFixed(2)}",
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Subtotal: ₹ ${subtotal.toStringAsFixed(2)}"),
                      pw.Text(
                        "Offer Discount: -₹ ${discount.toStringAsFixed(2)}",
                      ),
                      if (trayCharges > 0)
                        pw.Text(
                          "Tray Charges: ₹ ${trayCharges.toStringAsFixed(2)}",
                        ),
                      pw.Divider(color: PdfColors.grey400),
                      pw.Text(
                        "Grand Total: ₹ ${(total.ceilToDouble()).toStringAsFixed(2)}",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  "This is a computer-generated receipt. No signature required.",
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
