import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

import 'package:proteinova_connect/features/branch/sales/widget/transaction_detailscard.dart';
import 'package:proteinova_connect/features/purchase/orders/presentation/checkout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesEntry extends StatefulWidget {
  const SalesEntry({super.key});

  @override
  State<SalesEntry> createState() => _SalesEntryState();
}

class _SalesEntryState extends State<SalesEntry> {
  final TextEditingController categoryController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController notesController = TextEditingController();
  final baseUrl = dotenv.env['BASE_URL'];
  bool isLoading = true;

  Map<String, dynamic> header = {};

  List<dynamic> productDetails = [];

  List<dynamic> offers = [];

  List<dynamic> paymentMethods = [];

  Map<String, dynamic> billSummary = {};

  @override
  void initState() {
    super.initState();

    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      // final response = await http.get(
      //   Uri.parse("$baseUrl/api/sales/dashboard?branch_id=1"),
      //   headers: {"Accept": "application/json"},
      // );
      final prefs = await SharedPreferences.getInstance();

      final branchId = prefs.getInt("branch_id");

      print("BRANCH ID => $branchId");

      final response = await http.get(
        Uri.parse("$baseUrl/api/sales/dashboard?branch_id=$branchId"),

        headers: {"Accept": "application/json"},
      );

      print("STATUS CODE : ${response.statusCode}");

      print("STATUS CODE : ${response.statusCode}");

      print("BODY : ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        /// IMPORTANT FIX

        final data = decodedData["data"] ?? decodedData;

        setState(() {
          header = Map<String, dynamic>.from(data["header"] ?? {});

          productDetails = List<Map<String, dynamic>>.from(
            data["product_details"] ?? [],
          );

          offers = List<Map<String, dynamic>>.from(data["offers"] ?? []);

          paymentMethods = List<String>.from(data["payment_methods"] ?? []);

          billSummary = Map<String, dynamic>.from(
            data["bill_summary_defaults"] ?? {},
          );

          isLoading = false;
        });

        print("PRODUCT DETAILS : $productDetails");
      } else {
        setState(() {
          isLoading = false;
        });

        print("ERROR STATUS : ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print("ERROR : $e");
    }
  }
Future<void> generateAndPrintPdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            /// 🔹 HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("X Eggs Farms",
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text("Kattuva"),
                    pw.Text("City, State, ZIP"),
                    pw.Text("Phone Number:"),
                  ],
                ),
                pw.Text(
                  "INVOICE",
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Bill To:",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("Name :"),
                    pw.Text("Address :"),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Date: ${DateTime.now().toString().split(' ')[0]}"),
                    pw.Text("Invoice #: 001"),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            /// 🔹 TABLE HEADER
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("Description")),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("Qty")),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("Unit Price")),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text("Total")),
                  ],
                ),

                /// 🔹 SAMPLE DATA (Replace with your list)
                ...productDetails.map((product) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(product["product_name"].toString())),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("1")),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("₹${product["per_tray_price"]}")),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("₹${product["per_tray_price"]}")),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            /// 🔹 TOTAL SECTION
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      _pdfRow("Subtotal", "₹$totalAmount"),
                      _pdfRow("Tax", "₹0"),
                      pw.Divider(),
                      _pdfRow(
                        "Total",
                        "₹$totalAmount",
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            /// 🔹 FOOTER
            pw.Text("Thank you for your business!",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
}
pw.Widget _pdfRow(String title, String value, {bool isBold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight:
                isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
Future<void> downloadPdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text("Sales Invoice - ₹$totalAmount"),
        );
      },
    ),
  );

  final dir = await getApplicationDocumentsDirectory();
  final file = File("${dir.path}/sales_invoice.pdf");

  await file.writeAsBytes(await pdf.save());

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("PDF saved in ${file.path}")),
  );
}
Future<void> saveSale(double totalAmount) async {
    print("Saving sale: ₹$totalAmount");

  await Future.delayed(const Duration(seconds: 1));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Sale saved successfully")),
  );
}
void showPaymentOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text("Print"),
              onTap: () {
                Navigator.pop(context);
                generateAndPrintPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Download PDF"),
              onTap: () {
                Navigator.pop(context);
                downloadPdf();
              },
            ),
          ],
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Padding(
        padding: EdgeInsets.only(
          left: size.height * 0.01,
          right: size.height * 0.01,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.06),

            Padding(
              padding: EdgeInsets.only(left: size.width * 0.72),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined),

                  SizedBox(width: size.width * 0.02),

                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          header["title"]?.toString() ?? "Daily Sales Entry",
                          style: AppTextStyles.headingText22,
                        ),

                        SizedBox(width: size.width * 0.07),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor2,
                            border: Border.all(color: AppColors.border2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.menu, color: AppColors.blueAccent),

                              Text(
                                "Today's Sales",
                                style: AppTextStyles.blueText2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.02),

                    Text(
                      "Log new sales transactions to automatically update\nbranch inventory.",
                      style: AppTextStyles.bodyText14,
                    ),

                    SizedBox(height: size.height * 0.02),

                   TransactionDetailscard(
  categoryController: categoryController,
  quantityController: quantityController,
  nameController: nameController,
  notesController: notesController,

  onCollectPayment: () async {
    await saveSale(totalAmount);   // ✅ now exists
    showPaymentOptions();          // ✅ works
  },
),

                    SizedBox(height: size.height * 0.02),

                    /// PRODUCT DETAILS
                    productDetails.isEmpty
                        ? const Center(child: Text("No Products"))
                        : ListView.builder(
                            itemCount: productDetails.length,

                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            itemBuilder: (context, index) {
                              final product = productDetails[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),

                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius: BorderRadius.circular(12),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      product["product_name"].toString(),

                                      style: const TextStyle(
                                        fontSize: 18,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Per Tray Price : ₹ ${product["per_tray_price"]}",
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      "Stock Trays : ${product["stock_trays"]}",
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      "Stock Eggs : ${product["stock_eggs"]}",
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    SizedBox(height: size.height * 0.02),

                    /// OFFERS
                    if (offers.isNotEmpty)
                      ListView.builder(
                        itemCount: offers.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final offer = offers[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green.shade50,
                                  child: const Icon(
                                    Icons.local_offer,
                                    color: Colors.green,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    offer["offer_text"].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    SizedBox(height: size.height * 0.02),

                    /// PAYMENT METHODS
                    if (paymentMethods.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: paymentMethods.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(e.toString()),
                          );
                        }).toList(),
                      ),

                    SizedBox(height: size.height * 0.02),

                    /// BILL SUMMARY
                    // Container(
                    //   padding: const EdgeInsets.all(14),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey.shade300),
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       summaryRow("Items", "${billSummary["items"] ?? 0}"),

                    //       summaryRow("Trays", "${billSummary["trays"] ?? 0}"),

                    //       summaryRow(
                    //         "Subtotal",
                    //         "₹ ${billSummary["subtotal"] ?? 0}",
                    //       ),

                    //       summaryRow("Tax", "₹ ${billSummary["tax"] ?? 0}"),

                    //       const Divider(),

                    //       summaryRow(
                    //         "Total Amount",
                    //         "₹ ${billSummary["total_amount"] ?? 0}",
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // SizedBox(height: size.height * 0.02),

                    // Visibility(
                    //   visible: false,
                    //   child: Column(
                    //     children: [
                    //       StockPreviewCard(
                    //         available: productDetails.isNotEmpty
                    //             ? productDetails[0]["stock_trays"].toString()
                    //             : "0",

                    //         selling: quantityController.text.isEmpty
                    //             ? "- 0"
                    //             : "- ${quantityController.text}",

                    //         remaining: productDetails.isNotEmpty
                    //             ? (productDetails[0]["stock_trays"] -
                    //                       (int.tryParse(
                    //                             quantityController.text,
                    //                           ) ??
                    //                           0))
                    //                   .toString()
                    //             : "0",

                    //         onReceiveTap: () {},
                    //       ),

                    //       SizedBox(height: size.height * 0.02),

                    //       RecentSalesCard(
                    //         sales: [
                    //           SaleItem(
                    //             time: "Today",
                    //             quantity: header["today_sales"]?["count"] ?? 0,
                    //             customer: "Today's Sales",
                    //           ),

                    //           SaleItem(
                    //             time: "Stock",
                    //             quantity: productDetails.isNotEmpty
                    //                 ? productDetails[0]["stock_trays"]
                    //                 : 0,
                    //             customer: productDetails.isNotEmpty
                    //                 ? productDetails[0]["product_name"]
                    //                       .toString()
                    //                 : "Product",
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
