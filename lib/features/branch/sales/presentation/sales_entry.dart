import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/sales/data/datasource/branch_sales_remote_datasource.dart';
import 'package:proteinova_connect/features/branch/sales/widget/branch_payment_summary_widget.dart';
import 'package:proteinova_connect/features/branch/sales/widget/branch_product_selection_widget.dart';
import 'package:proteinova_connect/features/branch/sales/widget/branch_sales_items_widget.dart';
import 'package:proteinova_connect/features/branch/sales/widget/sales_entry_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({super.key});

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  String selectedCategory = "All Categories";
  String selectedPaymentMethod = "Cash";

  double offerDiscount = 0;
  bool customerFound = false;
  int salesItemCount = 0;
  List trayList = [];
  List dozenList = [];

  List eggsList = [];

  List rateList = [];
  List offersList = [];
  List totalList = [];
  List productList = [];
  List<Map<String, dynamic>> salesItems = [];
  String selectedWarehouse = "";

  List<String> warehouseList = [];

  List<String> selectedProducts = [];
  final List<TextEditingController> trayControllers = [];
  final List<TextEditingController> dozenControllers = [];
  final BranchSalesRemoteDatasource datasource = BranchSalesRemoteDatasource();
  Map<String, dynamic> salesEntryData = {};

  bool isLoading = true;
  TextEditingController amountController = TextEditingController();
  TextEditingController debtController = TextEditingController();
  TextEditingController customerNumberController = TextEditingController();

  TextEditingController customerNameController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List filteredProducts = [];
  List<int> appliedOfferIndices = [];

  int loginUserId = 0;
  int branchId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      getSalesEntry();
      getWarehouseList();
    });
    fetchOffers();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      branchId = prefs.getInt('branch_id') ?? 1;
      loginUserId = prefs.getInt('user_id') ?? 1;
    });
  }

  Future<void> getSalesEntry({String? warehouse}) async {
    try {
      print("API CALL STARTED FOR WAREHOUSE: $warehouse");
      final response = await datasource.getSalesEntry(
        loginUserId: loginUserId,
        branchName: warehouse,
      );
      print("FULL API RESPONSE =>");
      print(response);

      setState(() {
        salesEntryData = response;
        customerNumberController.text =
            response['customer_number']?.toString() ?? "";
        customerNameController.text =
            response['customer_name']?.toString() ?? "";
        dateController.text = response['sales_date']?.toString() ?? "";
        productList = response['product_details'] ?? [];
        trayList = response['tray_list'] ?? response['dozen_list'] ?? [];
        dozenList = response['dozen_list_actual'] ?? [];
        eggsList = response['eggs_list'] ?? [];
        rateList = response['rate_list'] ?? [];
        totalList = response['total_list'] ?? [];
        _ensureRowCapacity(_maxRowCount());
        productList = response['product_details'] ?? [];
        filteredProducts = productList;
        isLoading = false;
      });
    } catch (e) {
      print("API ERROR =>");
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void setTodayDate() {
    final now = DateTime.now();

    final formattedDate =
        "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}";

    dateController.text = formattedDate;
  }

  Future<void> getWarehouseList() async {
    try {
      final response = await datasource.getSalesEntry(loginUserId: loginUserId);

      print("WAREHOUSE RESPONSE =>");

      print(response);

      /// API FIELD
      List warehouseData = response["warehouse_list"] ?? [];

      print("WAREHOUSE DATA =>");

      print(warehouseData);

      setState(() {
        warehouseList.clear();

        warehouseList.addAll(warehouseData.map((e) => e.toString()));

        print("WAREHOUSE LIST =>");

        print(warehouseList);

        if (warehouseList.isNotEmpty) {
          selectedWarehouse = warehouseList.first;

          print(
            "SELECTED WAREHOUSE => "
            "$selectedWarehouse",
          );
        }
      });
    } catch (e) {
      print("WAREHOUSE ERROR => $e");
    }
  }

  //offer
  Future<void> fetchOffers() async {
    try {
      final response = await datasource.getOffers();

      setState(() {
        offersList = response.where((e) => e["status"] == "active").toList();
      });

      print("OFFERS => $offersList");
    } catch (e) {
      print("OFFERS ERROR => $e");
    }
  }

  //customer number search
  Future<void> fetchCustomerByNumber(String number) async {
    try {
      final customer = await datasource.findCustomerByNumber(number: number);

      if (customer != null) {
        customerNameController.text = customer["name"]?.toString() ?? "";

        customerFound = true;
      } else {
        customerNameController.clear();

        customerFound = false;
      }

      setState(() {});
    } catch (e) {
      customerFound = false;

      print("CUSTOMER FETCH ERROR => $e");
    }
  }

  void searchProducts(String value) {
    setState(() {
      if (value.isEmpty) {
        filteredProducts = productList;
      } else {
        filteredProducts = productList.where((product) {
          final String productName = product['product_name']
              .toString()
              .toLowerCase();
          return productName.contains(value.toLowerCase());
        }).toList();
      }
    });
  }

  void calculateOfferDiscount() {
    double discount = 0;

    final List offers = offersList;

    for (final offer in offers) {
      final String offerCategory =
          offer["category"]?.toString().toLowerCase() ?? "";

      bool matched = false;

      int totalEggs = 0;

      double matchedTotal = 0;

      for (final item in salesItems) {
        final String productName = item["product_name"]
            .toString()
            .toLowerCase();

        if (productName.contains(offerCategory)) {
          matched = true;

          totalEggs += int.tryParse(item["eggs"].toString()) ?? 0;

          matchedTotal += double.tryParse(item["total"].toString()) ?? 0;
        }
      }

      /// BUY X GET Y
      if (offer["offer_type"] == "buy_x_get_y") {
        final int buyQty = int.tryParse((offer["buy_qty"] ?? offer["buyTrays"] ?? 0).toString()) ?? 0;
        final int freeQty = int.tryParse((offer["free_qty"] ?? offer["getTrays"] ?? 1).toString()) ?? 1;
        
        // 1 unit here usually means trays (30 eggs)
        final int thresholdEggs = (buyQty + freeQty) * 30;
        final int freeEggs = freeQty * 30;

        if (totalEggs >= thresholdEggs && thresholdEggs > 0) {
          final int sets = totalEggs ~/ thresholdEggs;
          final double ratePerEgg = totalEggs == 0 ? 0 : matchedTotal / totalEggs;
          discount += (sets * freeEggs) * ratePerEgg;
        }
      }
      /// FLAT DISCOUNT
      else {
        if (matched) {
          discount += double.tryParse(offer["amount"].toString()) ?? 0;
        }
      }
    }

    setState(() {
      offerDiscount = discount;
    });
  }

  Future<void> _recalculateRowFromApi(int index) async {
    final String selectedProduct = selectedProducts[index];
    final String trayText = trayControllers[index].text.trim();
    final String dozenText = dozenControllers[index].text.trim();
    
    final int trayValue = int.tryParse(trayText) ?? 0;
    
    // Custom logic: 1.1 means 1 dozen and 1 egg. 0.1 means 1 egg.
    double totalDozenInput = double.tryParse(dozenText) ?? 0;
    int inputDozens = totalDozenInput.floor();
    // Extract eggs from decimal part (e.g., .1 -> 1, .11 -> 11)
    int inputEggs = 0;
    if (dozenText.contains('.')) {
      String decimalPart = dozenText.split('.')[1];
      inputEggs = int.tryParse(decimalPart) ?? 0;
    }
    
    int currentTotalEggs = (trayValue * 30) + (inputDozens * 12) + inputEggs;
    
    // Auto-convert to trays: 30 eggs = 1 tray
    int normalizedTrays = currentTotalEggs ~/ 30;
    int remainingEggs = currentTotalEggs % 30;
    int normalizedDozens = remainingEggs ~/ 12;
    int finalRemainingEggs = remainingEggs % 12;
    
    // Update state with normalized values
    setState(() {
      trayList[index] = normalizedTrays;
      // To show as D.E where E is single eggs
      dozenList[index] = normalizedDozens + (finalRemainingEggs / 100.0); // Using /100 to avoid .1 becoming .10 unexpectedly if we parse later
      
      // Update controllers to "auto show" the conversion
      String newTrayStr = normalizedTrays.toString();
      String newDozenStr = finalRemainingEggs > 0 
          ? "$normalizedDozens.$finalRemainingEggs" 
          : normalizedDozens.toString();
          
      if (trayControllers[index].text != newTrayStr) {
        trayControllers[index].text = newTrayStr;
      }
      if (dozenControllers[index].text != newDozenStr && !dozenText.endsWith('.')) {
        dozenControllers[index].text = newDozenStr;
      }
      
      eggsList[index] = currentTotalEggs;
    });
    
    if (selectedProduct == "Select Product" || currentTotalEggs <= 0) {
      setState(() {
        eggsList[index] = 0;
        rateList[index] = 0;
        totalList[index] = 0;
      });
      return;
    }
    try {
      /// API REFRESH
      final List latestProducts = productList;
      final Map<String, dynamic>? product = _findProductByName(
        latestProducts,
        selectedProduct,
      );
      if (product == null) {
        return;
      }

      /// 1 tray = 30 eggs
      final int eggsPerTray = 30;

      final int computedEggs = currentTotalEggs;

      /// RATE
      final double productRate = _extractRateFromProduct(product, eggsPerTray);

      /// TOTAL
      final double total = computedEggs * productRate;
      double finalTotal = total;

      for (final offer in offersList) {
        final String offerProduct = offer["product_name"]
            .toString()
            .toLowerCase();

        final String currentProduct = selectedProduct.toLowerCase();

        if (offerProduct == currentProduct) {
          /// PERCENTAGE
          if (offer["offer_type"] == "percentage") {
            double discount =
                double.tryParse(offer["discount_value"].toString()) ?? 0;

            finalTotal = total - ((total * discount) / 100);
          }
          /// FLAT
          else if (offer["offer_type"] == "flat") {
            double discount =
                double.tryParse(offer["discount_value"].toString()) ?? 0;

            finalTotal = (total - discount).clamp(0, total);
          }
          /// BUY X GET Y
          else if (offer["offer_type"] == "buy_x_get_y") {
            int buyQty = int.tryParse((offer["buy_qty"] ?? offer["buyTrays"] ?? 0).toString()) ?? 0;
            int freeQty = int.tryParse((offer["free_qty"] ?? offer["getTrays"] ?? 1).toString()) ?? 1;

            final int thresholdEggs = (buyQty + freeQty) * 30;

            if (computedEggs >= thresholdEggs && thresholdEggs > 0) {
              final int sets = computedEggs ~/ thresholdEggs;
              final double freeAmount = (sets * freeQty * 30) * productRate;
              finalTotal = (total - freeAmount).clamp(0, total);
            }
          }
        }
      }
      setState(() {
        productList = latestProducts;
        if (searchController.text.isEmpty) {
          filteredProducts = productList;
        } else {
          final String query = searchController.text.toLowerCase();
          filteredProducts = productList.where((product) {
            final String productName =
                product['product_name']?.toString().toLowerCase() ?? '';
            return productName.contains(query);
          }).toList();
        }

        eggsList[index] = computedEggs;

        rateList[index] = productRate.toStringAsFixed(2);

        totalList[index] = finalTotal.toStringAsFixed(2);

        /// SALES ITEMS UPDATE
        salesItems = List.generate(salesItemCount, (i) {
          return {
            "product_name": selectedProducts[i],
            "trays": trayList[i],
            "dozen": dozenList[i],
            "eggs": eggsList[i],
            "rate": rateList[i],
            "total": totalList[i],
          };
        });
        calculateOfferDiscount();
        
        // Sync payment amount
        if (amountController.text.isEmpty || amountController.text == "0") {
           amountController.text = _grandTotalValue();
        }

        print("salesItems => ");
        print(salesItems);
      });
    } catch (e) {
      print("ROW CALC API ERROR => ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF5F6FA),
        body: Center(child: SalesEntrySkeleton()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        titleSpacing: 0,
        title: const Text("Sales Entry", style: AppTextStyles.headingText22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Text(
              "Log new sales transactions to automatically update branch inventory.",
              style: AppTextStyles.bodyText14,
            ),
            SizedBox(height: getHeight(context, 20)),

            // buildWarehouseDropdown(),
            SizedBox(height: getHeight(context, 20)),

            /// TRANSACTION DETAILS
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transaction Details",
                    style: AppTextStyles.headingText22,
                  ),
                  SizedBox(height: getHeight(context, 20)),

                  /// CUSTOMER NUMBER
                  buildLabel("Customer Number"),

                  SizedBox(height: getHeight(context, 8)),

                  buildTextField(
                    hint: "Enter customer number",

                    controller: customerNumberController,

                    keyboardType: TextInputType.number,

                    maxLength: 10,

                    onChanged: (value) async {
                      print("NUMBER => $value");

                      if (value.length == 10) {
                        await fetchCustomerByNumber(value);
                      }
                    },
                  ),
                  SizedBox(height: getHeight(context, 18)),

                  /// CUSTOMER NAME
                  buildLabel("Customer Name"),
                  SizedBox(height: getHeight(context, 8)),
                  TextField(
                    controller: customerNameController,

                    readOnly: customerFound,

                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],

                    decoration: InputDecoration(
                      hintText: "Enter customer name",

                      filled: true,

                      fillColor: Colors.white,

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 14,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(context, 18)),

                  /// SALES DATE
                  buildLabel("Sales Date"),

                  SizedBox(height: getHeight(context, 8)),

                  buildDateField(),
                ],
              ),
            ),

            SizedBox(height: getHeight(context, 18)),

            /// PRODUCT SELECTION
            BranchProductSelectionWidget(
              searchController: searchController,
              filteredProducts: filteredProducts,
              buildDropdown: buildDropdown(),
              onSearch: (value) {
                searchProducts(value);
              },
              toNum: _toNum,
              onProductTap: (productName) async {
                /// CHECK EXISTING PRODUCT
                int existingIndex = selectedProducts.indexWhere(
                  (e) => e.toLowerCase() == productName.toLowerCase(),
                );

                /// PRODUCT ALREADY EXISTS
                if (existingIndex != -1) {
                  final productIndex = productList.indexWhere(
                    (e) =>
                        e["product_name"].toString().toLowerCase() ==
                        productName.toLowerCase(),
                  );

                  if (productIndex != -1) {
                    int currentStock =
                        int.tryParse(
                          productList[productIndex]["stock_eggs"].toString(),
                        ) ??
                        0;

                    if (currentStock < 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Out of Stock")),
                      );

                      return;
                    }
                  }

                  int currentTray =
                      int.tryParse(trayControllers[existingIndex].text) ?? 0;

                  currentTray += 1;

                  trayControllers[existingIndex].text = currentTray
                      .toString();

                  trayList[existingIndex] = currentTray;

                  await _recalculateRowFromApi(existingIndex);

                  return;
                }

                /// NEW PRODUCT
                final productIndex = productList.indexWhere(
                  (e) =>
                      e["product_name"].toString().toLowerCase() ==
                      productName.toLowerCase(),
                );

                if (productIndex != -1) {
                  int currentStock =
                      int.tryParse(
                        productList[productIndex]["stock_eggs"].toString(),
                      ) ??
                      0;

                  if (currentStock < 30) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Out of Stock")),
                    );
                    return;
                  }

                  setState(() {
                    salesItemCount++;

                    _ensureRowCapacity(salesItemCount);

                    final int rowIndex = salesItemCount - 1;

                    selectedProducts[rowIndex] = productName;

                    trayControllers[rowIndex].text = "1";
                    dozenControllers[rowIndex].text = "0";

                    trayList[rowIndex] = 1;
                    dozenList[rowIndex] = 0;
                  });

                  await _recalculateRowFromApi(salesItemCount - 1);
                }
              },
              selectedEggsMap: {
                for (var item in salesItems)
                  item["product_name"].toString():
                      int.tryParse(item["eggs"].toString()) ?? 0,
              },
            ),
            SizedBox(height: getHeight(context, 18)),

            /// SALES ITEMS
            BranchSalesItemsWidget(
              salesItemCount: salesItemCount,

              offers: offersList,

              onAdd: () {
                setState(() {
                  salesItemCount++;
                  selectedProducts.add("Select Product");
                  _ensureRowCapacity(salesItemCount);
                });
              },

              salesItemRow: (index) => salesItemRow(index),
              salesItems: salesItems,
              onOffersApplied: (List<int> appliedIndices) {
                double totalDiscount = 0;
                appliedOfferIndices = appliedIndices;
                for (int idx in appliedIndices) {
                  if (idx < offersList.length) {
                    final offer = offersList[idx];
                    final String offerCategory =
                        offer["category"]?.toString().toLowerCase() ?? "";

                    int totalEggs = 0;
                    double matchedTotal = 0;

                    for (final item in salesItems) {
                      final String productName = item["product_name"]
                          .toString()
                          .toLowerCase();

                      if (productName.contains(offerCategory)) {
                        totalEggs += int.tryParse(item["eggs"].toString()) ?? 0;
                        matchedTotal +=
                            double.tryParse(item["total"].toString()) ?? 0;
                      }
                    }

                    if (offer["offer_type"] == "buy_x_get_y") {
                      int buyQty =
                          int.tryParse(
                            (offer["buy_qty"] ?? offer["buyTrays"] ?? 0)
                                .toString(),
                          ) ??
                          0;
                      int getQty =
                          int.tryParse(
                            (offer["getTrays"] ?? offer["get_quantity"] ?? 1)
                                .toString(),
                          ) ??
                          1;

                      if (totalEggs >= (buyQty * 12)) {
                        final double ratePerEgg = totalEggs == 0
                            ? 0
                            : matchedTotal / totalEggs;
                        totalDiscount += (getQty * 12) * ratePerEgg;
                      }
                    } else {
                      totalDiscount +=
                          double.tryParse(
                            (offer["discount_value"] ?? offer["amount"] ?? 0)
                                .toString(),
                          ) ??
                          0;
                    }
                  }
                }
                setState(() {
                  offerDiscount = totalDiscount;
                });
              },
            ),

            SizedBox(height: getHeight(context, 18)),

            /// PAYMENT METHOD
            BranchPaymentSummaryWidget(
              selectedPaymentMethod: selectedPaymentMethod,
              paymentTab: paymentTab,
              buildLabel: buildLabel,

              selectedEggsMap: {
                for (var item in salesItems)
                  item["product_name"].toString():
                      int.tryParse(item["eggs"].toString()) ?? 0,
              },

              amountController: amountController,

              debtController: debtController,

              buildTextField: buildTextField,

              summaryRow: summaryRow,
              itemTrayCount: _itemTrayCount(),
              itemTotal: _itemTotal(),
              offerDiscount: _offerDiscountValue(),
              grandTotal: _grandTotalValue(),

              onSubmit: () async {
                final body = {
                  "login_user_id": loginUserId,

                  "branch_id": branchId,
                  "type": "SALE",
                  "customer_number": customerNumberController.text.trim(),

                  "customer_name": customerNameController.text.trim(),

                  "dispatch_date": (() {
                    try {
                      final parts = dateController.text.split("-");
                      if (parts.length == 3) {
                        return "${parts[2]}-${parts[1]}-${parts[0]}";
                      }
                    } catch (_) {}
                    return DateTime.now().toIso8601String().split("T").first;
                  })(),

                  "payment_method": selectedPaymentMethod.toUpperCase(),

                  "customer_debit": double.tryParse(debtController.text) ?? 0,

                  "cash_received":
                      double.tryParse(amountController.text) ??
                      double.tryParse(_grandTotalValue()) ??
                      0.0,

                  "upi_app": null,

                  "other_upi_details": null,

                  "total_amount": double.tryParse(_grandTotalValue()) ?? 0,

                  "offer_discount": double.tryParse(_offerDiscountValue()) ?? 0,

                  "applied_offers": appliedOfferIndices
                      .map((i) => offersList[i]["id"])
                      .toList(),

                  "sold_to": "Retail",

                  "notes": "",

                  "items": salesItems
                      .where(
                        (e) =>
                            e["product_name"] != "Select Product" &&
                            e["eggs"] != 0,
                      )
                      .map(
                        (e) => {
                          "egg_category_grade": e["product_name"],
                          "trays": e["trays"],
                          "dozen": e["dozen"],
                          "eggs": e["eggs"],
                          "total": e["total"],
                        },
                      )
                      .toList(),
                };

                print("CREATE SALE BODY =>");
                print(body);

                try {
                  final response = await datasource.createSale(body: body);

                  print("CREATE SALE RESPONSE =>");
                  print(response);
                  if (context.mounted) {
                    final String status =
                        response["status"]?.toString().toUpperCase() ?? "";

                    /// PENDING APPROVAL
                    if (status == "PENDING_REVIEW") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Payment Received. Sale sent for admin approval.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      Navigator.pop(context);
                    }
                    /// APPROVED DIRECTLY
                    else if (status == "APPROVED" || status == "SUCCESS") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sale Completed Successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                    /// REJECTED
                    else if (status == "REJECTED") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sale Rejected"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    /// DEFAULT
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            response["message"]?.toString() ?? "Sale Saved",
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print("CREATE SALE ERROR =>");
                  print(e);

                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Failed : $e")));
                  }
                }
              },
            ),

            SizedBox(height: getHeight(context, 30)),
          ],
        ),
      ),
    );
  }

  /// CREATE THIS WIDGET
  /// DROPDOWN UI

  Widget buildWarehouseDropdown() {
    return Center(
      child: Container(
        width: getWidth(context, 150),
        height: getHeight(context, 40),

        padding: const EdgeInsets.symmetric(horizontal: 10),

        decoration: BoxDecoration(
          color: AppColors.background,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: AppColors.border),
        ),

        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            /// IMPORTANT
            value: warehouseList.contains(selectedWarehouse)
                ? selectedWarehouse
                : null,

            hint: const Text("Select Warehouse"),

            isExpanded: true,

            icon: const Icon(
              Icons.arrow_drop_down,

              color: AppColors.dark,

              size: 20,
            ),

            style: AppTextStyles.bodyText14dark,
            dropdownColor: Colors.white,

            items: warehouseList.map((String warehouse) {
              return DropdownMenuItem<String>(
                value: warehouse,

                child: Text(warehouse, overflow: TextOverflow.ellipsis),
              );
            }).toList(),

            onChanged: (String? value) {
              print("SELECTED => $value");

              if (value != null) {
                setState(() {
                  selectedWarehouse = value;
                  isLoading = true;
                });
                getSalesEntry(warehouse: value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildDateField() {
    return Container(
      height: getHeight(context, 55),
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: dateController,

              readOnly: true,

              decoration: const InputDecoration(
                hintText: "Enter Date",

                border: InputBorder.none,
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,

                initialDate: DateTime.now(),

                firstDate: DateTime(2020),

                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.day.toString().padLeft(2, '0')}-"
                    "${pickedDate.month.toString().padLeft(2, '0')}-"
                    "${pickedDate.year}";

                setState(() {
                  dateController.text = formattedDate;
                });
              }
            },

            child: const Icon(Icons.calendar_today, size: 20),
          ),
        ],
      ),
    );
  }

  /// COMMON CARD
  Widget buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  /// LABEL
  Widget buildLabel(String text) {
    return Text(text, style: AppTextStyles.buttonText16);
  }

  /// TEXT FIELD
  Widget buildTextField({
    required String hint,

    IconData? icon,

    TextEditingController? controller,

    Function(String)? onChanged,

    TextInputType? keyboardType,

    int? maxLength,

    bool textOnly = false,
  }) {
    return TextField(
      controller: controller,

      onChanged: onChanged,

      keyboardType: keyboardType,

      maxLength: maxLength,

      inputFormatters: textOnly
          ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
          : null,

      decoration: InputDecoration(
        hintText: hint,

        counterText: "",

        prefixIcon: icon != null ? Icon(icon) : null,

        filled: true,

        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget buildDropdown() {
    final List<String> dropdownItems = [
      "All Categories",

      ...{
        ...productList.map((product) {
          return product['product_name']?.toString() ?? "";
        }),
      },
    ].toList();

    return Container(
      height: 55,

      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownItems.contains(selectedCategory)
              ? selectedCategory
              : "All Categories",

          isExpanded: true,

          icon: const Icon(Icons.keyboard_arrow_down),

          style: AppTextStyles.bodyText16,

          items: dropdownItems.map((String item) {
            return DropdownMenuItem<String>(
              value: item,

              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedCategory = value!;

              /// ALL PRODUCTS
              if (value == "All Categories") {
                filteredProducts = productList;
              } else {
                /// FILTER PRODUCT
                filteredProducts = productList.where((product) {
                  return product['product_name'].toString().toLowerCase() ==
                      value.toLowerCase();
                }).toList();
              }
            });
          },
        ),
      ),
    );
  }

  /// SALES ITEM ROW
  Widget salesItemRow(int no) {
    _ensureRowCapacity(no);
    final List<String> dropdownItems = _productDropdownItems();
    final String currentValue = dropdownItems.contains(selectedProducts[no - 1])
        ? selectedProducts[no - 1]
        : "Select Product";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          /// NUMBER
          SizedBox(
            width: getWidth(context, 10),
            child: Text(
              "$no",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText12dark,
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          /// PRODUCT
          Expanded(
            flex: 3,

            child: Container(
              height: getHeight(context, 38),

              padding: const EdgeInsets.symmetric(horizontal: 8),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),

                border: Border.all(color: Colors.grey.shade300),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentValue,

                  isExpanded: true,

                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),

                  style: AppTextStyles.bodyText10dark,

                  items: dropdownItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,

                      child: Text(item, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),

                  onChanged: (value) async {
                    setState(() {
                      selectedProducts[no - 1] = value!;
                    });

                    await _recalculateRowFromApi(no - 1);
                  },
                ),
              ),
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          /// TRAYS
          Container(
            width: getWidth(context, 35),
            height: getHeight(context, 38),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: trayControllers[no - 1],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (_) async {
                await _recalculateRowFromApi(no - 1);
              },
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          /// DOZEN
          Container(
            width: getWidth(context, 35),
            height: getHeight(context, 38),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: dozenControllers[no - 1],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (_) async {
                await _recalculateRowFromApi(no - 1);
              },
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          /// EGGS
          SizedBox(
            width: getWidth(context, 20),
            child: Text(
              eggsList.length >= no ? eggsList[no - 1].toString() : "0",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          /// RATE
          SizedBox(
            width: getWidth(context, 35),
            child: Text(
              "₹${rateList.length >= no ? rateList[no - 1] : 0}",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          /// TOTAL
          SizedBox(
            width: getWidth(context, 40),
            child: Text(
              "₹${totalList.length >= no ? totalList[no - 1] : 0}",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),

          SizedBox(width: getWidth(context, 4)),

          /// DELETE
          GestureDetector(
            onTap: () {
              setState(() {
                int index = no - 1;

                if (selectedProducts.length > index) {
                  selectedProducts.removeAt(index);
                }

                if (trayControllers.length > index) {
                  trayControllers[index].dispose();
                  trayControllers.removeAt(index);
                }

                if (dozenControllers.length > index) {
                  dozenControllers[index].dispose();
                  dozenControllers.removeAt(index);
                }

                if (trayList.length > index) {
                  trayList.removeAt(index);
                }

                if (dozenList.length > index) {
                  dozenList.removeAt(index);
                }

                if (eggsList.length > index) {
                  eggsList.removeAt(index);
                }

                if (rateList.length > index) {
                  rateList.removeAt(index);
                }

                if (totalList.length > index) {
                  totalList.removeAt(index);
                }

                if (salesItemCount > 0) {
                  salesItemCount--;
                }
              });
            },

            child: const Icon(
              Icons.delete_outline,
              size: 18,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// PAYMENT TAB
  Widget paymentTab(String title) {
    bool isSelected = selectedPaymentMethod == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = title;
        });
      },

      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,

              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: getHeight(context, 8)),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),

            height: getHeight(context, 3),
            width: getWidth(context, 30),

            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,

              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  /// SUMMARY ROW
  Widget summaryRow(
    String title,
    String value, {
    bool red = false,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: red ? Colors.red : Colors.black,

            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<String> _productDropdownItems() {
    final Set<String> apiProducts = productList
        .map((product) {
          if (product is Map<String, dynamic>) {
            return (product["product_name"] ??
                    product["name"] ??
                    product["product"] ??
                    "")
                .toString()
                .trim();
          }
          return product.toString().trim();
        })
        .where((name) => name.isNotEmpty)
        .toSet();

    return ["Select Product", ...apiProducts];
  }

  int _maxRowCount() {
    final List<int> lengths = [
      selectedProducts.length,
      dozenList.length,
      eggsList.length,
      rateList.length,
      totalList.length,
      salesItemCount,
    ];
    lengths.sort();
    return lengths.isEmpty ? 0 : lengths.last;
  }

  void _ensureRowCapacity(int count) {
    while (selectedProducts.length < count) {
      selectedProducts.add("Select Product");
    }
    while (trayList.length < count) {
      trayList.add(0);
    }
    while (dozenList.length < count) {
      dozenList.add(0);
    }
    while (eggsList.length < count) {
      eggsList.add(0);
    }
    while (rateList.length < count) {
      rateList.add(0);
    }
    while (totalList.length < count) {
      totalList.add(0);
    }
    while (trayControllers.length < count) {
      trayControllers.add(TextEditingController(text: "0"));
    }
    while (dozenControllers.length < count) {
      dozenControllers.add(TextEditingController(text: "0"));
    }

    for (int i = 0; i < count; i++) {
      final String trayVal = trayList[i].toString();
      final String dozenVal = dozenList[i].toString();
      if (trayControllers[i].text != trayVal) {
        trayControllers[i].text = trayVal;
      }
      if (dozenControllers[i].text != dozenVal) {
        dozenControllers[i].text = dozenVal;
      }
    }

    if (salesItemCount < count) {
      salesItemCount = count;
    }
  }

  Map<String, dynamic>? _findProductByName(List products, String name) {
    for (final dynamic product in products) {
      if (product is Map<String, dynamic>) {
        final String productName =
            (product["product_name"] ??
                    product["name"] ??
                    product["product"] ??
                    "")
                .toString()
                .trim();
        if (productName.toLowerCase() == name.toLowerCase()) {
          return product;
        }
      }
    }
    return null;
  }

  num _toNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return num.tryParse(value.toString()) ?? 0;
  }

  double _extractRateFromProduct(
    Map<String, dynamic>? product,
    int eggsPerTray,
  ) {
    if (product == null) {
      return 0;
    }

    final List<dynamic> directRateKeys = [
      product['per_egg_price'],
      product['rate_per_egg'],
      product['rate'],
      product['price'],
      product['egg_rate'],
      product['perEggRate'],
      product['per_egg_rate'],
    ];

    for (final dynamic value in directRateKeys) {
      final double parsed = _toNum(value).toDouble();
      if (parsed > 0) {
        return parsed;
      }
    }

    final double perTrayRate = _toNum(
      product['per_tray_price'] ??
          product['tray_price'] ??
          product['perDozenPrice'],
    ).toDouble();
    if (perTrayRate > 0 && eggsPerTray > 0) {
      return perTrayRate / eggsPerTray;
    }

    return 0;
  }

  String _formatMoney(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  num _sumNumericList(List data) {
    return data.fold<num>(0, (sum, item) {
      final num? value = num.tryParse(item.toString());
      return sum + (value ?? 0);
    });
  }

  String _itemTrayCount() {
    final num trays = _sumNumericList(dozenList);
    return _formatMoney(trays);
  }

  String _itemTotal() {
    final num total = _sumNumericList(totalList);
    return _formatMoney(total);
  }

  String _offerDiscountValue() {
    final num discount = num.tryParse(offerDiscount.toString()) ?? 0;
    return _formatMoney(discount);
  }

  String _grandTotalValue() {
    final num grandTotal =
        _sumNumericList(totalList) -
        (num.tryParse(offerDiscount.toString()) ?? 0);
    return _formatMoney(grandTotal < 0 ? 0 : grandTotal);
  }

  @override
  void dispose() {
    customerNumberController.dispose();
    customerNameController.dispose();
    dateController.dispose();
    for (final controller in dozenControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
