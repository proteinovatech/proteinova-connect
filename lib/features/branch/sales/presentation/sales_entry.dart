import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/core/services/sales_receipt_service.dart';
import 'package:proteinova_connect/features/branch/sales/data/datasource/branch_sales_remote_datasource.dart';
import 'package:proteinova_connect/features/branch/sales/data/model/sales_entry_model.dart';
import 'package:proteinova_connect/features/branch/sales/data/model/sales_item_model.dart';
import 'package:proteinova_connect/features/branch/sales/widget/sales_entry_skeleton.dart';
import 'package:proteinova_connect/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaleTray {
  String trayType;
  int qty;
  SaleTray({this.trayType = "without tray", this.qty = 0});
}

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({super.key});

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  // --- State Variables ---
  String salesHappen = "In_warehouse";
  Map<String, dynamic>? headerData;
  List<ProductDetail> products = [];
  List<OfferModel> offers = [];
  List<SalesItem> salesItems = [SalesItem()];
  List<SaleTray> saleTrays = [SaleTray()];

  bool isLoading = true;
  bool isSubmitting = false;
  String? customerStatus; // 'found', 'not_found', null

  String selectedPaymentMethod = "CASH";
  String selectedUpiApp = "";
  String otherUpiDetails = "";

  final TextEditingController customerNumberController =
      TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController cashReceivedController = TextEditingController();
  final TextEditingController debtController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final BranchSalesRemoteDatasource datasource = BranchSalesRemoteDatasource();
  List<ProductDetail> filteredProducts = [];
  int loginUserId = 0;
  int branchId = 0;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadUserData().then((_) => _fetchInitialData());
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      branchId = prefs.getInt('branch_id') ?? 1;
      loginUserId = prefs.getInt('user_id') ?? 1;
    });
  }

  Future<void> _fetchInitialData() async {
    try {
      if (mounted) setState(() => isLoading = true);
      final response = await datasource.getSalesEntry(loginUserId: loginUserId);
      final model = SalesEntryModel.fromJson(response);

      if (mounted) {
        setState(() {
          headerData = model.header;
          salesHappen = model.header['sales_happen'] ?? "In_warehouse";
          products = model.productDetails;
          offers = model.offers;
          filteredProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching sales data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- Calculations ---
  double get subtotal => salesItems.fold(0.0, (sum, item) => sum + item.total);

  double get totalDiscount {
    double discount = 0;
    for (var offer in offers) {
      if (!offer.applied) continue;

      final matchingItems = salesItems
          .where(
            (item) =>
                item.eggCategoryGrade.trim().toLowerCase() ==
                    offer.category.trim().toLowerCase() ||
                offer.category.trim().toLowerCase() == "all products",
          )
          .toList();

      if (matchingItems.isEmpty) continue;

      if (offer.offerType == 'buy_x_get_y') {
        final int totalEggs = matchingItems.fold(
          0,
          (sum, item) => sum + item.eggs,
        );
        final int buyQtyThreshold = offer.buyTrays * 30;
        if (totalEggs >= buyQtyThreshold && buyQtyThreshold > 0) {
          final int freeEggsCount = (totalEggs ~/ buyQtyThreshold) * 30;
          discount += double.parse(
            (freeEggsCount * matchingItems.first.price).toStringAsFixed(2),
          );
        }
      } else if (offer.offerType == 'percentage') {
        final double matchedTotal = matchingItems.fold(
          0.0,
          (sum, item) => sum + item.total,
        );
        discount += (matchedTotal * offer.discountValue) / 100;
      } else if (offer.offerType == 'fixed') {
        discount += offer.discountValue;
      }
    }
    return double.parse(discount.toStringAsFixed(2));
  }

  double get totalAmount => subtotal - totalDiscount;
  double get credit =>
      totalAmount - (double.tryParse(cashReceivedController.text) ?? 0);

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
      } else if (field == 'trays') {
        item.trays = int.tryParse(value.toString()) ?? 0;
        item.calculateEggs();
      }
    });
  }

  void addProductFromCard(ProductDetail product) {
    setState(() {
      final existingIndex = salesItems.indexWhere(
        (i) => i.eggCategoryGrade == product.productName,
      );
      if (existingIndex != -1) {
        salesItems[existingIndex].trays += 1;
        salesItems[existingIndex].calculateEggs();
      } else {
        if (salesItems.length == 1 && salesItems[0].eggCategoryGrade == "") {
          salesItems[0] = SalesItem(
            eggCategoryGrade: product.productName,
            price: product.perTrayPrice / 30,
            trays: 1,
          )..calculateEggs();
        } else {
          salesItems.add(
            SalesItem(
              eggCategoryGrade: product.productName,
              price: product.perTrayPrice / 30,
              trays: 1,
            )..calculateEggs(),
          );
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

    final validItems = salesItems
        .where((i) => i.eggCategoryGrade.isNotEmpty)
        .toList();
    if (validItems.isEmpty) {
      _showError("Please add at least one product");
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final payload = {
        "login_user_id": loginUserId.toString(),
        "sales_happen": salesHappen,
        "customer_name": cName.isEmpty ? "Unknown Customer" : cName,
        "customer_number": cNumber.isEmpty ? "N/A" : cNumber,
        "customer_debit": double.tryParse(debtController.text) ?? 0,
        "dispatch_date": dateController.text,
        "payment_method": selectedPaymentMethod,
        "cash_received": double.tryParse(cashReceivedController.text) ?? 0,
        "upi_app": selectedPaymentMethod == "UPI"
            ? (selectedUpiApp.isEmpty ? "Other" : selectedUpiApp)
            : null,
        "other_upi_details": selectedPaymentMethod == "UPI"
            ? otherUpiDetails
            : null,
        "total_amount": totalAmount,
        "offer_discount": totalDiscount,
        "applied_offers": offers
            .where((o) => o.applied)
            .map((o) => o.name)
            .toList(),
        "sold_to": "Retail",
        "notes": notesController.text,
        "items": validItems
            .map(
              (i) => {
                "egg_category_grade": i.eggCategoryGrade,
                "dozen": i.dozen,
                "eggs": i.eggs,
                "trays": (i.eggs / 30).ceil(),
                "total": i.total,
              },
            )
            .toList(),
        "sale_trays": saleTrays
            .where((t) => t.qty > 0)
            .map((t) => {"tray_type": t.trayType, "qty": t.qty})
            .toList(),
        "branch_id": branchId,
      };

      if (customerStatus == 'not_found' && cNumber.isNotEmpty) {
        await datasource.createCustomer(
          name: cName.isEmpty ? "Unknown Customer" : cName,
          number: cNumber,
        );
      }

      final res = await datasource.createSale(body: payload);
      setState(() => isSubmitting = false);

      final saleId = res['sale']?['id'] ?? res['id'] ?? res['sale_id'] ?? 'N/A';
      final isPending =
          res['status'] == "PENDING_REVIEW" || res['approval_id'] != null;

      if (isPending) {
        final totalEggs = validItems.fold(0, (sum, i) => sum + i.eggs);
        NotificationService.sendAdminApprovalNotification(
          saleId: saleId.toString(),
          branchName: headerData?['title'] ?? 'Branch',
          totalEggs: totalEggs,
        );
      }

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
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFEF4444),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Sale Failed",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup(
    dynamic saleId,
    bool isPending,
    List<SalesItem> finalItems,
  ) {
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
    if (isLoading) return const Scaffold(body: SalesEntrySkeleton());

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        _buildTodayStatsRow(),
                        const SizedBox(height: 16),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildTransactionDetailsCard(),
                                    const SizedBox(height: 16),
                                    _buildProductSelectionCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildSalesItemsCard(isWide),
                                    const SizedBox(height: 16),
                                    _buildTrayTypesCard(),
                                    const SizedBox(height: 16),
                                    _buildOffersCard(),
                                    const SizedBox(height: 16),
                                    _buildPaymentAndSummaryGrid(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildTransactionDetailsCard(),
                              const SizedBox(height: 16),
                              _buildProductSelectionCard(),
                              const SizedBox(height: 16),
                              _buildSalesItemsCard(isWide),
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
          },
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
                  Text(
                    "${salesHappen.replaceAll('_', ' ')} / ",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Text(
                    "Sales Entry",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // const Icon(Icons.notifications_none, color: Colors.grey),
            ],
          ),
          const Divider(),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     headerData?['title'] ?? "Sales Entry",
          //     style: const TextStyle(
          //       fontSize: 22,
          //       fontWeight: FontWeight.w800,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTodayStatsRow() {
    final stats = headerData?['today_sales'] ?? {};
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Today: ",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              "${stats['count'] ?? 0} Sales",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              " | Total: ",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              "₹${(stats['amount'] ?? 0).toString()}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.list, size: 16),
          label: const Text(
            "View Today's Sales",
            style: TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(color: Colors.blue.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
                  "Customer Number",
                  customerNumberController,
                  hint: "9876543210",
                  keyboardType: TextInputType.phone,
                  onChanged: lookupCustomer,
                  suffix: customerStatus == 'found'
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        )
                      : customerStatus == 'not_found'
                      ? const Icon(
                          Icons.person_add,
                          color: Colors.orange,
                          size: 18,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 15),
              Expanded(
                child: _buildInput(
                  "Customer Name",
                  customerNameController,
                  hint: "Enter customer name",
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
            suffix: const Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.grey,
            ),
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
                filteredProducts = products
                    .where(
                      (p) =>
                          p.productName.toLowerCase().contains(v.toLowerCase()),
                    )
                    .toList();
              });
            },
            decoration: InputDecoration(
              hintText: "Search product by name",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
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
                      Text(
                        p.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "₹${(p.perTrayPrice / 30).toStringAsFixed(2)} / Egg",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Stock: ${p.stockEggs} Eggs",
                        style: TextStyle(
                          fontSize: 11,
                          color: isOutOfStock ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildSalesItemsCard(bool isWide) {
    return _buildCard(
      title: "Sales Items",
      trailing: InkWell(
        onTap: addItem,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
      child: Column(
        children: [
          if (isWide)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              color: Colors.grey.shade100,
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Product",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Dozen",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Trays",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Eggs",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
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
              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: item.eggCategoryGrade.isEmpty
                                  ? null
                                  : item.eggCategoryGrade,
                              isExpanded: true,
                              hint: const Text(
                                "Select Product",
                                style: TextStyle(fontSize: 11),
                              ),
                              items: products
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p.productName,
                                      child: Text(
                                        p.productName,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => updateItem(index, 'product', v),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 2,
                        child: _buildStepper(
                          item.dozen,
                          (v) => updateItem(index, 'dozen', v),
                          isDozen: true,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 2,
                        child: _buildStepper(
                          item.trays.toDouble(),
                          (v) => updateItem(index, 'trays', v.toInt()),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${item.eggs}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "₹${item.total.toStringAsFixed(1)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => removeItem(index),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: item.eggCategoryGrade.isEmpty
                                      ? null
                                      : item.eggCategoryGrade,
                                  isExpanded: true,
                                  hint: const Text(
                                    "Select Product",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  items: products
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p.productName,
                                          child: Text(
                                            p.productName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      updateItem(index, 'product', v),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => removeItem(index),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Dozen",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStepper(
                                  item.dozen,
                                  (v) => updateItem(index, 'dozen', v),
                                  isDozen: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Trays",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStepper(
                                  item.trays.toDouble(),
                                  (v) => updateItem(index, 'trays', v.toInt()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Total Eggs:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${item.eggs}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Price:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "₹${item.total.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF16A34A),
                                    fontSize: 16,
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
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
      child: Column(
        children: saleTrays.asMap().entries.map((entry) {
          int idx = entry.key;
          SaleTray tray = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tray.trayType,
                        isExpanded: true,
                        items:
                            [
                                  "without tray",
                                  "Empty paper tray",
                                  "Empty plastic tray",
                                  "Plastic tray (With egg)",
                                  "Paper tray (with egg)",
                                ]
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => tray.trayType = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildStepper(
                    tray.qty.toDouble(),
                    (v) => setState(() => tray.qty = v.toInt()),
                  ),
                ),
                if (saleTrays.length > 1) ...[
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => setState(() => saleTrays.removeAt(idx)),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
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
        children: offers.map((o) {
          final isAllProducts = o.category.toLowerCase() == 'all products';
          final matchingItem = salesItems.any(
            (item) => isAllProducts
                ? item.eggCategoryGrade.isNotEmpty
                : item.eggCategoryGrade.toLowerCase() ==
                      o.category.toLowerCase(),
          );

          bool isEligible = false;
          String message = "";
          if (o.offerType == 'buy_x_get_y') {
            final totalEggs = salesItems
                .where(
                  (i) => isAllProducts
                      ? i.eggCategoryGrade.isNotEmpty
                      : i.eggCategoryGrade.toLowerCase() ==
                            o.category.toLowerCase(),
                )
                .fold(0, (sum, i) => sum + i.eggs);
            isEligible = totalEggs >= (o.buyTrays * 30);
            message = "Need ${o.buyTrays} trays";
          } else {
            isEligible = matchingItem;
            message = isAllProducts ? "Add any product" : "Add product";
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: o.applied ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: o.applied ? Colors.green : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        o.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isEligible ? () => toggleOffer(o.id) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: o.applied
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (o.applied) const Icon(Icons.check, size: 14),
                      if (o.applied) const SizedBox(width: 4),
                      Text(
                        o.applied
                            ? "Applied"
                            : (isEligible ? "Apply" : message),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentAndSummaryGrid() {
    return Column(
      children: [
        _buildCard(
          title: "Payment Method",
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sidebar-like payment selector
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _sidebarMethodBtn("CASH"),
                      _sidebarMethodBtn("UPI"),
                      _sidebarMethodBtn("CARD"),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                // Payment content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedPaymentMethod == "UPI") ...[
                        const Text(
                          "Select UPI App",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ["Google Pay", "PhonePe", "Paytm"]
                              .map(
                                (app) => ChoiceChip(
                                  label: Text(
                                    app,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: selectedUpiApp == app
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: selectedUpiApp == app,
                                  onSelected: (v) =>
                                      setState(() => selectedUpiApp = app),
                                  selectedColor: const Color(0xFF2563EB),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: selectedUpiApp == app
                                          ? const Color(0xFF2563EB)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 15),
                        _buildInput(
                          "Other UPI Details (Optional)",
                          TextEditingController(text: otherUpiDetails),
                          onChanged: (v) => otherUpiDetails = v,
                        ),
                        const SizedBox(height: 15),
                      ],
                      if (selectedPaymentMethod == "CASH") ...[
                        _buildInput(
                          "Customer Debt (Optional)",
                          debtController,
                          keyboardType: TextInputType.number,
                          hint: "0",
                        ),
                        const SizedBox(height: 15),
                      ],
                      _buildInput(
                        "Enter Amount Received",
                        cashReceivedController,
                        keyboardType: TextInputType.number,
                        hint: "0.00",
                        prefix: const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "₹",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        onChanged: (v) => setState(() {}),
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                        "Notes",
                        notesController,
                        hint: "Add internal notes",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Bill Summary",
          child: Column(
            children: [
              _summaryRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
              _summaryRow(
                "Discount",
                "-₹${totalDiscount.toStringAsFixed(2)}",
                color: const Color(0xFFEF4444),
              ),
              const Divider(height: 40),
              _summaryRow(
                "Total",
                "₹${totalAmount.toStringAsFixed(2)}",
                isBold: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Complete Sale",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sidebarMethodBtn(String method) {
    bool active = selectedPaymentMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedPaymentMethod = method),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            method,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(
    double value,
    Function(double) onChanged, {
    bool isDozen = false,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (value > 0) onChanged(value - (isDozen ? 0.5 : 1));
            },
            child: Container(
              width: 24,
              alignment: Alignment.center,
              child: const Icon(Icons.remove, size: 12),
            ),
          ),
          Expanded(
            child: Text(
              isDozen ? value.toStringAsFixed(1) : value.toInt().toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          InkWell(
            onTap: () => onChanged(value + (isDozen ? 0.5 : 1)),
            child: Container(
              width: 24,
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    String? hint,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    Widget? suffix,
    Widget? prefix,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              fontSize: isBold ? 18 : 15,
              color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color:
                  color ??
                  (isBold ? const Color(0xFF1E293B) : const Color(0xFF1E293B)),
              fontSize: isBold ? 22 : 16,
            ),
          ),
        ],
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isPending
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.timer_outlined : Icons.check_circle_outline,
                size: 70,
                color: isPending
                    ? const Color(0xFFF97316)
                    : const Color(0xFF22C55E),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPending ? "Approval Requested" : "Payment Successful!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? "This sale exceeds egg limits and requires admin approval."
                  : "Your transaction has been recorded successfully.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _infoBox(
              isPending ? "Request ID:" : "Sale ID:",
              "#$saleId",
              isPending ? "REQ" : "S",
            ),
            _infoBox("Amount Paid:", "₹${amount.toStringAsFixed(2)}", "INR"),
            const SizedBox(height: 32),
            if (!isPending)
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      Icons.file_download_outlined,
                      "PDF",
                      () async {
                        await SalesReceiptService.generateAndPrintReceipt(
                          saleId: saleId,
                          customerName: customerName,
                          customerNumber: customerNumber,
                          date: date,
                          items: items,
                          subtotal: subtotal,
                          discount: discount,
                          total: amount,
                          paymentMethod: paymentMethod,
                          isThermal: false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _actionBtn(Icons.print_outlined, "Print", () async {
                      await SalesReceiptService.generateAndPrintReceipt(
                        saleId: saleId,
                        customerName: customerName,
                        customerNumber: customerNumber,
                        date: date,
                        items: items,
                        subtotal: subtotal,
                        discount: discount,
                        total: amount,
                        paymentMethod: paymentMethod,
                        isThermal: true,
                      );
                    }),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onNextSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Next Sale",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onDashboard,
              child: const Text(
                "Back to Dashboard",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1E293B),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
