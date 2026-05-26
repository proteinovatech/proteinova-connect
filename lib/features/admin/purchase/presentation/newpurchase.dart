import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';

import '../bloc/purchase/purchase_bloc.dart';
import '../bloc/purchase/purchase_event.dart';
import '../bloc/purchase/purchase_state.dart';
import '../data/models/purchase_model.dart';
import '../data/models/product_input_model.dart';
import '../widget/add_supplier_pop.dart';
import '../bloc/supplier/supplier_bloc.dart';
import '../bloc/supplier/supplier_event.dart';
import '../bloc/supplier/supplier_state.dart';
import '../data/models/supplier_model.dart';

class Newpurchase extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? purchaseData;

  const Newpurchase({super.key, this.isEdit = false, this.purchaseData});

  @override
  State<Newpurchase> createState() => _NewpurchaseState();
}

class _NewpurchaseState extends State<Newpurchase> {
  // Supplier & Location details
  SupplierModel? selectedSupplier;
  String originLocation = "";
  DateTime? expectedArrivalDate;
  final TextEditingController brokerNameController = TextEditingController();
  final TextEditingController brokerNumController = TextEditingController();

  // Product specification
  List<ProductInput> products = [ProductInput()];

  // Additional costs
  final TextEditingController loadingController = TextEditingController(text: "0");
  final TextEditingController unloadingController = TextEditingController(text: "0");
  final TextEditingController transportController = TextEditingController(text: "0");
  final TextEditingController miscController = TextEditingController(text: "0");
  final TextEditingController brokerFeeController = TextEditingController(text: "0");

  // Purchase employee details
  final TextEditingController driverController = TextEditingController();
  final TextEditingController reachingWarehouseController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController driverContactController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Dynamic Payments
  List<Map<String, dynamic>> payments = [
    {
      "id": "1",
      "method": "Cash",
      "amount": "",
      "app": "",
      "reference": "",
      "notes": ""
    }
  ];

  // Namakkal Stocks
  int namakkalStock = 0;
  int namakkalPaperStock = 0;

  final List<String> eggCategories = [
    "White large",
    "White correct size",
    "white export",
    "white medium",
    "white pullet",
    "white small eggs",
    "Brown eggs",
    "country eggs",
    "quail eggs",
    "duck eggs"
  ];

  @override
  void initState() {
    super.initState();
    _fetchTrayStock();
    context.read<SupplierBloc>().add(FetchSuppliers());

    loadingController.addListener(_refresh);
    unloadingController.addListener(_refresh);
    transportController.addListener(_refresh);
    miscController.addListener(_refresh);
    brokerFeeController.addListener(_refresh);
  }

  @override
  void dispose() {
    loadingController.dispose();
    unloadingController.dispose();
    transportController.dispose();
    miscController.dispose();
    brokerFeeController.dispose();
    brokerNameController.dispose();
    brokerNumController.dispose();
    driverController.dispose();
    reachingWarehouseController.dispose();
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    driverContactController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchTrayStock() async {
    try {
      final res = await DioClient().dio.get("/api/tray-inventory/get-inventory");
      if (res.data != null && res.data["success"] == true) {
        final data = res.data["data"] as List;
        final namakkal = data.firstWhere(
          (item) => item["location_name"] == "Namakkal",
          orElse: () => null,
        );
        if (namakkal != null) {
          setState(() {
            namakkalStock = int.tryParse(namakkal["plastic_tray_count"].toString()) ?? 0;
            namakkalPaperStock = int.tryParse(namakkal["paper_tray_count"].toString()) ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching tray stock: $e");
    }
  }

  double getProductSubtotal() {
    double total = 0;
    for (var p in products) {
      final qty = double.tryParse(p.quantity) ?? 0;
      final necc = double.tryParse(p.necc) ?? 0;
      final minus = double.tryParse(p.minus) ?? 0;
      final finalRate = necc - minus;
      total += qty * 30 * finalRate;
    }
    return total;
  }

  double getAdditionalTotal() {
    final load = double.tryParse(loadingController.text) ?? 0;
    final unload = double.tryParse(unloadingController.text) ?? 0;
    final trans = double.tryParse(transportController.text) ?? 0;
    final misc = double.tryParse(miscController.text) ?? 0;
    final broker = double.tryParse(brokerFeeController.text) ?? 0;
    return load + unload + trans + misc + broker;
  }

  double getTotalAmount() {
    return getProductSubtotal() + getAdditionalTotal();
  }

  double getPaidAmount() {
    return payments
        .where((p) => p["method"] != "Credit")
        .fold(0.0, (sum, p) => sum + (double.tryParse(p["amount"].toString()) ?? 0.0));
  }

  double getDebtAmount() {
    return payments
        .where((p) => p["method"] == "Credit")
        .fold(0.0, (sum, p) => sum + (double.tryParse(p["amount"].toString()) ?? 0.0));
  }

  double getBalanceAmount() {
    return getTotalAmount() - getPaidAmount();
  }

  void _addPaymentRow() {
    setState(() {
      payments.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "method": "Cash",
        "amount": "",
        "app": "",
        "reference": "",
        "notes": ""
      });
    });
  }

  void _removePaymentRow(String id) {
    if (payments.length > 1) {
      setState(() {
        payments.removeWhere((p) => p["id"] == id);
      });
    }
  }

  void _submitForm(bool isDraft) {
    if (selectedSupplier == null) {
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

    final String brokerNum = brokerNumController.text.trim();
    if (brokerNum.isNotEmpty && brokerNum.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Broker number must be exactly 10 digits"), backgroundColor: Colors.red),
      );
      return;
    }

    final String driverNum = driverContactController.text.trim();
    if (driverNum.isNotEmpty && driverNum.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver number must be exactly 10 digits"), backgroundColor: Colors.red),
      );
      return;
    }

    final isSplit = payments.length > 1;
    final finalMethod = isSplit ? "SPLIT" : payments[0]["method"];
    final upiApp = (!isSplit && payments[0]["method"] == "UPI") ? payments[0]["app"] : null;
    final otherUpi = jsonEncode(payments);

    final purchase = PurchaseRequest(
      supplierId: selectedSupplier!.id,
      supplierName: selectedSupplier!.companyName,
      location: originLocation,
      warehouseLocation: reachingWarehouseController.text,
      expectedArrival: expectedArrivalDate != null
          ? DateFormat('yyyy-MM-dd').format(expectedArrivalDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      driverName: driverController.text,
      driverNumber: driverNum,
      vehicleNumber: vehicleNumberController.text,
      vehicleType: vehicleTypeController.text,
      loadingCharge: double.tryParse(loadingController.text) ?? 0,
      unloadingCharge: double.tryParse(unloadingController.text) ?? 0,
      transportCharge: double.tryParse(transportController.text) ?? 0,
      miscExpense: double.tryParse(miscController.text) ?? 0,
      purchaseStatus: isDraft ? "PENDING" : "PURCHASED",
      brokerFee: double.tryParse(brokerFeeController.text) ?? 0,
      brokerNumber: brokerNum,
      brokerName: brokerNameController.text,
      description: descriptionController.text,
      paymentMethod: finalMethod,
      upiApp: upiApp,
      otherUpiDetails: otherUpi,
      paymentAmount: getPaidAmount(),
      debtAmount: getDebtAmount(),
      items: products.map((p) {
        final double necc = double.tryParse(p.necc) ?? 0.0;
        final double minus = double.tryParse(p.minus) ?? 0.0;
        final double finalRate = necc - minus;
        return PurchaseItem(
          eggCategoryGrade: p.category,
          trays: int.tryParse(p.quantity) ?? 0,
          capacity: 30,
          perEggPrice: finalRate,
          marketPriceMinus: minus,
          neccRate: necc,
          trayType: p.trayType,
        );
      }).toList(),
    );

    context.read<PurchaseBloc>().add(SubmitPurchaseEvent(purchase));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 1000;

    return BlocListener<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseSubmitSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessfulScreen(purchaseId: state.purchaseId),
            ),
          );
        } else if (state is PurchaseSubmitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "New Purchase Entry",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manage and receive incoming shipments from suppliers to update inventory",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildFormFields(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _buildSummaryCard(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildFormFields(),
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildSupplierDetailsCard(),
        const SizedBox(height: 24),
        _buildProductCard(),
        const SizedBox(height: 24),
        _buildEmployeeDetailsCard(),
        const SizedBox(height: 24),
        _buildPaymentDetailsCard(),
      ],
    );
  }

  Widget _buildSupplierDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_shipping_outlined, color: AppColors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Supplier & Location Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BlocBuilder<SupplierBloc, SupplierState>(
            builder: (context, state) {
              List<SupplierModel> suppliers = [];
              if (state is SupplierLoaded) {
                suppliers = state.suppliers.map((s) => SupplierModel(
                  id: s.id,
                  companyName: s.companyName,
                  supplierName: s.supplierName,
                  email: s.email,
                  phoneNumber: s.phoneNumber,
                  location: s.location,
                  status: s.status,
                )).toList();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Supplier Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SupplierModel>(
                        value: selectedSupplier,
                        isExpanded: true,
                        hint: const Text("Select Supplier"),
                        items: suppliers.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.companyName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedSupplier = val;
                            originLocation = val?.location ?? "";
                          });
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AddSupplierPopup(),
                );
                // Refresh list
                if (mounted) {
                  context.read<SupplierBloc>().add(FetchSuppliers());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add New Supplier"),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Origin Location", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        originLocation.isEmpty ? "Auto-filled based on supplier" : originLocation,
                        style: TextStyle(color: originLocation.isEmpty ? Colors.grey : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Expected Arrival Date", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            expectedArrivalDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              expectedArrivalDate == null
                                  ? "Select Date"
                                  : DateFormat('yyyy-MM-dd').format(expectedArrivalDate!),
                            ),
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Broker Name", brokerNameController, hint: "Enter Broker Name"),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  "Broker Number",
                  brokerNumController,
                  hint: "Enter Broker Number",
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.inventory_2_outlined, color: AppColors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Product Specifications",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB), size: 28),
                onPressed: () {
                  setState(() {
                    products.add(ProductInput());
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, idx) {
              final p = products[idx];
              final totalEggs = (int.tryParse(p.quantity) ?? 0) * 30;
              final double necc = double.tryParse(p.necc) ?? 0.0;
              final double minus = double.tryParse(p.minus) ?? 0.0;
              final double finalRate = necc - minus;

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Product ${idx + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        if (products.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                products.removeAt(idx);
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Egg Category & Grade", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: p.category.isEmpty ? null : p.category,
                                    isExpanded: true,
                                    hint: const Text("Select Category"),
                                    items: eggCategories.map((c) {
                                      return DropdownMenuItem(value: c, child: Text(c));
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        p.category = val ?? "";
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Number Trays", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  hintText: "Trays",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    p.quantity = val;
                                    p.totalEggs = ((int.tryParse(val) ?? 0) * 30).toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Total Eggs (Auto)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDF2F7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(totalEggs.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("NECC Rate (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              TextField(
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                decoration: InputDecoration(
                                  hintText: "Rate",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    p.necc = val;
                                    p.rate = (finalRate).toStringAsFixed(2);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Market Minus (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              TextField(
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                decoration: InputDecoration(
                                  hintText: "Minus",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    p.minus = val;
                                    p.rate = (finalRate).toStringAsFixed(2);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Final Rate (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDF2F7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text("₹ ${finalRate.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tray Type", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: p.trayType.isEmpty ? null : p.trayType,
                              isExpanded: true,
                              hint: const Text("Select Tray Type"),
                              items: [
                                DropdownMenuItem(value: "Paper Tray", child: Text("Paper Tray (Stock: $namakkalPaperStock)")),
                                DropdownMenuItem(value: "Plastic Tray", child: Text("Plastic Tray (Stock: $namakkalStock)")),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  p.trayType = val ?? "";
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person_pin_outlined, color: AppColors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Purchase Employee Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Driver Name", driverController, hint: "Enter driver name"),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Reaching Warehouse", reachingWarehouseController, hint: "Enter warehouse location"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Vehicle Number", vehicleNumberController, hint: "e.g. TN 01 AB 1234"),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Vehicle Type", vehicleTypeController, hint: "e.g. Truck"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            "Driver Contact Number",
            driverContactController,
            hint: "Enter 10-digit number",
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField("Additional Notes", descriptionController, hint: "Enter notes"),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    final double totalAmt = getTotalAmount();
    final double paidAmt = getPaidAmount();
    final double balanceAmt = getBalanceAmount();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.payment, color: AppColors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Payment Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _addPaymentRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2F6),
                  foregroundColor: const Color(0xFF4338CA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add Payment"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("TOTAL AMOUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("₹ ${totalAmt.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                Column(
                  children: [
                    const Text("PAID AMOUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("₹ ${paidAmt.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                Column(
                  children: [
                    const Text("BALANCE / DEBT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("₹ ${balanceAmt.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final pay = payments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Method", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: pay["method"],
                                        isExpanded: true,
                                        items: ["Cash", "UPI", "Card", "RTGS/NEFT", "Credit"].map((m) {
                                          return DropdownMenuItem(value: m, child: Text(m));
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            pay["method"] = val ?? "Cash";
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Amount (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    decoration: InputDecoration(
                                      hintText: "0.00",
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        pay["amount"] = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (pay["method"] == "UPI") ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("UPI App", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: pay["app"].toString().isEmpty ? null : pay["app"],
                                          isExpanded: true,
                                          hint: const Text("Select App"),
                                          items: ["Google Pay", "PhonePe", "Paytm", "Other"].map((app) {
                                            return DropdownMenuItem(value: app, child: Text(app));
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              pay["app"] = val ?? "";
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Reference No.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: "Txn ID",
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          pay["reference"] = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (pay["method"] == "RTGS/NEFT" || pay["method"] == "Card") ...[
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Reference No.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Txn ID or Ref",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    pay["reference"] = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                        if (pay["method"] == "Credit") ...[
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Debt Notes", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(height: 6),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Notes",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    pay["notes"] = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    if (payments.length > 1)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: InkWell(
                          onTap: () => _removePaymentRow(pay["id"]),
                          child: const Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final double subtotal = getProductSubtotal();
    final double addTotal = getAdditionalTotal();
    final double grandTotal = getTotalAmount();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Purchase Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          _buildSummaryRow("Supplier", selectedSupplier?.companyName ?? "-"),
          _buildSummaryRow("Location", originLocation.isEmpty ? "-" : originLocation),
          const Divider(height: 24),
          const Text("Products", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          ...products.map((p) {
            final qty = int.tryParse(p.quantity) ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(p.category.isEmpty ? "Egg Product" : p.category, style: const TextStyle(fontSize: 13))),
                  Text("$qty Trays (${qty * 30} Eggs)", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 24),
          _buildSummaryRow("Subtotal", "₹ ${subtotal.toStringAsFixed(2)}"),
          if (addTotal > 0)
            _buildSummaryRow("Additional Charges", "₹ ${addTotal.toStringAsFixed(2)}"),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Cost", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
              Text("₹ ${grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 32),
          BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              if (state is PurchaseSubmitting) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _submitForm(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text("Submit Purchase Entry", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _submitForm(true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Save as Draft", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }
}

class PaymentSuccessfulScreen extends StatefulWidget {
  final int purchaseId;
  const PaymentSuccessfulScreen({super.key, required this.purchaseId});

  @override
  State<PaymentSuccessfulScreen> createState() => _PaymentSuccessfulScreenState();
}

class _PaymentSuccessfulScreenState extends State<PaymentSuccessfulScreen> {
  Map<String, dynamic>? purchase;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPurchase();
  }

  Future<void> _fetchPurchase() async {
    try {
      final res = await DioClient().dio.get("/api/purchase/${widget.purchaseId}");
      if (res.data != null && res.data["data"] != null) {
        setState(() {
          purchase = res.data["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching purchase details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalTrays = int.tryParse(purchase?["total_trays"]?.toString() ?? "0") ?? 0;
    final totalEggs = totalTrays * (int.tryParse(purchase?["capacity"]?.toString() ?? "30") ?? 30);
    final finalRate = (double.tryParse(purchase?["per_egg_price"]?.toString() ?? "0.0") ?? 0.0) -
        (double.tryParse(purchase?["market_price_minus"]?.toString() ?? "0.0") ?? 0.0);

    final double loadingCharge = double.tryParse(purchase?["loading_charge"]?.toString() ?? "0.0") ?? 0.0;
    final double unloadingCharge = double.tryParse(purchase?["unloading_charge"]?.toString() ?? "0.0") ?? 0.0;
    final double transportCharge = double.tryParse(purchase?["transport_charge"]?.toString() ?? "0.0") ?? 0.0;
    final double miscExpense = double.tryParse(purchase?["misc_expense"]?.toString() ?? "0.0") ?? 0.0;

    final additionalCost = loadingCharge + unloadingCharge + transportCharge + miscExpense;
    final totalAmount = totalEggs * finalRate + additionalCost;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Color(0xFF16A34A), size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Purchase Order Created",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your purchase entry has been successfully recorded and added to the incoming stock queue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildRow("Order Reference", "PO-${purchase?["id"] ?? widget.purchaseId}"),
                      _buildRow("Supplier", purchase?["supplier_company_name"] ?? "-"),
                      _buildRow("Product", purchase?["egg_category_grade"] ?? "-"),
                      _buildRow("Total Quantity", "$totalTrays Tray"),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Cost", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text("₹ ${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text("Back to Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Newpurchase()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Create Another Purchase", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
