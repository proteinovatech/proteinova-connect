import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateThermalPdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(
        80 * PdfPageFormat.mm,
        double.infinity,
        marginAll: 10,
      ),

      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,

          children: [
            /// SHOP NAME
            pw.Center(
              child: pw.Text(
                "SHOPPERS STORE",

                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 2),

            pw.Center(
              child: pw.Text(
                "No 25, Main Road, Chennai",

                style: const pw.TextStyle(fontSize: 8),
              ),
            ),

            pw.Center(
              child: pw.Text(
                "Ph : 9876543210",

                style: const pw.TextStyle(fontSize: 8),
              ),
            ),

            pw.SizedBox(height: 5),

            pw.Divider(),

            /// BILL DETAILS
            billRow("Bill No", "1025"),
            billRow("Date", "24-05-2025"),
            billRow("Time", "10:45 AM"),
            billRow("Cashier", "Admin"),

            pw.Divider(),

            /// HEADER
            pw.Row(
              children: [
                pw.Expanded(flex: 4, child: headerText("Item")),

                pw.Expanded(
                  child: headerText("Qty", align: pw.TextAlign.center),
                ),

                pw.Expanded(
                  child: headerText("Rate", align: pw.TextAlign.center),
                ),

                pw.Expanded(
                  child: headerText("Amt", align: pw.TextAlign.right),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            /// ITEMS
            itemRow("Brown Eggs", "2", "120", "240"),

            itemRow("Country Eggs", "1", "135", "135"),

            itemRow("Duck Eggs", "1", "150", "150"),

            pw.Divider(),

            /// TOTAL
            totalRow("Sub Total", "525"),
            totalRow("Discount", "25"),

            totalRow("Grand Total", "500", bold: true),

            pw.Divider(),

            billRow("Payment", "Cash"),
            billRow("Paid", "500"),

            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text(
                "THANK YOU",

                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.Center(
              child: pw.Text(
                "Visit Again",

                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ],
        );
      },
    ),
  );

  /// SAVE PDF
  final dir = await getApplicationDocumentsDirectory();

  final file = File("${dir.path}/thermal_bill.pdf");

  await file.writeAsBytes(await pdf.save());

  /// PRINT PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

/// COMMON ROW
pw.Widget billRow(String left, String right) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),

    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(left, style: const pw.TextStyle(fontSize: 8)),
        ),

        pw.Text(right, style: const pw.TextStyle(fontSize: 8)),
      ],
    ),
  );
}

/// HEADER TEXT
pw.Widget headerText(String text, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Text(
    text,

    textAlign: align,

    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
  );
}

/// ITEM ROW
pw.Widget itemRow(String item, String qty, String rate, String amt) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),

    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 4,

          child: pw.Text(item, style: const pw.TextStyle(fontSize: 8)),
        ),

        pw.Expanded(
          child: pw.Text(
            qty,

            textAlign: pw.TextAlign.center,

            style: const pw.TextStyle(fontSize: 8),
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            rate,

            textAlign: pw.TextAlign.center,

            style: const pw.TextStyle(fontSize: 8),
          ),
        ),

        pw.Expanded(
          child: pw.Text(
            amt,

            textAlign: pw.TextAlign.right,

            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
      ],
    ),
  );
}

/// TOTAL ROW
pw.Widget totalRow(String title, String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),

    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

      children: [
        pw.Text(
          title,

          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),

        pw.Text(
          value,

          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
