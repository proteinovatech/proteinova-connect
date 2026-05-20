import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

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
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _submitForm(bool isDraft) {
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Bill download started..."), backgroundColor: Colors.green),
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseSubmitSuccess) {
          final isDraft = activePaymentTab == "UPI" && paymentAmountController.text == "0" && debtAmountController.text == "0";
          _showSuccessPopup(isDraft, "PO-${DateTime.now().millisecondsSinceEpoch % 100000}", getTotalCost());
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
            children: [
              const Icon(Icons.payment_outlined, color: AppColors.blueAccent),
              SizedBox(width: size.width * 0.02),
              const Text(
                "Choose Payment",
                style: AppTextStyles.headingText20,
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          const Divider(),
          SizedBox(height: size.height * 0.01),
          
          // Payment Method Tabs
          Row(
            children: [
              Expanded(child: _buildPaymentTab("UPI", Icons.phone_android_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _buildPaymentTab("COD", Icons.money)),
              const SizedBox(width: 8),
              Expanded(child: _buildPaymentTab("RTGS", Icons.account_balance_outlined)),
            ],
          ),
          SizedBox(height: size.height * 0.02),

          // Conditional UI based on active tab
          if (activePaymentTab == "UPI") ...[
            const Text("Select UPI App", style: AppTextStyles.buttonText16),
            SizedBox(height: size.height * 0.01),
            Row(
              children: [
                Expanded(child: _buildUpiAppButton("Google Pay")),
                const SizedBox(width: 6),
                Expanded(child: _buildUpiAppButton("PhonePe")),
                const SizedBox(width: 6),
                Expanded(child: _buildUpiAppButton("Paytm")),
                const SizedBox(width: 6),
                Expanded(child: _buildUpiAppButton("Other")),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            const Text("Transaction Reference", style: AppTextStyles.buttonText16),
            SizedBox(height: size.height * 0.01),
            _buildTextField(
              controller: otherUpiDetailsController,
              hint: "UPI ID or Reference No.",
              icon: Icons.vpn_key_outlined,
            ),
            SizedBox(height: size.height * 0.02),
          ],

          if (activePaymentTab == "RTGS") ...[
            const Text("Transaction Reference", style: AppTextStyles.buttonText16),
            SizedBox(height: size.height * 0.01),
            _buildTextField(
              controller: otherUpiDetailsController,
              hint: "RTGS/NEFT Transaction ID",
              icon: Icons.receipt_long_outlined,
            ),
            SizedBox(height: size.height * 0.02),
          ],

          // Payment amount and debt inputs
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Payment Amount", style: AppTextStyles.buttonText16),
                    SizedBox(height: size.height * 0.01),
                    _buildTextField(
                      controller: paymentAmountController,
                      hint: "Enter amount paid",
                      isNumeric: true,
                      prefixText: "₹ ",
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Debt (Optional)", style: AppTextStyles.buttonText16),
                    SizedBox(height: size.height * 0.01),
                    _buildTextField(
                      controller: debtAmountController,
                      hint: "Enter remaining debt",
                      isNumeric: true,
                      prefixText: "₹ ",
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

  Widget _buildPaymentTab(String title, IconData icon) {
    final bool isSelected = activePaymentTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          activePaymentTab = title;
        });
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.amber600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.amber600 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black87),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTextStyles.bodyText13.copyWith(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiAppButton(String title) {
    final bool isSelected = selectedUpiApp == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUpiApp = title;
        });
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueAccent : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.blueAccent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyText13.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumeric = false,
    String? prefixText,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.containerColor,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
            : [],
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixText: prefixText,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.light, size: 18) : null,
        ),
      ),
    );
  }

  Widget _buildPurchaseSummaryCard(Size size) {
    // ignore: unused_local_variable
    final double productTotal = getProductTotal();
    final double additionalTotal = getAdditionalTotal();
    final double totalCost = getTotalCost();
    // ignore: unused_local_variable
    final double trays = getTotalTrays();
    final double perTray = getCostPerTray();

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
          Text(
            "Purchase Summary",
            style: AppTextStyles.headingText25,
          ),
          SizedBox(height: size.height * 0.01),
          _buildRow("Supplier", selectedSupplierName),
          _buildRow("Location", originLocation),
          const Divider(),
          Text(
            "Products Summary",
            style: AppTextStyles.formInputs15dark,
          ),
          SizedBox(height: size.height * 0.01),
          ...products.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildRow("Category", p.category),
                  _buildRow("Trays", p.quantity),
                  _buildRow("Rate per Egg", "₹ ${p.rate}"),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          Text(
            "Additional Costs",
            style: AppTextStyles.formInputs15dark,
          ),
          _buildRow("Loading Charges", "₹ ${loadingController.text}"),
          _buildRow("Unloading Charges", "₹ ${unloadingController.text}"),
          _buildRow("Transport Charges", "₹ ${transportController.text}"),
          _buildRow("Misc Expense", "₹ ${miscController.text}"),
          _buildRow("Total Additional Cost", "₹ ${additionalTotal.toStringAsFixed(2)}"),
          _buildRow("Cost per Tray", "₹ ${perTray.toStringAsFixed(2)}"),
          const SizedBox(height: 12),
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
                "Total Estimated Cost",
                style: AppTextStyles.headingText22,
              ),
              Text(
                "₹ ${totalCost.toStringAsFixed(2)}",
                style: AppTextStyles.blueText2,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
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

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.formInputs15),
          Text(
            value.isEmpty ? "--" : value,
            style: AppTextStyles.bodyText16,
          ),
        ],
      ),
    );
  }
}
