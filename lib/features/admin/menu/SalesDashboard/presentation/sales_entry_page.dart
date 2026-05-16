import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/data/datasource/sales_remote_datasource.dart';
import 'package:proteinova_connect/features/branch/sales/data/model/sales_entry_model.dart';
import 'package:proteinova_connect/features/branch/sales/data/model/sales_item_model.dart';
import 'package:proteinova_connect/core/services/sales_receipt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaleTray {
  String trayType;
  int qty;
  SaleTray({this.trayType = "without tray", this.qty = 0});
}

class AdminOfferModel {
  final int id;
  final String name;
  final String category;
  final String offerType;
  final double buyQty;
  final double freeQty;
  final double discountValue;
  bool applied;

  AdminOfferModel({
    required this.id,
    required this.name,
    required this.category,
    required this.offerType,
    required this.buyQty,
    required this.freeQty,
    required this.discountValue,
    this.applied = false,
  });
}

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({super.key});

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  // --- State Variables ---
  String selectedBranchId = "warehouse";
  String soldLocation = "Warehouse";
  List<Map<String, dynamic>> branches = [];
  
  Map<String, dynamic>? headerData;
  List<ProductDetail> products = [];
  List<AdminOfferModel> offers = [];
  List<SalesItem> salesItems = [SalesItem()];
  List<SaleTray> saleTrays = [SaleTray()];
  
  bool isLoading = true;
  bool offersLoading = true;
  bool isSubmitting = false;
  String? customerStatus; // 'found', 'not_found', null
  
  String selectedPaymentMethod = "CASH";
  String soldTo = "Retail";
  
  final TextEditingController customerNumberController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController cashReceivedController = TextEditingController();
  final TextEditingController debtController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final SalesRemoteDatasource datasource = SalesRemoteDatasource();
  List<ProductDetail> filteredProducts = [];
  int loginUserId = 1;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getInt('user_id') ?? 1;
    await _fetchBranches();
    await _fetchOffers();
    await _fetchSalesEntryData();
  }

  Future<void> _fetchBranches() async {
    try {
      final res = await datasource.getBranches();
      if (mounted) {
        setState(() {
          branches = List<Map<String, dynamic>>.from(res['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error fetching branches: $e");
    }
  }

  Future<void> _fetchOffers() async {
    try {
      if (mounted) setState(() => offersLoading = true);
      final res = await datasource.getOffers();
      if (res['success'] == true && res['data'] != null) {
        final List list = res['data']['offers_list'] ?? [];
        if (mounted) {
          setState(() {
            offers = list.where((o) => o['status'] == 'active').map((o) => AdminOfferModel(
              id: int.tryParse(o['id'].toString()) ?? 0,
              name: o['offer_name'] ?? "",
              category: o['product_name'] ?? "All Products",
              offerType: o['offer_type'] ?? "fixed_amount",
              buyQty: double.tryParse(o['buy_qty'].toString()) ?? 0,
              freeQty: double.tryParse(o['free_qty'].toString()) ?? 0,
              discountValue: double.tryParse(o['discount_value'].toString()) ?? 0,
            )).toList();
            offersLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching offers: $e");
      if (mounted) setState(() => offersLoading = false);
    }
  }

  Future<void> _fetchSalesEntryData() async {
    try {
      if (mounted) setState(() => isLoading = true);
      final res = await datasource.getSalesEntry(
        loginUserId: loginUserId,
        branchId: selectedBranchId == "warehouse" ? null : int.tryParse(selectedBranchId),
      );
      
      if (mounted) {
        setState(() {
          headerData = res['header'];
          if (res['header']?['sales_happen'] == "In_warehouse") {
            soldLocation = "Warehouse";
          } else {
            soldLocation = res['header']?['branch_name'] ?? "Branch";
          }
          
          products = (res['product_details'] as List? ?? [])
              .map((e) => ProductDetail.fromJson(e))
              .toList();
          filteredProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching sales entry data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- Calculations ---
  double get subtotal => salesItems.fold(0.0, (sum, item) => sum + item.total);

  double get totalDiscount {
    double discount = 0;
    final totalEggsInCart = salesItems.fold(0, (sum, item) => sum + item.eggs);

    for (var offer in offers) {
      if (!offer.applied) continue;

      final isAllProducts = offer.category == "All Products";
      final matchingItem = isAllProducts ? null : salesItems.where((item) =>
        item.eggCategoryGrade.trim().toLowerCase() == offer.category.trim().toLowerCase()
      ).firstOrNull;

      if (!isAllProducts && matchingItem == null) continue;

      if (offer.offerType == 'buy_x_get_y') {
        final double relevantEggs = isAllProducts ? totalEggsInCart.toDouble() : (matchingItem?.eggs.toDouble() ?? 0);
        final double pricePerEgg = isAllProducts ? (salesItems.isNotEmpty ? salesItems.first.price : 0) : (matchingItem?.price ?? 0);

        if (relevantEggs >= offer.buyQty && offer.buyQty > 0) {
          final double freeEggsCount = (relevantEggs ~/ offer.buyQty) * offer.freeQty;
          discount += double.parse((freeEggsCount * pricePerEgg).toStringAsFixed(2));
        }
      } else if (offer.offerType == 'percentage') {
        final double relevantTotal = isAllProducts ? subtotal : (matchingItem?.total ?? 0);
        discount += (relevantTotal * offer.discountValue) / 100;
      } else if (offer.offerType == 'fixed_amount') {
        discount += offer.discountValue;
      }
    }
    return double.parse(discount.toStringAsFixed(2));
  }

  double get totalAmount => subtotal - totalDiscount;

  // --- Actions ---
  void addItem() {
    setState(() => salesItems.add(SalesItem()));
  }

  void removeItem(int index) {
    setState(() {
      salesItems.removeAt(index);
      if (salesItems.isEmpty) salesItems.add(SalesItem());
    });
  }

  void updateItem(int index, String field, dynamic value) {
    setState(() {
      final item = salesItems[index];
      if (field == 'product') {
        final product = products.firstWhere((p) => p.productName == value);
        item.eggCategoryGrade = product.productName;
        item.price = product.perTrayPrice / 30;
        item.calculateEggs();
      } else if (field == 'dozen') {
        item.dozen = double.tryParse(value.toString()) ?? 0;
        item.calculateEggs();
        item.trays = (item.eggs / 30).ceil();
      } else if (field == 'trays') {
        item.trays = int.tryParse(value.toString()) ?? 0;
        item.eggs = item.trays * 30;
        item.dozen = double.parse((item.eggs / 12).toStringAsFixed(2));
        item.total = double.parse((item.eggs * item.price).toStringAsFixed(2));
      }
    });
  }

  void addProductFromCard(ProductDetail product) {
    setState(() {
      final existingIndex = salesItems.indexWhere((i) => i.eggCategoryGrade == product.productName);
      if (existingIndex != -1) {
        salesItems[existingIndex].trays += 1;
        salesItems[existingIndex].eggs = salesItems[existingIndex].trays * 30;
        salesItems[existingIndex].dozen = double.parse((salesItems[existingIndex].eggs / 12).toStringAsFixed(2));
        salesItems[existingIndex].total = double.parse((salesItems[existingIndex].eggs * (product.perTrayPrice / 30)).toStringAsFixed(2));
      } else {
        if (salesItems.length == 1 && salesItems[0].eggCategoryGrade == "") {
          salesItems[0] = SalesItem(
            eggCategoryGrade: product.productName,
            price: product.perTrayPrice / 30,
            trays: 1,
            eggs: 30,
            dozen: 2.5,
            total: product.perTrayPrice,
          );
        } else {
          salesItems.add(SalesItem(
            eggCategoryGrade: product.productName,
            price: product.perTrayPrice / 30,
            trays: 1,
            eggs: 30,
            dozen: 2.5,
            total: product.perTrayPrice,
          ));
        }
      }
    });
  }

  Future<void> lookupCustomer(String number) async {
    if (number.length < 10) return;
    try {
      final res = await datasource.getCustomerByNumber(number);
      if (res != null && res['customer'] != null) {
        setState(() {
          customerNameController.text = res['customer']['name'] ?? "";
          customerStatus = 'found';
        });
      } else {
        setState(() => customerStatus = 'not_found');
      }
    } catch (e) {
      setState(() => customerStatus = 'not_found');
    }
  }

  void toggleOffer(int offerId) {
    setState(() {
      final index = offers.indexWhere((o) => o.id == offerId);
      if (index != -1) {
        offers[index].applied = !offers[index].applied;
      }
    });
  }

  Future<void> handlePayment() async {
    final cName = customerNameController.text.trim();
    final cNumber = customerNumberController.text.trim();

    if (cName.isEmpty && cNumber.isEmpty) {
      _showError("Please enter Customer Name or Number");
      return;
    }

    final validItems = salesItems.where((i) => i.eggCategoryGrade.isNotEmpty).toList();
    if (validItems.isEmpty) {
      _showError("Please add at least one product");
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final payload = {
        "login_user_id": loginUserId,
        "sold_location_id": selectedBranchId == "warehouse" ? null : int.tryParse(selectedBranchId),
        "customer_name": cName.isEmpty ? "Unknown Customer" : cName,
        "customer_number": cNumber.isEmpty ? "N/A" : cNumber,
        "customer_debit": double.tryParse(debtController.text) ?? 0,
        "sales_date": dateController.text,
        "payment_method": selectedPaymentMethod,
        "cash_received": double.tryParse(cashReceivedController.text) ?? 0,
        "sold_to": soldTo,
        "sold_location": soldLocation,
        "notes": notesController.text,
        "applied_offers": offers.where((o) => o.applied).map((o) => o.name).toList(),
        "total_amount": totalAmount,
        "items": validItems.map((i) => {
          "egg_category_grade": i.eggCategoryGrade,
          "dozen": i.dozen,
          "eggs": i.eggs,
          "trays": (i.eggs / 30).ceil(),
          "total": i.total
        }).toList(),
        "sale_trays": saleTrays.where((t) => t.qty > 0).map((t) => {"tray_type": t.trayType, "qty": t.qty}).toList(),
      };

      if (customerStatus == 'not_found' && cNumber.isNotEmpty) {
        await datasource.createCustomer(name: cName.isEmpty ? "Unknown Customer" : cName, number: cNumber);
      }

      final res = await datasource.createSale(body: payload);
      setState(() => isSubmitting = false);
      
      final saleId = res['data']?['id'] ?? res['id'] ?? res['approval_id'] ?? 'N/A';
      final isPending = res['status'] == "PENDING_REVIEW";
      
      _showSuccessPopup(saleId, isPending, validItems);
    } catch (e) {
      setState(() => isSubmitting = false);
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Color(0xFFEF4444), size: 40),
              ),
              const SizedBox(height: 24),
              const Text("Sale Failed", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Try Again", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup(dynamic saleId, bool isPending, List<SalesItem> finalItems) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(
        saleId: saleId.toString(),
        amount: totalAmount,
        isPending: isPending,
        customerName: customerNameController.text,
        customerNumber: customerNumberController.text,
        date: dateController.text,
        items: finalItems,
        discount: totalDiscount,
        subtotal: subtotal,
        paymentMethod: selectedPaymentMethod,
        onNextSale: () {
          Navigator.pop(context);
          setState(() {
            salesItems = [SalesItem()];
            saleTrays = [SaleTray()];
            customerNameController.clear();
            customerNumberController.clear();
            cashReceivedController.clear();
            debtController.clear();
            notesController.clear();
            customerStatus = null;
            for (var o in offers) {
              o.applied = false;
            }
          });
        },
        onDashboard: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 900;
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        _buildSubHeader(),
                        const SizedBox(height: 16),
                        if (isWide) 
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 1, child: Column(children: [
                                _buildTransactionDetailsCard(),
                                const SizedBox(height: 16),
                                _buildProductSelectionCard(),
                              ])),
                              const SizedBox(width: 16),
                              Expanded(flex: 1, child: Column(children: [
                                _buildSalesItemsCard(),
                                const SizedBox(height: 16),
                                _buildTrayTypesCard(),
                                const SizedBox(height: 16),
                                _buildOffersCard(),
                                const SizedBox(height: 16),
                                _buildPaymentAndSummaryGrid(),
                              ])),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildTransactionDetailsCard(),
                              const SizedBox(height: 16),
                              _buildProductSelectionCard(),
                              const SizedBox(height: 16),
                              _buildSalesItemsCard(),
                              const SizedBox(height: 16),
                              _buildTrayTypesCard(),
                              const SizedBox(height: 16),
                              _buildOffersCard(),
                              const SizedBox(height: 16),
                              _buildPaymentAndSummaryGrid(),
                            ],
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Sales Entry",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
              const Icon(Icons.notifications_none, color: Colors.grey),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sales Entry",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Log new sales transactions to automatically update branch inventory.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedBranchId,
                  items: [
                    const DropdownMenuItem(value: "warehouse", child: Text("Main Warehouse")),
                    ...branches.map((b) => DropdownMenuItem(value: b['id'].toString(), child: Text(b['branch_name'] ?? ""))),
                  ],
                  onChanged: (v) {
                    setState(() {
                      selectedBranchId = v!;
                      _fetchSalesEntryData();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionDetailsCard() {
    return _buildCard(
      title: "Transaction Details",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  "Customer Name",
                  customerNameController,
                  hint: "John",
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildInput(
                  "Customer Number",
                  customerNumberController,
                  hint: "9876543210",
                  keyboardType: TextInputType.phone,
                  onChanged: lookupCustomer,
                  suffix: customerStatus == 'found' 
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
                    : customerStatus == 'not_found' 
                      ? const Icon(Icons.person_add, color: Colors.orange, size: 18)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInput(
            "Sales Date",
            dateController,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                dateController.text = DateFormat('yyyy-MM-dd').format(date);
              }
            },
            suffix: const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelectionCard() {
    return _buildCard(
      title: "Product Selection",
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (v) {
              setState(() {
                filteredProducts = products.where((p) => p.productName.toLowerCase().contains(v.toLowerCase())).toList();
              });
            },
            decoration: InputDecoration(
              hintText: "Search product by name",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final p = filteredProducts[index];
              final isOutOfStock = p.stockEggs <= 0;
              return InkWell(
                onTap: isOutOfStock ? null : () => addProductFromCard(p),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text("₹${(p.perTrayPrice / 30).toStringAsFixed(2)} / Egg", style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text("Stock: ${p.stockEggs} eggs", style: TextStyle(fontSize: 11, color: isOutOfStock ? Colors.red : Colors.green, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalesItemsCard() {
    return _buildCard(
      title: "Sales Items",
      trailing: InkWell(
        onTap: addItem,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            color: Colors.grey.shade100,
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text("Product", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Dozen", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text("Trays", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text("Eggs", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text("Total", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                SizedBox(width: 30),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: salesItems.length,
            itemBuilder: (context, index) {
              final item = salesItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: item.eggCategoryGrade.isEmpty ? null : item.eggCategoryGrade,
                          isExpanded: true,
                          hint: const Text("Select", style: TextStyle(fontSize: 11)),
                          items: products.map((p) => DropdownMenuItem(value: p.productName, child: Text(p.productName, style: const TextStyle(fontSize: 11)))).toList(),
                          onChanged: (v) => updateItem(index, 'product', v),
                        ),
                      ),
                    )),
                    const SizedBox(width: 4),
                    Expanded(flex: 2, child: _buildStepper(item.dozen, (v) => updateItem(index, 'dozen', v), isDozen: true)),
                    const SizedBox(width: 4),
                    Expanded(flex: 2, child: _buildStepper(item.trays.toDouble(), (v) => updateItem(index, 'trays', v.toInt()))),
                    const SizedBox(width: 4),
                    Expanded(flex: 1, child: Text("${item.eggs}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text("₹${item.total.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF16A34A), fontSize: 11), textAlign: TextAlign.right)),
                    const SizedBox(width: 4),
                    InkWell(onTap: () => removeItem(index), child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrayTypesCard() {
    return _buildCard(
      title: "Tray Types Used",
      trailing: ElevatedButton.icon(
        onPressed: () => setState(() => saleTrays.add(SaleTray())),
        icon: const Icon(Icons.add, size: 14),
        label: const Text("Add Tray", style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 10)),
      ),
      child: Column(
        children: saleTrays.asMap().entries.map((entry) {
          int idx = entry.key;
          SaleTray tray = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(flex: 3, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tray.trayType,
                      isExpanded: true,
                      items: ["without tray", "Empty paper tray", "Empty plastic tray", "Plastic tray (With egg)", "Paper tray (with egg)"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) => setState(() => tray.trayType = v!),
                    ),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _buildStepper(tray.qty.toDouble(), (v) => setState(() => tray.qty = v.toInt()))),
                if (saleTrays.length > 1) ...[
                  const SizedBox(width: 10),
                  InkWell(onTap: () => setState(() => saleTrays.removeAt(idx)), child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20)),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOffersCard() {
    return _buildCard(
      title: "Available Offers",
      child: Column(
        children: [
          if (offersLoading) const Center(child: CircularProgressIndicator()),
          if (!offersLoading && offers.isEmpty) const Text("No active offers available.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ...offers.map((o) {
            final isAllProducts = o.category == "All Products";
            final totalEggsInCart = salesItems.fold(0, (sum, item) => sum + item.eggs);
            final matchingItem = salesItems.where((i) => i.eggCategoryGrade == o.category).firstOrNull;

            bool isEligible = false;
            String hint = '';

            if (o.offerType == 'buy_x_get_y') {
              final double currentQty = isAllProducts ? totalEggsInCart.toDouble() : (matchingItem?.eggs.toDouble() ?? 0);
              isEligible = currentQty >= o.buyQty;
              hint = isEligible ? 'Apply Offer' : "Need ${o.buyQty.toInt()} eggs ${isAllProducts ? 'total' : 'of ${o.category}'}";
            } else {
              isEligible = isAllProducts ? salesItems.any((i) => i.eggCategoryGrade.isNotEmpty) : matchingItem != null;
              hint = isEligible ? 'Apply Offer' : "Select ${isAllProducts ? 'any product' : o.category}";
            }

            String offerDesc = o.name;
            if (o.offerType == 'buy_x_get_y') {
              offerDesc = "${o.name} — Buy ${o.buyQty.toInt()} get ${o.freeQty.toInt()} free";
            } else if (o.offerType == 'percentage') {
              offerDesc = "${o.name} — ${o.discountValue.toInt()}% Off";
            } else if (o.offerType == 'fixed_amount') {
              offerDesc = "${o.name} — ₹${o.discountValue.toInt()} Flat Discount";
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: o.applied ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: o.applied ? Colors.green : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(offerDesc, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B))),
                    Text(o.category, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ])),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isEligible ? () => toggleOffer(o.id) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: o.applied ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(o.applied ? "Applied" : (isEligible ? "Apply" : hint), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentAndSummaryGrid() {
    return Column(
      children: [
        _buildCard(
          title: "Payment Method",
          child: Column(
            children: [
              Row(
                children: ["CASH", "UPI", "CARD"].map((m) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => selectedPaymentMethod = m),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedPaymentMethod == m ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: selectedPaymentMethod == m ? const Color(0xFF2563EB) : Colors.grey.shade300),
                        ),
                        child: Text(m, style: TextStyle(color: selectedPaymentMethod == m ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              _buildInput("Cash Received", cashReceivedController, keyboardType: TextInputType.number, hint: "0"),
              if (selectedPaymentMethod == "CASH") ...[
                const SizedBox(height: 15),
                _buildInput("Debt (Optional)", debtController, keyboardType: TextInputType.number, hint: "0"),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Bill Summary",
          child: Column(
            children: [
              _summaryRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
              _summaryRow("Discount", "-₹${totalDiscount.toStringAsFixed(2)}", color: const Color(0xFFEF4444)),
              const Divider(height: 30),
              _summaryRow("Total", "₹${totalAmount.toStringAsFixed(2)}", isBold: true),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text("Complete Transaction ₹${totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(double value, Function(double) onChanged, {bool isDozen = false}) {
    return Container(
      height: 38,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: Row(
        children: [
          InkWell(
            onTap: () { if (value > 0) onChanged(value - (isDozen ? 0.5 : 1)); }, 
            child: Container(width: 24, alignment: Alignment.center, child: const Icon(Icons.remove, size: 12)),
          ),
          Expanded(child: Text(isDozen ? value.toStringAsFixed(1) : value.toInt().toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
          InkWell(
            onTap: () => onChanged(value + (isDozen ? 0.5 : 1)), 
            child: Container(width: 24, alignment: Alignment.center, child: const Icon(Icons.add, size: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
          if (trailing != null) trailing,
        ]),
        const SizedBox(height: 15),
        child,
      ]),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {String? hint, Function(String)? onChanged, TextInputType? keyboardType, Widget? suffix, bool readOnly = false, VoidCallback? onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ]);
  }

  Widget _summaryRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, fontSize: isBold ? 16 : 14, color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color ?? const Color(0xFF1E293B), fontSize: isBold ? 18 : 14)),
      ]),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String saleId;
  final double amount;
  final bool isPending;
  final String customerName;
  final String customerNumber;
  final String date;
  final List<SalesItem> items;
  final double discount;
  final double subtotal;
  final String paymentMethod;
  final VoidCallback onNextSale;
  final VoidCallback onDashboard;

  const _SuccessDialog({
    required this.saleId, 
    required this.amount, 
    required this.isPending, 
    required this.customerName,
    required this.customerNumber,
    required this.date,
    required this.items,
    required this.discount,
    required this.subtotal,
    required this.paymentMethod,
    required this.onNextSale, 
    required this.onDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: isPending ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: Icon(isPending ? Icons.timer_outlined : Icons.check_circle_outline, size: 60, color: isPending ? const Color(0xFFF97316) : const Color(0xFF22C55E)),
            ),
            const SizedBox(height: 20),
            Text(isPending ? "Approval Requested" : "Payment Successful!", textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            const SizedBox(height: 10),
            Text(isPending ? "This sale exceeds limits and requires admin approval." : "Your transaction has been recorded successfully.", textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 25),
            _infoRow(isPending ? "Request ID:" : "Sale ID:", "#$saleId"),
            _infoRow("Amount Paid:", "₹${amount.toStringAsFixed(2)}"),
            const SizedBox(height: 25),
            if (!isPending) Row(children: [
              Expanded(child: _actionBtn(Icons.download, "PDF", () async {
                await SalesReceiptService.generateAndPrintReceipt(
                  saleId: saleId, customerName: customerName, customerNumber: customerNumber, date: date,
                  items: items, subtotal: subtotal, discount: discount, total: amount, paymentMethod: paymentMethod, isThermal: false,
                );
              })),
              const SizedBox(width: 10),
              Expanded(child: _actionBtn(Icons.print, "Print", () async {
                await SalesReceiptService.generateAndPrintReceipt(
                  saleId: saleId, customerName: customerName, customerNumber: customerNumber, date: date,
                  items: items, subtotal: subtotal, discount: discount, total: amount, paymentMethod: paymentMethod, isThermal: true,
                );
              })),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
              onPressed: onNextSale, 
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Next Sale Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            TextButton(onPressed: onDashboard, child: const Text("Back to Dashboard", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap, 
      icon: Icon(icon, size: 18), 
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1E293B), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
