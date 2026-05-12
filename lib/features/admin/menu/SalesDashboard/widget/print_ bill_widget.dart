import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintBillWidget extends StatelessWidget {
  final String grandTotal;

  final String selectedPaymentMethod;

  const PrintBillWidget({
    super.key,
    required this.grandTotal,
    required this.selectedPaymentMethod,
  });

  Future<void> printBill() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),

        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              /// COMPANY
              pw.Center(
                child: pw.Text(
                  "PROTEINOVA FARMS",

                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Center(
                child: pw.Text("No: 123, Main Street, Chennai - 600001"),
              ),

              pw.SizedBox(height: 4),

              pw.Center(
                child: pw.Text("Ph: 9876543210 | GSTIN: 33ABCDE1234F1Z5"),
              ),

              pw.SizedBox(height: 15),

              pw.Divider(),

              pw.SizedBox(height: 10),

              /// TITLE
              pw.Center(
                child: pw.Text(
                  "SALES BILL",

                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              /// BILL DETAILS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,

                    children: [
                      pw.Text("Bill No : INV100123"),

                      pw.SizedBox(height: 4),

                      pw.Text("Time : 10:45 AM"),
                    ],
                  ),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,

                    children: [
                      pw.Text("Date : 24-05-2025"),

                      pw.SizedBox(height: 4),

                      pw.Text("User : Admin"),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 15),

              pw.Divider(),

              pw.SizedBox(height: 10),

              /// TABLE HEADER
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,

                    child: pw.Text(
                      "S.No",

                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Expanded(
                    flex: 4,

                    child: pw.Text(
                      "Item",

                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Expanded(
                    flex: 2,

                    child: pw.Text(
                      "Qty",

                      textAlign: pw.TextAlign.center,

                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Expanded(
                    flex: 2,

                    child: pw.Text(
                      "Rate",

                      textAlign: pw.TextAlign.center,

                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),

                  pw.Expanded(
                    flex: 2,

                    child: pw.Text(
                      "Amount",

                      textAlign: pw.TextAlign.right,

                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              /// ITEM 1
              pw.Row(
                children: [
                  pw.Expanded(flex: 1, child: pw.Text("1")),

                  pw.Expanded(flex: 4, child: pw.Text("Brown Eggs (Tray)")),

                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("2", textAlign: pw.TextAlign.center),
                  ),

                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("₹120", textAlign: pw.TextAlign.center),
                  ),

                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("₹240", textAlign: pw.TextAlign.right),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              /// ITEM 2
              pw.Row(
                children: [
                  pw.Expanded(flex: 1, child: pw.Text("2")),

                  pw.Expanded(flex: 4, child: pw.Text("Country Eggs")),

                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("1", textAlign: pw.TextAlign.center),
                  ),

                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("₹135", textAlign: pw.TextAlign.center),
                  ),

                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("₹135", textAlign: pw.TextAlign.right),
                  ),
                ],
              ),

              pw.SizedBox(height: 15),

              pw.Divider(),

              pw.SizedBox(height: 10),

              /// TOTALS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                children: [pw.Text("Sub Total"), pw.Text("₹525")],
              ),

              pw.SizedBox(height: 5),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                children: [pw.Text("Discount"), pw.Text("₹25")],
              ),

              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                children: [
                  pw.Text(
                    "Grand Total",

                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),

                  pw.Text(
                    "₹ $grandTotal",

                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.SizedBox(height: 15),

              pw.Divider(),

              pw.SizedBox(height: 10),

              /// PAYMENT
              pw.Text("Payment Mode : $selectedPaymentMethod"),

              pw.SizedBox(height: 4),

              pw.Text("Amount Paid : ₹ $grandTotal"),

              pw.SizedBox(height: 20),

              pw.Divider(),

              pw.SizedBox(height: 20),

              /// FOOTER
              pw.Center(
                child: pw.Text(
                  "Thank You!",

                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Center(child: pw.Text("Visit Again!")),
            ],
          );
        },
      ),
    );

    /// PRINT
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,

        foregroundColor: Colors.black,

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),

      onPressed: () async {
        await printBill();
      },

      icon: const Icon(Icons.print),

      label: const Text("Print Bill"),
    );
  }
}
