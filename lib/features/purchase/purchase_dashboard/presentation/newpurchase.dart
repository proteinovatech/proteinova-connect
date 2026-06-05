import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/payment_model.dart';

import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/product_specificationcard.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/supplier_locationcard.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchase_employeecard.dart';

import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_state.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/purchase_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/product_input_model.dart';
import 'package:proteinova_connect/purchase_bottom_navigator.dart';

class Newpurchase extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? purchaseData;

  const Newpurchase({
    super.key,
    this.isEdit = false,
    this.purchaseData,
  });

  @override
  State<Newpurchase> createState() => _NewpurchaseState();
}

class _NewpurchaseState extends State<Newpurchase> {
  // Supplier & Location details
  String selectedSupplierName = "";
  String originLocation = "";
  int selectedSupplierId = 0;
  DateTime? expectedArrivalDate;

  final TextEditingController brokerNameController = TextEditingController();
  final TextEditingController brokerNumController = TextEditingController();

  // Product specification
  List<ProductInput> products = [ProductInput()];

  // Additional costs / Expenses
  final TextEditingController loadingController = TextEditingController(text: "0");
  final TextEditingController unloadingController = TextEditingController(text: "0");
  final TextEditingController transportController = TextEditingController(text: "0");
  final TextEditingController miscController = TextEditingController(text: "0");

  // Purchase employee details
  final TextEditingController driverController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Payment Selection state
  String activePaymentTab = "UPI"; // "UPI", "COD", "RTGS"
  String selectedUpiApp = "Google Pay"; // "Google Pay", "PhonePe", "Paytm", "Other"
  final TextEditingController otherUpiDetailsController = TextEditingController();
  final TextEditingController paymentAmountController = TextEditingController(text: "0");
  final TextEditingController debtAmountController = TextEditingController(text: "0");
  final List<PaymentModel> _payments = [];
  // Summaries
  double getProductTotal() {
    double total = 0;
    for (var p in products) {
      final qty = double.tryParse(p.quantity) ?? 0;
      final rate = double.tryParse(p.rate) ?? 0;
      total += qty * 30 * rate;
    }
    return total;
  }

  double getAdditionalTotal() {
    final load = double.tryParse(loadingController.text) ?? 0;
    final unload = double.tryParse(unloadingController.text) ?? 0;
    final trans = double.tryParse(transportController.text) ?? 0;
    final misc = double.tryParse(miscController.text) ?? 0;
    return load + unload + trans + misc;
  }

  double getTotalCost() {
    return getProductTotal() + getAdditionalTotal();
  }

  double getTotalTrays() {
    double total = 0;
    for (var p in products) {
      total += double.tryParse(p.quantity) ?? 0;
    }
    return total;
  }

  double getCostPerTray() {
    final trays = getTotalTrays();
    return trays == 0 ? 0 : getTotalCost() / trays;
  }
  
  
  @override
  void initState() {
    super.initState();

    loadingController.addListener(_refresh);
    unloadingController.addListener(_refresh);
    transportController.addListener(_refresh);
    miscController.addListener(_refresh);
    
    paymentAmountController.addListener(_refresh);
    debtAmountController.addListener(_refresh);
     _payments.add(
    PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    ),
  );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
  void _addPaymentRow() {
  setState(() {
    _payments.add(
      PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        method: '',
        amount: '',
      ),
    );
  });
}
bool _isDraftSubmission = false;
  void _submitForm(bool isDraft) {
    _isDraftSubmission = isDraft; 
    if (selectedSupplierId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a supplier"), backgroundColor: Colors.red),
      );
      return;
    }

    if (products.isEmpty || products.any((p) => p.category.isEmpty || (double.tryParse(p.quantity) ?? 0) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please specify products with quantity"), backgroundColor: Colors.red),
      );
      return;
    }

    final purchase = PurchaseRequest(
      supplierId: selectedSupplierId,
      supplierName: selectedSupplierName,
      location: originLocation,
      warehouseLocation: branchController.text,
      expectedArrival: expectedArrivalDate != null 
          ? expectedArrivalDate!.toIso8601String().split('T')[0]
          : DateTime.now().toIso8601String().split('T')[0],
      driverName: driverController.text,
      driverNumber: contactController.text,
      vehicleNumber: numberController.text,
      vehicleType: typeController.text,
      loadingCharge: double.tryParse(loadingController.text) ?? 0,
      unloadingCharge: double.tryParse(unloadingController.text) ?? 0,
      transportCharge: double.tryParse(transportController.text) ?? 0,
      miscExpense: double.tryParse(miscController.text) ?? 0,
      purchaseStatus: isDraft ? "PENDING" : "PURCHASED",
      brokerFee: 0.0,
      brokerNumber: brokerNumController.text,
      brokerName: brokerNameController.text,
      description: descriptionController.text,
      paymentMethod: activePaymentTab,
      upiApp: activePaymentTab == "UPI" ? selectedUpiApp : null,
      otherUpiDetails: otherUpiDetailsController.text,
      paymentAmount: double.tryParse(paymentAmountController.text) ?? 0.0,
      debtAmount: double.tryParse(debtAmountController.text) ?? 0.0,
      items: products.map((p) {
        return PurchaseItem(
          eggCategoryGrade: p.category,
          trays: int.tryParse(p.quantity) ?? 0,
          capacity: 30,
          perEggPrice: double.tryParse(p.rate) ?? 0.0,
          marketPriceMinus: double.tryParse(p.minus) ?? 0.0,
          neccRate: double.tryParse(p.necc) ?? 0.0,
          trayType: p.trayType,
        );
      }).toList(),
    );

    context.read<PurchaseBloc>().add(SubmitPurchaseEvent(purchase));
  }
  


void _handlePaymentChange(
  String id,
  String field,
  dynamic value,
) {
  final index = _payments.indexWhere((p) => p.id == id);

  if (index == -1) return;

  setState(() {
    if (field == 'method') {
      _payments[index].method = value ?? '';
    } else if (field == 'amount') {
      _payments[index].amount = value ?? '';
    }
  });
}

  void _showSuccessPopup(bool isDraft, String orderRef, double totalCost) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDraft ? AppColors.amber600.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDraft ? Icons.assignment_turned_in_outlined : Icons.check_circle_outline,
                    color: isDraft ? AppColors.amber600 : Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isDraft ? "Draft Saved!" : "Purchase Entry Submitted!",
                  style: AppTextStyles.headingText22,
                ),
                const SizedBox(height: 8),
                Text(
                  isDraft 
                      ? "Your purchase draft has been successfully saved."
                      : "Your purchase entry has been successfully recorded and added to incoming stock queue.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyText14,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildPopupRow("Order ID", orderRef),
                _buildPopupRow("Total Eggs", (getTotalTrays() * 30).toInt().toString()),
                _buildPopupRow("Estimated Cost", "₹ ${totalCost.toStringAsFixed(2)}"),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (!isDraft) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                        onPressed: () async {

  await _downloadBill(
    orderRef,
    totalCost,
  );

},
                          icon: const Icon(Icons.download_outlined, size: 16),
                          label: const Text("Bill", style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PurchaseBottomNavigator(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Dashboard"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.formInputs15),
          Text(value, style: AppTextStyles.bodyText16),
        ],
      ),
    );
  }
  double get totalAmount {
  double total = 0;

  for (var product in products) {
    final eggs = int.tryParse(product.totalEggs) ?? 0;
    final rate = double.tryParse(product.rate) ?? 0;

    total += eggs * rate;
  }

  return total;
}

  double get paidAmount {
  double total = 0;

  for (var payment in _payments) {
    total += double.tryParse(payment.amount) ?? 0;
  }

  return total;
}
double get balanceAmount {
  return totalAmount - paidAmount;
}
double get totalPaidAmount {
  return _payments.fold(
    0.0,
    (sum, payment) =>
        sum + (double.tryParse(payment.amount.toString()) ?? 0),
  );
}

double get pendingAmount {
  return getTotalCost() - paidAmount;
}

Future<void> _downloadBill(
  String orderRef,
  double totalCost,
) async {

  final pdf = pw.Document();
  final ttf = await PdfGoogleFonts.notoSansRegular();

  final int totalEggs = (getTotalTrays() * 30).toInt();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "Purchase Invoice",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  children: [

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Column(
                        children: [

                          pw.Text(
                            "PROTEIN OVA",
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),

                          pw.SizedBox(height: 5),

                          pw.Text(
                            "Namakkal, Tamil Nadu",
                          ),

                          pw.SizedBox(height: 15),

                          pw.Text(
                            "Purchase Bill",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Divider(),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Row(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                        children: [

                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                              children: [

                                pw.Text(
                                  "Supplier Details",
                                  style: pw.TextStyle(
                                    fontWeight:
                                        pw.FontWeight.bold,
                                  ),
                                ),

                                pw.SizedBox(height: 5),

                                pw.Text(
                                  selectedSupplierName,
                                ),

                                pw.Text(
                                  originLocation,
                                ),
                              ],
                            ),
                          ),

                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                              children: [

                                pw.Text(
                                  "Purchase Details",
                                  style: pw.TextStyle(
                                    fontWeight:
                                        pw.FontWeight.bold,
                                  ),
                                ),

                                pw.SizedBox(height: 5),

                                pw.Text(
                                  "PO No: $orderRef",
                                ),

                                pw.Text(
                                  "Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Divider(),

                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [

                        pw.TableRow(
                          children: [

                            _tableCell("#"),
                            _tableCell("Item"),
                            _tableCell("Qty"),
                            _tableCell("Eggs"),
                            _tableCell("Rate"),
                            _tableCell("Amount"),
                          ],
                        ),

                        ...products.asMap().entries.map((entry) {

                          final index = entry.key;
                          final product = entry.value;

                          final qty =
                              int.tryParse(product.quantity) ?? 0;

                          final eggs =
                              int.tryParse(product.totalEggs) ?? 0;

                          final rate =
                              double.tryParse(product.rate) ?? 0;

                          final amount = eggs * rate;

                          return pw.TableRow(
                            children: [

                              _tableCell("${index + 1}"),

                              _tableCell(product.category),

                              _tableCell("$qty"),

                              _tableCell("$eggs"),

                              _tableCell(
                                "₹ ${rate.toStringAsFixed(2)}",ttf
                              ),

                              _tableCell(
                                "₹ ${amount.toStringAsFixed(2)}",ttf
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.end,
                        children: [

                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [

                              pw.Text("Total Eggs"),

                              pw.Text("$totalEggs"),
                            ],
                          ),

                          pw.SizedBox(height: 8),

                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [

                              pw.Text(
                                "Grand Total",
                                style: pw.TextStyle(
                                  fontWeight:
                                      pw.FontWeight.bold,
                                ),
                              ),

                              pw.Text(
                                "₹ ${totalCost.toStringAsFixed(2)}",
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontWeight:
                                      pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async =>
        pdf.save(),
  );
}
 
 pw.Widget _tableCell(String text,[pw.Font? font]) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style:  pw.TextStyle(
        fontSize: 10,
        font: font
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseSubmitSuccess) {
          
          _showSuccessPopup(_isDraftSubmission, "PO-${DateTime.now().millisecondsSinceEpoch % 100000}", getTotalCost());
        } else if (state is PurchaseSubmitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background1,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text("New Purchase", style: AppTextStyles.headingText25),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Padding(
                  padding: EdgeInsets.only(left: size.width * 0.02),
                  child: Text(
                    "Record new form procurement and\nstock.",
                    style: AppTextStyles.bodyText16,
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                // Supplier & Location Card
                SupplierLocationCard(
                  brokerNameController: brokerNameController,
                  brokerNumController: brokerNumController,
                  onDateChanged: (date) {
                    setState(() {
                      expectedArrivalDate = date;
                    });
                  },
                  onChanged: (sup, loc, supId) {
                    setState(() {
                      selectedSupplierName = sup;
                      originLocation = loc;
                      selectedSupplierId = supId;
                    });
                  },
                ),
                SizedBox(height: size.height * 0.02),

                // Product Specification Card
                ProductSpecificationCard(
                  onProductsChanged: (list) {
                    setState(() {
                      products = list;
                    });
                  },
                  onCategoryChanged: (_) {},
                  trayController: TextEditingController(),
                  quantityController: TextEditingController(),
                  countController: TextEditingController(),
                  neccController: TextEditingController(),
                  minusController: TextEditingController(),
                  rateController: TextEditingController(),
                  loadingController: loadingController,
                  unloadingController: unloadingController,
                  transportController: transportController,
                  miscController: miscController,
                ),
                SizedBox(height: size.height * 0.02),

                // Purchase Employee Card
                PurchaseEmployeecard(
                  driverController: driverController,
                  branchController: branchController,
                  numberController: numberController,
                  typeController: typeController,
                  contactController: contactController,
                  descriptionController: descriptionController,
                ),
                SizedBox(height: size.height * 0.02),

                // Choose Payment Section
                _buildChoosePaymentSection(size),
                SizedBox(height: size.height * 0.02),

                // Summary Section
                _buildPurchaseSummaryCard(size),
                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPaymentSummaryCard() {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 8,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFFE2E8F0),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            "Total Amount",
             "₹ ${totalAmount.toStringAsFixed(2)}",
            Colors.black87,
          ),
        ),

        Container(
          width: 1,
          height: 40,
          color: const Color(0xFFE2E8F0),
        ),

        Expanded(
          child: _buildSummaryItem(
            "Paid Amount",
             "₹ ${paidAmount.toStringAsFixed(2)}",
            Colors.green,
          ),
        ),

        Container(
          width: 1,
          height: 40,
          color: const Color(0xFFE2E8F0),
        ),

        Expanded(
          child: _buildSummaryItem(
            "Balance Debit",
          "₹ ${balanceAmount.toStringAsFixed(2)}",
            Colors.red,
          ),
        ),
      ],
    ),
  );
}


Widget _buildSummaryItem(
  String title,
  String amount,
  Color amountColor,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        amount,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: amountColor,
        ),
      ),
    ],
  );
}

  Widget _buildChoosePaymentSection(Size size) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        const Icon(
          Icons.payment_outlined,
          color: AppColors.blueAccent,
        ),
        SizedBox(width: size.width * 0.02),
        const Text(
          "Choose Payment",
          style: AppTextStyles.headingText20,
        ),
      ],
    ),

    InkWell(
      onTap: _addPaymentRow,
      child: const Row(
        children: [
          Icon(
            Icons.add,
            size: 18,
            color: Color(0xFFFFC107),
          ),
          SizedBox(width: 4),
          Text(
            "Add Payment",
            style: TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  ],
),
          SizedBox(height: size.height * 0.02),
          const Divider(),
          _buildPaymentSummaryCard(),
          SizedBox(height: size.height * 0.01),
         
         
          SizedBox(height: size.height * 0.02),
          
          ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: _payments.length,
  itemBuilder: (context, index) {
    final p = _payments[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
 Align(
  alignment: Alignment.centerRight,
  child: _payments.length > 1
      ? IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.red,
            size: 18,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(() {
              _payments.removeAt(index);
            });
          },
        )
      : const SizedBox(),
),
Row(
  children: [
    Expanded(
      child: _buildDropdownField(
        "Method",
        p.method,
        ["Cash", "UPI", "Card", "RTGS/NEFT", "Credit"],
        (value) => _handlePaymentChange(
          p.id,
          'method',
          value,
        ),
      ),
    ),

    SizedBox(
      width: getWidth(context, 10),
    ),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Amount (₹) *",
            style: TextStyle(
              fontSize: getWidth(context, 11),
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(
            height: getHeight(context, 6),
          ),

          SizedBox(
            height: getHeight(context, 40),
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (val) => _handlePaymentChange(
                p.id,
                'amount',
                val,
              ),
              style: TextStyle(
                fontSize: getWidth(context, 13),
              ),
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: TextStyle(
                  fontSize: getWidth(context, 12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: getWidth(context, 10),
                  vertical: getHeight(context, 8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    getWidth(context, 8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
)     ],
      ),
    );
  },
),

          // Conditional UI based on active tab
       ],
      ),
    );
  }




  Widget _buildPurchaseSummaryCard(Size size) {
    final double _ = getProductTotal();
    getAdditionalTotal();
    final double totalCost = getTotalCost();
    final double _ = getTotalTrays();
    getCostPerTray();
    final int totalEggsCount = products.fold(
  0,
  (sum, p) => sum + (int.tryParse(p.totalEggs) ?? 0),
);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Purchase Summary",
              style: AppTextStyles.headingText25,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Center(
            child: Text(
              "PURCHASE INFO",
              style: AppTextStyles.bodyText16,
            ),
          ),
          const Divider(),
          _buildRow("Supplier", selectedSupplierName),
          _buildRow("Location", originLocation),
          
_buildColumnRow(
  "Products",
  products
      .map((p) => "${p.category} (${p.totalEggs})")
      .toList(),
),

_buildColumnRow(
  "Rate per Egg",
  products
      .map((p) => "₹ ${p.rate}")
      .toList(),
),
const SizedBox(height: 8),

        
          
           _buildRow("Total Eggs", totalEggsCount.toString()),
           SizedBox(height: size.height * 0.02),
            Center(
            child: Text(
              "AMOUNT SUMMARY",
              style: AppTextStyles.bodyText16,
            ),
          ),
          const Divider(),
           SizedBox(height: size.height * 0.02),
          _buildRow("Subtotal", "₹ ${totalCost.toStringAsFixed(2)}"),
          
           SizedBox(height: size.height * 0.02),
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 1,
                  color: index % 2 == 0 ? Colors.grey : Colors.transparent,
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: AppTextStyles.headingText22,
              ),
              Text(
                "₹ ${totalCost.toStringAsFixed(2)}",
                style: AppTextStyles.blueText2,
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
           Center(
            child: Text(
              "PAYMENT BREAKDOWN",
              style: AppTextStyles.bodyText16,
            ),
          ),
          const Divider(),
           _buildRow("Credit/Pending", "₹ ${totalCost.toStringAsFixed(2)}"),
          const SizedBox(height: 16),
          Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.containerColor,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: [
      _buildRow(
        "Paid Amount",
        "₹ ${paidAmount.toStringAsFixed(2)}",
        valueColor: Colors.green
        
      ),

      const SizedBox(height: 8),

      _buildRow(
        "Pending Amount",
        "₹ ${pendingAmount.toStringAsFixed(2)}",
         valueColor: Colors.red
      ),

      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(thickness: 1),
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Final Total",
            style: AppTextStyles.headingText20,
          ),
          Text(
            "₹ ${totalCost.toStringAsFixed(2)}",
            style: AppTextStyles.headingText16,
          ),
        ],
      ),
    ],
  ),
),
SizedBox(height: size.height * 0.02),
          
          // Submit Buttons
          BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              if (state is PurchaseSubmitting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.amber600,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _submitForm(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.check_circle_outline, color: AppColors.dark),
                      label: Text(
                        "Submit Purchase Entry",
                        style: AppTextStyles.headingText20,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.containerColor,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _submitForm(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.save_outlined, color: AppColors.dark),
                      label: Text(
                        "Save as Draft",
                        style: AppTextStyles.headingText20,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text("Stock will be marked as 'incoming' upon\nsubmission", style: AppTextStyles.formInputs15),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, {
  Color valueColor = Colors.black,
}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.formInputs15),
          Text(
            value.isEmpty ? "--" : value,
            style: AppTextStyles.headingText16.copyWith(color: valueColor,
              ),
          ),
        ],
      ),
    );
  }

Widget _buildColumnRow(String title, List<String> values) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.formInputs15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: values.map((value) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                value.isEmpty ? "--" : value,
                style: AppTextStyles.headingText16
            ));
          }).toList(),
        ),
      ],
    ),
  );
}
Widget _buildDropdownField(
  String label,
  String? value,
  List<String> items,
  ValueChanged<String?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value?.isEmpty == true ? null : value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

}