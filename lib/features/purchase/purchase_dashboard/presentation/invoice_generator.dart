import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceGenerator{
  static Future<void> generate({
    required Map<String, dynamic> purchase,
    required List<Map<String, dynamic>> items,
  }) async {
    final regular = pw.Font.ttf(
  await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
);

final bold = pw.Font.ttf(
  await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
);

final pdf = pw.Document(
  theme: pw.ThemeData.withFont(
    base: regular,
    bold: bold,
  ),
);

    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    double grandTotal = 0;

    for (final item in items) {
      grandTotal +=
          (item["total_amount"] ??
                  ((item["trays"] ?? 0) *
                      (item["capacity"] ?? 30) *
                      (item["per_egg_price"] ?? 0)))
              .toDouble();
    }

    final totalTrays = items.fold<int>(
  0,
  (sum, item) => sum + (num.tryParse(item["trays"].toString())?.toInt() ?? 0),
);

final totalEggs = items.fold<int>(
  0,
  (sum, item) {
    final trays = num.tryParse(item["trays"].toString())?.toInt() ?? 0;
    final capacity = num.tryParse(item["capacity"].toString())?.toInt() ?? 30;
    return sum + trays * capacity;
  },
);
final formattedDate = DateFormat('dd/MM/yyyy').format(
  DateTime.parse(purchase["created_at"]),
);


    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
            ),
            child: pw.Column(
              children: [

                //---------------- Header ----------------//

                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [

                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              "PROTEIN OVA",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 18),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "141/40c, Kurinji Tower, Salem Road,\nNamakkal, Tamil Nadu - 637001",
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Phone : +91 9791220001",
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(width: 10),

                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Email: contact@proteinova.in",
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 5),
                          pw.Text("GSTIN : 33AAAAA0000A1Z5",
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 5),
                          pw.Text("State : 33-Tamil Nadu",
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      )
                    ],
                  ),
                ),

                pw.Divider(height: 1),

                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    "Purchase Bill",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                ),

                pw.Divider(height: 1),

                //---------------- Supplier & Purchase ----------------//

                pw.Row(
                  children: [

                    pw.Expanded(
                      child: pw.Container(
                        height: 110,
                        padding: const pw.EdgeInsets.all(10),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              "Supplier Details:",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 15),
                            pw.Text(
                              purchase["supplier_company_name"] ??
                                  "SKR POULTRY FARM",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),

                    pw.Expanded(
                      child: pw.Container(
                        height: 110,
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.Text("Purchase Details",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    pw.SizedBox(height: 8),
    pw.Text("PO No: PO-${purchase["id"]}"),
    pw.Text("Date: $formattedDate"),
 
    pw.Text("Warehouse: ${purchase["warehouse_location"] ?? "--"}"),
  ],
),
                      ),
                    ),
                  ],
                ),

                //---------------- Items Table ----------------//

                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(25),
                    1: const pw.FixedColumnWidth(90),
                    2: const pw.FixedColumnWidth(60),
                    3: const pw.FixedColumnWidth(70),
                    4: const pw.FixedColumnWidth(60),
                    5: const pw.FixedColumnWidth(70),
                    6: const pw.FixedColumnWidth(55),
                    7: const pw.FixedColumnWidth(75),
                  },
                  children: [

                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300),
                      children: [
                        _cell("#", true),
                        _cell("Item Name", true),
                        _cell("HSN/SAC", true),
                        _cell("Qty (Trays)", true),
                        _cell("Total Eggs", true),
                        _cell("Price/Egg", true),
                        _cell("GST", true),
                        _cell("Amount", true),
                      ],
                    ),

                    ...List.generate(items.length, (index) {
                      final item = items[index];

                      return pw.TableRow(
                        children: [

                          _cell("${index + 1}"),

                          _cell(item["egg_category_grade"] ?? ""),

                          _cell("04072100"),

                          _cell("${item["trays"]} Trays"),

                          _cell(
                              "${(item["trays"] ?? 0) * (item["capacity"] ?? 30)}"),

                          _cell("₹ ${item["per_egg_price"]}"),

                          _cell("₹ 0"),

                          _cell(currency.format(
                              (item["trays"] ?? 0) *
                                  (item["capacity"] ?? 30) *
                                  (item["per_egg_price"] ?? 0))),
                        ],
                      );
                    }),

                    pw.TableRow(
                      children: [
                        _cell(""),
                        _cell(""),
                        _cell("Total", true),
                        _cell("$totalTrays Trays", true),
                        _cell("$totalEggs", true),
                        _cell(""),
                        _cell(""),
                        _cell(currency.format(grandTotal), true),
                      ],
                    ),
                  ],
                ),

                //---------------- Bottom ----------------//

                pw.Expanded(
                  child: pw.Row(
                    children: [

                      /// Left
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              right: pw.BorderSide(),
                            ),
                          ),
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [

                              pw.Center(
                                child: pw.Text(
                                  "Expenses & Payment Details",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),

                              pw.SizedBox(height: 10),

                              pw.Text(
                                  "Loading Charge : ₹ ${purchase["loading_charge"] ?? 0}"),

                              pw.Text(
                                  "Unloading Charge : ₹ ${purchase["unloading_charge"] ?? 0}"),

                              pw.Text(
                                  "Transport Charge : ₹ ${purchase["transport_charge"] ?? 0}"),

                              pw.Text(
                                  "Misc Expense : ₹ ${purchase["misc_expense"] ?? 0}"),

                              pw.Divider(),

                              pw.Center(
                                child: pw.Text(
                                  "Payment Splits",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),

                              pw.SizedBox(height: 10),

                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text("RTGS/NEFT"),
                                  pw.Text(currency.format(grandTotal)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      /// Right
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Column(
                            children: [

                              _amountRow("Sub Total",
                                  currency.format(grandTotal)),

                              _amountRow("Expenses Total", "₹ 0"),

                              pw.Divider(),

                              _amountRow(
                                "Grand Total",
                                currency.format(grandTotal),
                                bold: true,
                              ),

                              pw.SizedBox(height: 15),

                              pw.Container(
                                width: double.infinity,
                                padding: const pw.EdgeInsets.all(10),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(),
                                ),
                                child: pw.Column(
                                  children: [
                                    pw.Text(
                                      "Amount In Words:",
                                      style: pw.TextStyle(
                                          fontWeight:
                                              pw.FontWeight.bold),
                                    ),
                                    pw.Text(
                                        "${currency.format(grandTotal)} only"),
                                  ],
                                ),
                              ),

                              pw.SizedBox(height: 10),

                              _amountRow("Paid Amount",
                                  currency.format(grandTotal)),

                              _amountRow("Balance", "₹ 0"),

                              pw.SizedBox(height: 10),

                              pw.Container(
                                alignment: pw.Alignment.center,
                                width: double.infinity,
                                padding: const pw.EdgeInsets.all(6),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(),
                                ),
                                child: pw.Text(
                                  "STATUS: PAID",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),

                              pw.Spacer(),

                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      "For PROTEIN OVA:",
                                      style: pw.TextStyle(
                                          fontWeight:
                                              pw.FontWeight.bold),
                                    ),
                                    pw.SizedBox(height: 30),
                                    pw.Text("Authorized Signatory"),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "Purchase_Invoice_PO-${purchase["id"]}.pdf",
    );
  }

  static pw.Widget _cell(String text, [bool bold = false]) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  static pw.Widget _amountRow(String title, String value,
      {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title,
              style: bold
                  ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                  : const pw.TextStyle()),
          pw.Text(value,
              style: bold
                  ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                  : const pw.TextStyle()),
        ],
      ),
    );
  }

}

