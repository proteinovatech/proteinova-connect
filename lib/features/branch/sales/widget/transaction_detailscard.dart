import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/sales/widget/buildrow.dart';
import 'package:proteinova_connect/features/branch/sales/widget/eggitemcard.dart';

class TransactionDetailscard extends StatefulWidget {
  final TextEditingController categoryController;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  final TextEditingController notesController;
 final VoidCallback onCollectPayment;

  const TransactionDetailscard({
    super.key,
    required this.categoryController,
    required this.quantityController,
    required this.nameController,
    required this.notesController,
     required this.onCollectPayment, 
  });
  @override
  State<TransactionDetailscard> createState() => _TransactionDetailscardState();
}

class _TransactionDetailscardState extends State<TransactionDetailscard> {
  List<String> items = [];
  final TextEditingController cashController = TextEditingController();
  String? selectedCategory;
  int? selectedIncrement;
  bool showNotesSection = false;
  bool showCustomerInput = false;
  int selectedIndex = 0;
  String? selectedPayment;
  int? loginUserId;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  List<Map<String, String>> selectedItems = [];
  final List<String> eggCategories = [
    "White Eggs (Tray)",
    "Brown Eggs (Tray)",
    "Organic Eggs (Tray)",
  ];
  List<Map<String, String>> allTrays = [
    {"title": "White Eggs", "price": "\$76", "Stock": "2,430"},
    {"title": "Brown Eggs", "price": "\$40", "Stock": "1,200"},
    {"title": "Medium Eggs", "price": "\$55", "Stock": "850"},
    {"title": "Plastic Trays", "price": "\$70", "Stock": "3,100"},
    {"title": "Paper Trays", "price": "\$110", "Stock": "540"},
    {"title": "Empty Trays", "price": "\$120", "Stock": " 300"},
  ];
String selectedDate = "Select sales date";
 final TextEditingController numberController =
    TextEditingController();

final TextEditingController nameController =
    TextEditingController();

String customerStatus = "";
bool customerFound = false;
  List<dynamic> customers = [];
  Map<String, dynamic> offerCard = {};

List<dynamic> offersList = [];

bool isLoadingOffers = false;

  void showTrayList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: allTrays.length,
          itemBuilder: (context, index) {
            final tray = allTrays[index];
            return ListTile(
              title: Text(tray["title"] ?? ""),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${tray["price"] ?? "0"} per tray"),
                  Text("Stock: ${tray["Stock"] ?? ""}"),
                ],
              ),
              onTap: () {
                setState(() {
                  if (!selectedItems.any(
                    (item) => item["title"] == tray["title"],
                  )) {
                    selectedItems.add({
                      "title": tray["title"] ?? "",
                      "price": (tray["price"] ?? "0").replaceAll("\$", ""),
                      "stock": tray["Stock"] ?? "",
                      "qty": "1",
                    });
                  }
                });

                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> saveSale(int totalAmount) async {
    try {
      for (var item in selectedItems) {
        int qty = int.tryParse(item["qty"] ?? "1") ?? 1;

        int stock =
            int.tryParse(
              item["stock"]
                      ?.replaceAll(",", "")
                      .replaceAll("Stock:", "")
                      .trim() ??
                  "0",
            ) ??
            0;

        if (qty > stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Not enough stock for ${item["title"]}")),
          );

          return;
        }
      }
      final response = await http.post(
        Uri.parse("$baseUrl/api/sales"),
        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "login_user_id": loginUserId,

          "customer_name": widget.nameController.text,

          "customer_number": "",

          "customer_debit": 0,

          "dispatch_date": DateTime.now().toString().split(" ")[0],

          "payment_method": tabs[selectedIndex].toUpperCase(),

          "cash_received": int.tryParse(cashController.text) ?? 0,

          "sold_to": "Retail",

          "sold_location": "Branch",

          "notes": widget.notesController.text,

          "items": selectedItems.map((item) {
            return {
              "egg_category_grade": item["title"],

              "trays": int.tryParse(item["qty"] ?? "1") ?? 1,
            };
          }).toList(),
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sale Saved Successfully")),
        );

        setState(() {
          selectedItems.clear();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to save sale")));
      }
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
Future<void> checkCustomer() async {
  try {
    final response = await http.get(
      Uri.parse(
        "https://proteinova-system.onrender.com/api/customers",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);
    final customers = data["data"];

      final existingCustomer = customers.firstWhere(
        (customer) =>
            customer["number"].toString() ==
            numberController.text,

        orElse: () => null,
      );

      if (existingCustomer != null) {
        setState(() {
          customerFound = true;

          customerStatus = "Customer Found";

          nameController.text =
              existingCustomer["name"];
        });
      } else {
        setState(() {
          customerFound = false;

          customerStatus =
              "Customer Not Found";

          nameController.clear();
        });
      }
    }
  } catch (e) {
    print(e);
  }
}
Future<void> saveCustomer() async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/api/customers"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "name": nameController.text,
        "number": numberController.text,
      }),
    );

    final data = jsonDecode(response.body);

    print(data["message"]);
  } catch (e) {
    print(e);
  }
}
  @override
  void initState() {
    super.initState();

    loginUserId = 6;
  }
    
  final TextEditingController debitController =
      TextEditingController();

  final List<String> tabs = [
    "Cash",
    "UPI",
  ];

  List<IconData> tabIcons = [
    Icons.money,
    Icons.phone_android_outlined,
  ];

  double totalAmount = 5300;


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    int totalQty = 0;
    int subTotal = 0;
    int totalItems = selectedItems.length;
    for (var item in selectedItems) {
      int price = int.tryParse(item["price"] ?? "0") ?? 0;
      int qty = int.tryParse(item["qty"] ?? "1") ?? 1;

      totalQty += qty;
      subTotal += price * qty;
    }

    int tax = 0;
    int totalAmount = subTotal + tax;
    print("Items: $totalItems");
    print("Qty: $totalQty");
    print("Subtotal: $subTotal");
    print("Total: $totalAmount");
    if (cashController.text != totalAmount.toString()) {
      cashController.text = totalAmount.toString();
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Customer Details",
          style: AppTextStyles.headingText22,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showCustomerInput = !showCustomerInput;
            });
          },
          child: Icon(
            showCustomerInput
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_up,
          ),
        ),
      ],
    ),

    const SizedBox(height: 10),
    const Divider(),
    const SizedBox(height: 10),

    if (showCustomerInput)
      Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: Column(
          children: [
          
        Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Number",
          ),
          const SizedBox(height: 6),
          TextField(
            controller: numberController,
            keyboardType:
                TextInputType.phone,
            onChanged: (value) {
              if (value.length == 10) {
                checkCustomer();
              } else {
                setState(() {
                  customerStatus = "";
                  nameController.clear();
                });
              }
            },

            decoration: InputDecoration(
              hintText: "Enter number",

              prefixIcon: const Icon(
                Icons.phone_outlined,
                size: 18,
              ),

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                      Colors.grey.shade300,
                ),
              ),
            ),
          ),

          if (customerStatus.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 5,
              ),

              child: Text(
                customerStatus,

                style: TextStyle(
                  color: customerFound
                      ? Colors.green
                      : Colors.red,

                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    ),

    const SizedBox(width: 15),

    Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Name",
          ),
          const SizedBox(height: 6),
        TextField(
  controller: nameController,
   readOnly: customerFound,
  decoration: InputDecoration(
    hintText: "Enter name",
    prefixIcon: const Icon(
      Icons.person_outline,
      size: 18,
    ),
    contentPadding:
        const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),

  ),
) ],
      ),
    ),
  ],
), const SizedBox(height: 15),
         Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Sales Date",
    ),

    const SizedBox(height: 6),

    Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          Text(
            selectedDate,
            style: TextStyle(
              color: selectedDate ==
                      "Select sales date"
                  ? Colors.grey
                  : Colors.black,
            ),
          ),

          IconButton(
            onPressed: () async {
              DateTime? pickedDate =
                  await showDatePicker(
                context: context,

                initialDate: DateTime.now(),

                firstDate: DateTime(2000),

                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  selectedDate =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                });
              }
            },

            icon: const Icon(
              Icons.calendar_month_outlined,
              size: 20,
            ),
          ),
        ],
      ),
    ),
  ],
),
SizedBox(height: 10,),
Align(
  alignment: Alignment.centerRight,

  child:GestureDetector(
  onTap: () async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/customers"),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({
          "name":
              nameController.text,

          "number":
              numberController.text,
        }),
      );

      final data =
          jsonDecode(response.body);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            data["message"],
          ),
        ),
      );

      print(data);
    } catch (e) {
      print(e);
    }
  },

  child: Container(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),

    decoration: BoxDecoration(
      color: Colors.yellowAccent,

      borderRadius:
          BorderRadius.circular(10),
    ),

    child: const Text(
      "Save",

      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  ),
))],
        ),
      ),
  ],
),  SizedBox(height: 10),
          Text("Product Details", style: AppTextStyles.headingText20),
          const SizedBox(height: 10),
         
          const Text("Select Product", style: AppTextStyles.buttonText16),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                SizedBox(width: size.width * 0.027),
                Icon(Icons.inventory_2_outlined, color: AppColors.light),
                SizedBox(width: size.width * 0.02),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    hint: const Text("All Category"),
                    underline: const SizedBox(),
                    items: eggCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
           const SizedBox(height: 14),
          // Visibility(
          //   visible: false, // 👈 change to true when needed
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text(
          //         "Quantity Sold (Units/Trays)",
          //         style: AppTextStyles.buttonText16,
          //       ),
          //       const SizedBox(height: 6),
          //       _buildField(
          //         controller: widget.quantityController,
          //         hint: "Enter quantity",
          //         icon: null,
          //         isNumeric: true,
          //       ),
          //       const SizedBox(height: 10),

          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //         children: [10, 20, 50, 100].map((value) {
          //           final isSelected = selectedIncrement == value;

          //           return GestureDetector(
          //             onTap: () {
          //               int current =
          //                   int.tryParse(widget.quantityController.text) ?? 0;

          //               setState(() {
          //                 selectedIncrement = value;
          //                 widget.quantityController.text = (current + value)
          //                     .toString();
          //               });
          //             },
          //             child: Container(
          //               padding: const EdgeInsets.symmetric(
          //                 horizontal: 16,
          //                 vertical: 8,
          //               ),
          //               decoration: BoxDecoration(
          //                 color: isSelected
          //                     ? AppColors.containerColor2
          //                     : AppColors.containerColor,
          //                 border: Border.all(
          //                   color: isSelected
          //                       ? AppColors.border2
          //                       : AppColors.border,
          //                 ),
          //                 borderRadius: BorderRadius.circular(20),
          //               ),
          //               child: Text(
          //                 "+$value",
          //                 style: isSelected
          //                     ? AppTextStyles.containerText.copyWith(
          //                         fontWeight: FontWeight.bold,
          //                         color: AppColors.dark,
          //                       )
          //                     : AppTextStyles.containerText,
          //               ),
          //             ),
          //           );
          //         }).toList(),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 14),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Product Details", style: AppTextStyles.headingText20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    _buildItem("White Eggs", "\$76", "Stock: 2,430"),
                    _buildItem("Brown Eggs", "\$40", "Stock: 1,200"),
                    _buildItem("Medium Eggs", "\$55", "Stock: 850"),
                    _buildItem("Plastic Trays", "\$70", "Stock: 3,100"),
                    _buildItem("Paper Trays", "\$110", "Stock: 540"),
                    _buildItem("Empty Trays", "\$120", "Stock: 300"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Sales Items", style: AppTextStyles.headingText20),
                    GestureDetector(
                      onTap: showTrayList,
                      child: Icon(Icons.add, color: AppColors.dark),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...selectedItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  int price = int.tryParse(item["price"] ?? "0") ?? 0;
                  int qty = int.tryParse(item["qty"] ?? "1") ?? 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.containerColor2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"] ?? "",
                              style: AppTextStyles.headingText20,
                            ),
                            Text("${item["price"] ?? "0"} per tray"),
                            Text(
                              item["stock"] ?? "",
                              style: AppTextStyles.bodyText14,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            /// ➖ BUTTON
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  int qty = int.parse(item["qty"] ?? "1");
                                  if (qty > 1) {
                                    qty--;
                                    item["qty"] = qty.toString();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.remove, size: 18),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item["qty"] ?? "1",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  int qty = int.parse(item["qty"] ?? "1");
                                  qty++;
                                  item["qty"] = qty.toString();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.add, size: 18),
                              ),
                            ),

                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedItems.removeAt(index);
                                });
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Offers", style: AppTextStyles.headingText20),
              const SizedBox(height: 10),
                           Container(
                padding: const EdgeInsets.all(14),
              
                decoration: BoxDecoration(
                  color: AppColors.background,
              
                  border: Border.all(
                    color: AppColors.border,
                  ),
              
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
              
                      children: [
                        _offerCountCard(
                          "Active",
              
                          offerCard["active_offers"]
                                  ?.toString() ??
                              "0",
              
                          Colors.green,
                        ),
              
                        _offerCountCard(
                          "Products",
              
                          offerCard[
                                      "products_on_offer"]
                                  ?.toString() ??
                              "0",
              
                          Colors.orange,
                        ),
              
                        _offerCountCard(
                          "Expiring",
              
                          offerCard[
                                      "expiring_soon"]
                                  ?.toString() ??
                              "0",
              
                          Colors.red,
                        ),
              
                        _offerCountCard(
                          "Inactive",
              
                          offerCard[
                                      "deactive_offers"]
                                  ?.toString() ??
                              "0",
              
                          Colors.grey,
                        ),
                      ],
                    ),
              
                    const SizedBox(height: 16),
              
                    isLoadingOffers
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
              
                        : offersList.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.all(
                                  20,
                                ),
              
                                child: Text(
                                  "No Offers Available",
              
                                  style:
                                      AppTextStyles
                                          .bodyText14,
                                ),
                              )
              
                            : ListView.builder(
                                itemCount:
                                    offersList.length,
              
                                shrinkWrap: true,
              
                                physics:
                                    const NeverScrollableScrollPhysics(),
              
                                itemBuilder:
                                    (context, index) {
              
                                  final offer =
                                      offersList[index];
              
                                  return Container(
                                    margin:
                                        const EdgeInsets.only(
                                      bottom: 10,
                                    ),
              
                                    padding:
                                        const EdgeInsets.all(
                                      12,
                                    ),
              
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.white,
              
                                      borderRadius:
                                          BorderRadius.circular(
                                        10,
                                      ),
              
                                      border:
                                          Border.all(
                                        color: Colors
                                            .grey
                                            .shade300,
                                      ),
                                    ),
              
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
              
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    "${offer["offer_text"] ?? ""} ",
              
                                                style:
                                                    AppTextStyles
                                                        .headingText22
                                                        .copyWith(
                                                  color:
                                                      AppColors
                                                          .textPrimary,
                                                ),
                                              ),
              
                                              TextSpan(
                                                text:
                                                    "(${offer["product_name"] ?? "Product"})",
              
                                                style:
                                                    AppTextStyles
                                                        .headingText22
                                                        .copyWith(
                                                  color:
                                                      Colors
                                                          .grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
              
                                        const SizedBox(
                                          height: 12,
                                        ),
              
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .end,
              
                                          children: [
                                            GestureDetector(
                                              onTap: () {},
              
                                              child:
                                                  Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal:
                                                      12,
              
                                                  vertical:
                                                      6,
                                                ),
              
                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      AppColors
                                                          .background1,
              
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    6,
                                                  ),
                                                ),
              
                                                child: Text(
                                                  "Remove",
              
                                                  style:
                                                      AppTextStyles
                                                          .containerText,
                                                ),
                                              ),
                                            ),
              
                                            const SizedBox(
                                              width: 10,
                                            ),
              
                                            GestureDetector(
                                              onTap: () {},
              
                                              child:
                                                  Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal:
                                                      12,
              
                                                  vertical:
                                                      6,
                                                ),
              
                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      AppColors
                                                          .amber600,
              
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    6,
                                                  ),
                                                ),
              
                                                child: Text(
                                                  "Accept",
              
                                                  style:
                                                      AppTextStyles
                                                          .containerText,
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
              ),SizedBox(height: 10),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Bill Summery", style: AppTextStyles.headingText22),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 218, 217, 217),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSummaryRow("Items", "$totalItems"),

                    buildSummaryRow("Trays", "$totalQty"),
                    const SizedBox(height: 5),
                    const Divider(),

                    buildSummaryRow("Sub Total", "₹$subTotal", isBold: true),
                    const Divider(),

                    buildSummaryRow("Tax(0%)", "₹$tax"),
                    const SizedBox(height: 5),
                    const Divider(),

                    buildSummaryRow(
                      "Total Amount",
                      "₹$totalAmount",
                      isBold: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
             
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Method", style: AppTextStyles.headingText22),
                    const SizedBox(height: 10),
            SizedBox(
  height: size.height * 0.06,
  child: Row(
    children: List.generate(tabs.length, (index) {
      final bool isSelected = selectedIndex == index;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;

              // Auto fill when UPI selected
              if (tabs[index] == "UPI") {
                cashController.text = totalAmount.toString();
              } else {
                cashController.clear();
              }
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tabIcons[index],
                    color: isSelected
                        ? AppColors.dark
                        : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tabs[index],
                    style: AppTextStyles.bodyText16.copyWith(
                      color: isSelected
                          ? AppColors.dark
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Yellow line only under selected item
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                width: isSelected ? 80 : 0,
                decoration: BoxDecoration(
                  color: AppColors.amber500,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      );
    }),
  ),
),
const SizedBox(height: 16),

// ---------- CASH TAB ----------
if (selectedIndex == 0) ...[
  Text(
    "Cash Received",
    style: AppTextStyles.headingText20,
  ),

  const SizedBox(height: 10),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.background,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
      controller: cashController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        prefixText: "₹ ",
        hintText: "Enter amount",
        border: InputBorder.none,
      ),
    ),
  ),

  const SizedBox(height: 16),

  Text(
    "Debit(Optional)",
    style: AppTextStyles.headingText20,
  ),

  const SizedBox(height: 10),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.background,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
      controller: debitController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Enter debit amount",
        border: InputBorder.none,
      ),
    ),
  ),
],

// ---------- UPI TAB ----------
if (selectedIndex == 1) ...[
  Text(
    "UPI Payment",
    style: AppTextStyles.headingText20,
  ),

  const SizedBox(height: 10),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.background,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount Received",
          style: AppTextStyles.bodyText16,
        ),

        const SizedBox(height: 6),

        Text(
          "₹ ${cashController.text}",
          style: AppTextStyles.headingText20.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Change", style: AppTextStyles.containerText),
                        Text("₹20.00", style: AppTextStyles.headingText20),
                      ],
                    ),
                    SizedBox(height: 10),
                  GestureDetector(
   onTap: widget. onCollectPayment,
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: Colors.green,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        "Collect Payment   ₹$totalAmount",
        style: AppTextStyles.containerText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
) ],
                ),
              ),
            ],
          ),
       
      ] ),
    );
  }
Widget _offerCountCard(
  String title,
  String count,
  Color color,
) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),

      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),

      child: Column(
        children: [
          Text(
            count,

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,

            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? icon,
    bool isNumeric = false, // 👈 add this
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.formInputs15,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric
            ? [FilteringTextInputFormatter.digitsOnly] // 👈 only numbers
            : [],
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.light) : null,
        ),
      ),
    );
  }

  Widget _buildItem(String title, String price, String stock) {
    return InkWell(
      onTap: () {
        setState(() {
          if (!selectedItems.any((item) => item["title"] == title)) {
            selectedItems.add({
              "title": title,
              "price": price.replaceAll("\$", ""),
              "stock": stock,
              "qty": "1",
            });
          }
        });
      },
      child: EggItemCard(title: title, price: price, Stock: stock),
    );
  }
}
