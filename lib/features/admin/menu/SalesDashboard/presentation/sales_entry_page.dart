import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/data/datasource/sales_remote_datasource.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/widget/payment_summary_widget.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/widget/product_selection_widget.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/widget/sales_items_widget.dart';

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({super.key});

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  String selectedCategory = "All Categories";
  String selectedPaymentMethod = "Cash";

  int loginUserId = 1;

  double offerDiscount = 0;

  int salesItemCount = 0;
  List dozenList = [];

  List eggsList = [];

  List rateList = [];

  List totalList = [];
  List productList = [];
  List<Map<String, dynamic>> salesItems = [];
  List<Map<String, dynamic>> warehouseList = [];
  List<int> appliedOfferIndexes = [];
  String selectedWarehouseId = "";

  String selectedWarehouseName = "";

  List<String> selectedProducts = ["Select Product"];
  final List<TextEditingController> dozenControllers = [];
  final SalesRemoteDatasource datasource = SalesRemoteDatasource();

  Map<String, dynamic> salesEntryData = {};

  bool isLoading = true;
  bool isProductLoading = false;
  TextEditingController amountController = TextEditingController();
  TextEditingController debtController = TextEditingController();
  TextEditingController customerNumberController = TextEditingController();

  TextEditingController customerNameController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List filteredProducts = [];
  Map<String, int> selectedEggsMap = {};
  @override
  void initState() {
    super.initState();
    getSalesEntry();
    getWarehouseList();
  }

  Future<void> getSalesEntry() async {
    try {
      print("API CALL STARTED");
      final response = await datasource.getSalesEntry(loginUserId: 1);
      print("FULL API RESPONSE =>");
      print(response);
      print("CUSTOMER NUMBER =>");
      print(response['customer_number']);
      print("CUSTOMER NAME =>");
      print(response['customer_name']);
      print("SALES DATE =>");
      print(response['sales_date']);
      print("OFFERS =>");
      print(response['offers']);

      if (response['offers'] != null && response['offers'].isNotEmpty) {
        print("FIRST OFFER =>");
        print(response['offers'][0]);
      }
      setState(() {
        salesEntryData = response;
        customerNumberController.text =
            response['customer_number']?.toString() ?? "";
        customerNameController.text =
            response['customer_name']?.toString() ?? "";
        dateController.text = response['sales_date']?.toString() ?? "";
        productList = List.from(response['product_details'] as List? ?? []);
        dozenList = response['dozen_list'] ?? [];
        eggsList = response['eggs_list'] ?? [];
        rateList = response['rate_list'] ?? [];
        totalList = response['total_list'] ?? [];
        _ensureRowCapacity(_maxRowCount());

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
      final response = await datasource.getBranches();

      print("BRANCH RESPONSE =>");
      print(response);

      List warehouseData = response["data"] ?? [];

      setState(() {
        warehouseList = List<Map<String, dynamic>>.from(warehouseData);

        if (warehouseList.isNotEmpty) {
          selectedWarehouseId = warehouseList.first["id"].toString();

          selectedWarehouseName = warehouseList.first["branch_name"].toString();
        }
      });
    } catch (e) {
      print("WAREHOUSE ERROR => $e");
    }
  }

  /// Called every time the user picks a different branch.
  /// Re-fetches the product list (with stock) for that branch.
  Future<void> reloadProductsForBranch(int branchId) async {
    setState(() {
      isProductLoading = true;
      // Clear current selection so stale rows don't remain
      salesItems = [];
      salesItemCount = 0;
      selectedProducts = ["Select Product"];
      dozenControllers.clear();
      dozenList = [];
      eggsList = [];
      rateList = [];
      totalList = [];
      offerDiscount = 0;
    });

    try {
      final response = await datasource.getSalesEntry(
        loginUserId: loginUserId,
        branchId: branchId,
      );

      print("BRANCH RELOAD RESPONSE =>");
      print(response);

      setState(() {
        salesEntryData = response;
        // Show ALL products for this branch — UI handles No Stock state
        productList = List.from(response['product_details'] as List? ?? []);
        filteredProducts = productList;
        _ensureRowCapacity(_maxRowCount());
        isProductLoading = false;
      });
    } catch (e) {
      print("BRANCH RELOAD ERROR => $e");
      setState(() {
        productList = [];
        filteredProducts = [];
        isProductLoading = false;
      });
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
    if (appliedOfferIndexes.isEmpty) {
      setState(() {
        offerDiscount = 0;
      });

      return;
    }
    double discount = 0;

    final List offers = salesEntryData["offers"] ?? [];

    for (int index = 0; index < offers.length; index++) {
      if (!appliedOfferIndexes.contains(index)) {
        continue;
      }

      final offer = offers[index];
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
      print("========== APPLY CHECK ==========");
      print("Offer => ${offer["name"]}");

      print("Offer Category => $offerCategory");

      print("Matched => $matched");

      print("Total Eggs => $totalEggs");

      print("Matched Total => $matchedTotal");
      print("BUY X GET Y CHECK");

      print("buyTrays => ${offer["buyTrays"]}");

      print("getTrays => ${offer["getTrays"]}");

      print("buy_quantity => ${offer["buy_quantity"]}");

      print("get_quantity => ${offer["get_quantity"]}");

      /// BUY X GET Y
      /// BUY X GET Y
      if (offer["offer_type"] == "buy_x_get_y") {
        // final int needTrays = int.tryParse(offer["buyTrays"].toString()) ?? 0;
        final int needTrays =
            int.tryParse(
              (offer["buy_qty"] ?? offer["buyTrays"] ?? 0).toString(),
            ) ??
            0;
        // final int freeTrays = int.tryParse(offer["getTrays"].toString()) ?? 0;
        final int freeTrays =
            int.tryParse(
              (offer["free_qty"] ?? offer["getTrays"] ?? 1).toString(),
            ) ??
            1;
        // final int totalTrays = totalEggs ~/ 30;
        final int totalDozens = totalEggs ~/ 12;
        // if (totalTrays >= needTrays)
        if (totalDozens >= needTrays) {
          // final double trayRate = totalTrays == 0
          //     ? 0
          //     : matchedTotal / totalTrays;
          final double dozenRate = totalDozens == 0
              ? 0
              : matchedTotal / totalDozens;
          // discount += freeTrays * trayRate;
          discount += freeTrays * dozenRate;
        }
      }
      /// FLAT DISCOUNT
      else {
        if (matched) {
          // discount += double.tryParse(offer["amount"].toString()) ?? 0;
          final double fixedDiscount =
              double.tryParse(
                (offer["discount_value"] ?? offer["amount"] ?? 50).toString(),
              ) ??
              50;

          discount += fixedDiscount;
        }
      }
    }
    print("FINAL DISCOUNT => $discount");
    setState(() {
      offerDiscount = discount;
    });
  }

  // Future<void> _recalculateRowFromApi(int index) async {
  //   final String selectedProduct = selectedProducts[index];
  //   final String dozenText = dozenControllers[index].text.trim();
  //   final int dozenValue = int.tryParse(dozenText) ?? 0;
  //   setState(() {
  //     dozenList[index] = dozenValue;
  //   });
  //   if (selectedProduct == "Select Product" || dozenValue <= 0) {
  //     setState(() {
  //       eggsList[index] = 0;
  //       rateList[index] = 0;
  //       totalList[index] = 0;
  //     });
  //     return;
  //   }
  //   try {
  //     /// API REFRESH
  //     final List latestProducts = productList;
  //     final Map<String, dynamic>? product = _findProductByName(
  //       latestProducts,
  //       selectedProduct,
  //     );
  //     if (product == null) {
  //       return;
  //     }

  //     /// WEBSITE LOGIC
  //     /// 1 tray = 30 eggs
  //     final int eggsPerTray = 30;

  //     /// UI shows 12 eggs
  //     final int computedEggs = dozenValue * 12;

  //     /// RATE
  //     final double productRate = _extractRateFromProduct(product, eggsPerTray);

  //     /// TOTAL
  //     final double total = computedEggs * productRate;
  //     setState(() {
  //       productList = latestProducts;

  //       eggsList[index] = computedEggs;

  //       rateList[index] = productRate.toStringAsFixed(2);

  //       totalList[index] = total.toStringAsFixed(2);

  //       /// SALES ITEMS UPDATE
  //       salesItems = List.generate(salesItemCount, (i) {
  //         return {
  //           "product_name": selectedProducts[i],
  //           "dozen": dozenList[i],
  //           "eggs": eggsList[i],
  //           "rate": rateList[i],
  //           "total": totalList[i],
  //         };
  //       });
  //       calculateOfferDiscount();

  //       print("salesItems => ");
  //       print(salesItems);
  //     });
  //   } catch (e) {
  //     print("ROW CALC API ERROR => ${e.toString()}");
  //   }
  // }
  Future<void> _recalculateRowFromApi(int index) async {
    final String selectedProduct = selectedProducts[index];

    final String dozenText = dozenControllers[index].text.trim();

    final int dozenValue = int.tryParse(dozenText) ?? 0;

    setState(() {
      dozenList[index] = dozenValue;
    });

    if (selectedProduct == "Select Product" || dozenValue <= 0) {
      setState(() {
        eggsList[index] = 0;
        rateList[index] = 0;
        totalList[index] = 0;
      });

      return;
    }

    try {
      final List latestProducts = productList;

      final Map<String, dynamic>? product = _findProductByName(
        latestProducts,
        selectedProduct,
      );

      if (product == null) {
        return;
      }

      final int eggsPerTray = 30;

      final int computedEggs = dozenValue * 12;

      final double productRate = _extractRateFromProduct(product, eggsPerTray);

      final double total = computedEggs * productRate;

      setState(() {
        eggsList[index] = computedEggs;

        rateList[index] = productRate.toStringAsFixed(2);

        totalList[index] = total.toStringAsFixed(2);

        salesItems = List.generate(salesItemCount, (i) {
          return {
            "product_name": selectedProducts[i],
            "dozen": dozenList[i],
            "eggs": eggsList[i],
            "rate": rateList[i],
            "total": totalList[i],
          };
        });

        calculateOfferDiscount();
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
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        titleSpacing: 0,
        title: const Text(
          "Sales Entry",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Text(
              "Log new sales transactions to automatically update branch inventory.",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
            ),
            const SizedBox(height: 20),
            buildWarehouseDropdown(),

            const SizedBox(height: 20),

            /// TRANSACTION DETAILS
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transaction Details",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  /// CUSTOMER NUMBER
                  buildLabel("Customer Number"),

                  const SizedBox(height: 8),

                  buildTextField(
                    hint: "Enter customer number",
                    controller: customerNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,

                    onChanged: (value) async {
                      if (value.length == 10) {
                        try {
                          final response = await datasource.getCustomerByNumber(
                            value,
                          );

                          print("CUSTOMER RESPONSE =>");
                          print(response);

                          if (response["customer"] != null) {
                            customerNameController.text =
                                response["customer"]["name"]?.toString() ?? "";
                          } else {
                            customerNameController.clear();
                          }
                        } catch (e) {
                          print("CUSTOMER FETCH ERROR => $e");

                          customerNameController.clear();
                        }
                      } else {
                        customerNameController.clear();
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  /// CUSTOMER NAME
                  buildLabel("Customer Name"),
                  const SizedBox(height: 8),
                  buildTextField(
                    hint: "Enter customer name",
                    controller: customerNameController,
                    textOnly: true,
                  ),
                  const SizedBox(height: 18),

                  /// SALES DATE
                  buildLabel("Sales Date"),

                  const SizedBox(height: 8),

                  buildDateField(),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// PRODUCT SELECTION
            isProductLoading
                ? Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 14),
                          Text(
                            "Loading branch stock...",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ProductSelectionWidget(
                    searchController: searchController,
                    filteredProducts: filteredProducts,
                    buildDropdown: buildDropdown(),
                    selectedEggsMap: selectedEggsMap,
                    onSearch: (value) {
                      searchProducts(value);
                    },
                    toNum: _toNum,
                    onProductTap: (productName) async {
                      final product = filteredProducts.firstWhere(
                        (e) => e["product_name"] == productName,
                      );

                      final int actualStock =
                          int.tryParse(
                            (product["stock_eggs"] ?? 0).toString(),
                          ) ??
                          0;

                      final int alreadySelected =
                          selectedEggsMap[productName] ?? 0;

                      /// 1 dozen = 12 eggs
                      const int addEggs = 12;

                      /// BLOCK OVER STOCK
                      if ((alreadySelected + addEggs) > actualStock) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Only ${actualStock - alreadySelected} eggs left",
                            ),
                          ),
                        );

                        return;
                      }

                      /// UPDATE LOCAL STOCK
                      selectedEggsMap[productName] = alreadySelected + addEggs;

                      print("USED STOCK => $selectedEggsMap");

                      /// ADD NEW ROW
                      setState(() {
                        salesItemCount++;

                        selectedProducts.add(productName);

                        dozenList.add(1);

                        eggsList.add(12);

                        final double trayPrice = _toNum(
                          product['per_tray_price'] ?? product['price'] ?? 0,
                        ).toDouble();

                        final double eggRate = trayPrice > 0
                            ? trayPrice / 30
                            : 0;

                        rateList.add(eggRate.toStringAsFixed(2));

                        totalList.add((eggRate * 12).toStringAsFixed(2));

                        dozenControllers.add(TextEditingController(text: "1"));

                        salesItems = List.generate(
                          salesItemCount,
                          (i) => {
                            "product_name": selectedProducts[i],
                            "dozen": dozenList[i],
                            "eggs": eggsList[i],
                            "rate": rateList[i],
                            "total": totalList[i],
                          },
                        );

                        calculateOfferDiscount();
                      });
                    },
                  ),
            const SizedBox(height: 18),

            /// SALES ITEMS
            SalesItemsWidget(
              salesItemCount: salesItemCount,

              offers: salesEntryData["offers"] ?? [],
              onOffersApplied: (indexes) {
                setState(() {
                  appliedOfferIndexes = indexes;
                });

                calculateOfferDiscount();
              },
              onAdd: () {
                setState(() {
                  salesItemCount++;
                  selectedProducts.add("Select Product");
                  _ensureRowCapacity(salesItemCount);
                });
              },

              salesItemRow: (index) => salesItemRow(index),
              salesItems: salesItems,
            ),

            const SizedBox(height: 18),

            /// PAYMENT METHOD
            PaymentSummaryWidget(
              selectedPaymentMethod: selectedPaymentMethod,
              paymentTab: paymentTab,
              buildLabel: buildLabel,
              buildTextField:
                  ({required String hint, TextEditingController? controller}) {
                    return buildTextField(hint: hint, controller: controller);
                  },
              summaryRow: summaryRow,
              itemTrayCount: _itemTrayCount(),
              itemTotal: _itemTotal(),
              offerDiscount: _offerDiscountValue(),
              grandTotal: _grandTotalValue(),
              onSubmit: () async {
                final body = {
                  "login_user_id": loginUserId,

                  /// IMPORTANT
                  "sold_location_id": null,
                  "sold_location": "In_warehouse",
                  "customer_name": customerNameController.text.trim(),

                  "customer_number": customerNumberController.text.trim(),

                  "customer_debit":
                      double.tryParse(debtController.text.trim()) ?? 0,

                  "sales_date": dateController.text.trim(),

                  "payment_method": selectedPaymentMethod.toUpperCase(),

                  "cash_received":
                      double.tryParse(amountController.text.trim()) ?? 0,

                  "sold_to": "Retail",

                  "notes": "",

                  "offer_discount": double.tryParse(_offerDiscountValue()) ?? 0,

                  "grand_total": double.tryParse(_grandTotalValue()) ?? 0,

                  "items": (() {
                    final Map<String, Map<String, dynamic>> grouped = {};

                    for (final item in salesItems) {
                      if (item["product_name"] == "Select Product" ||
                          item["eggs"] == 0) {
                        continue;
                      }

                      final String key = item["product_name"].toString();

                      if (grouped.containsKey(key)) {
                        grouped[key]!["dozen"] =
                            (grouped[key]!["dozen"] ?? 0) +
                            (double.tryParse(item["dozen"].toString()) ?? 0);

                        grouped[key]!["eggs"] =
                            (grouped[key]!["eggs"] ?? 0) +
                            (int.tryParse(item["eggs"].toString()) ?? 0);

                        grouped[key]!["trays"] =
                            (grouped[key]!["trays"] ?? 0) +
                            (((int.tryParse(item["eggs"].toString()) ?? 0) / 30)
                                .ceil());

                        grouped[key]!["total"] =
                            (grouped[key]!["total"] ?? 0) +
                            (double.tryParse(item["total"].toString()) ?? 0);
                      } else {
                        grouped[key] = {
                          "egg_category_grade": key,
                          "dozen":
                              double.tryParse(item["dozen"].toString()) ?? 0,
                          "eggs": int.tryParse(item["eggs"].toString()) ?? 0,
                          "trays":
                              ((int.tryParse(item["eggs"].toString()) ?? 0) /
                                      30)
                                  .ceil(),
                          "total":
                              double.tryParse(item["total"].toString()) ?? 0,
                        };
                      }
                    }

                    return grouped.values.toList();
                  })(),
                };

                print("CREATE SALE BODY =>");
                print(body);
                try {
                  // for (final item in (body["items"] as List)) {
                  //   final singleProductBody = {
                  //     ...body,
                  //     "items": [item],
                  //   };

                  //   print("SINGLE PRODUCT BODY =>");
                  //   print(singleProductBody);

                  //   final response = await datasource.createSale(
                  //     body: singleProductBody,
                  //   );

                  //   print("CREATE SALE RESPONSE =>");
                  //   print(response);
                  // }
                  bool allSuccess = true;

                  for (final item in (body["items"] as List)) {
                    final int trays =
                        int.tryParse(item["trays"].toString()) ?? 1;

                    for (int i = 0; i < trays; i++) {
                      final singleTrayBody = {
                        ...body,

                        "items": [
                          {
                            ...item,

                            "dozen": 1,
                            "eggs": 12,
                            "trays": 1,

                            "total":
                                (double.tryParse(item["total"].toString()) ??
                                    0) /
                                trays,
                          },
                        ],
                      };

                      print("SINGLE TRAY BODY =>");
                      print(singleTrayBody);

                      try {
                        final response = await datasource.createSale(
                          body: singleTrayBody,
                        );

                        print("CREATE SALE RESPONSE =>");
                        print(response);
                      } catch (e) {
                        allSuccess = false;

                        print("API FAILED => $e");

                        break;
                      }
                    }
                  }

                  if (!allSuccess) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Order failed from backend"),
                        ),
                      );
                    }

                    return;
                  }
                  if (allSuccess && context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 60,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "Payment Successful!",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Grand Total : ₹ ${_grandTotalValue()}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Close"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
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
              amountController: amountController,
              debtController: debtController,
            ),

            const SizedBox(height: 30),
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
        width: 220,
        height: 48,

        padding: const EdgeInsets.symmetric(horizontal: 10),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: Colors.grey.shade300),
        ),

        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            /// IMPORTANT
            value:
                warehouseList
                    .where(
                      (e) =>
                          e["branch_name"].toString().toLowerCase() !=
                          "warehouse",
                    )
                    .isNotEmpty
                ? warehouseList.firstWhere(
                    (e) => e["id"].toString() == selectedWarehouseId,
                    orElse: () => warehouseList.first,
                  )
                : null,
            hint: const Text("Select Warehouse"),

            isExpanded: true,

            icon: const Icon(
              Icons.keyboard_arrow_down,

              color: Colors.black,

              size: 20,
            ),

            style: const TextStyle(
              color: Colors.black,

              fontSize: 14,

              fontWeight: FontWeight.w500,
            ),

            dropdownColor: Colors.white,
            items: warehouseList
                .where(
                  (warehouse) =>
                      warehouse["branch_name"].toString().toLowerCase() !=
                      "warehouse",
                )
                .map((warehouse) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: warehouse,

                    child: Text(
                      warehouse["branch_name"].toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                })
                .toList(),

            onChanged: (value) {
              print("SELECTED => $value");

              if (value != null) {
                final int? branchId = int.tryParse(value["id"].toString());

                setState(() {
                  selectedWarehouseId = value["id"].toString();
                  selectedWarehouseName = value["branch_name"].toString();
                });

                if (branchId != null) {
                  reloadProductsForBranch(branchId);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildDateField() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
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
        color: Colors.white,
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
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
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

          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),

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
            width: 16,

            child: Text(
              "$no",

              textAlign: TextAlign.center,

              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          const SizedBox(width: 6),

          /// PRODUCT
          Expanded(
            flex: 4,

            child: Container(
              height: 38,

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

                  style: const TextStyle(color: Colors.black, fontSize: 10),

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

          const SizedBox(width: 6),

          /// DOZEN
          Container(
            width: 40,
            height: 38,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),

              border: Border.all(color: Colors.grey.shade300),
            ),

            child: TextField(
              controller: dozenControllers[no - 1],

              keyboardType: TextInputType.number,

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 12),

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

          const SizedBox(width: 8),

          /// EGGS
          SizedBox(
            width: 24,

            child: Text(
              eggsList.length >= no ? eggsList[no - 1].toString() : "0",

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 12),
            ),
          ),

          const SizedBox(width: 8),

          /// RATE
          SizedBox(
            width: 42,

            child: Text(
              "₹${rateList.length >= no ? rateList[no - 1] : 0}",

              textAlign: TextAlign.center,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(width: 8),

          /// TOTAL
          SizedBox(
            width: 48,

            child: Text(
              "₹${totalList.length >= no ? totalList[no - 1] : 0}",

              textAlign: TextAlign.center,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(width: 6),

          /// DELETE
          GestureDetector(
            onTap: () {
              setState(() {
                int index = no - 1;

                if (selectedProducts.length > index) {
                  selectedProducts.removeAt(index);
                }

                if (dozenControllers.length > index) {
                  dozenControllers[index].dispose();

                  dozenControllers.removeAt(index);
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

          const SizedBox(height: 8),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),

            height: 3,
            width: 40,

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
    while (dozenControllers.length < count) {
      dozenControllers.add(TextEditingController(text: "0"));
    }

    for (int i = 0; i < count; i++) {
      final String value = dozenList[i].toString();
      if (dozenControllers[i].text != value) {
        dozenControllers[i].text = value;
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
    int eggsPerDozen,
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
    if (perTrayRate > 0 && eggsPerDozen > 0) {
      return perTrayRate / eggsPerDozen;
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
