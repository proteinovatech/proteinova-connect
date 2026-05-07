import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/sales/widget/buildcustomerinput.dart';
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

  final List<String> tabs = ["Cash", "UPI", "Card"];
  List<IconData> tabIcons = [
    Icons.money,
    Icons.phone_android_outlined,
    Icons.credit_card,
  ];
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

  @override
  void initState() {
    super.initState();

    loginUserId = 6;
  }

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
          Text("Product Details", style: AppTextStyles.headingText20),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search Product by name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          // const SizedBox(height: 14),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Buy 5 Trays Get 1 Free ",
                            style: AppTextStyles.headingText22.copyWith(
                              color: AppColors.textPrimary, // first color
                            ),
                          ),
                          TextSpan(
                            text: "(White eggs)",
                            style: AppTextStyles.headingText22.copyWith(
                              color: Colors.grey, // second color
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background1,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Remove",
                              style: AppTextStyles.containerText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amber600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Accept",
                              style: AppTextStyles.containerText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
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
                  if (showCustomerInput) buildCustomerInput(),
                ],
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
                      height: size.height * 0.05,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tabs.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 20),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? AppColors.amber500.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        tabIcons[index],
                                        color: selectedIndex == index
                                            ? AppColors.dark
                                            : Colors.grey,
                                      ),
                                      // SizedBox(width: 5),
                                      const SizedBox(width: 5),
                                      Text(
                                        tabs[index],
                                        style: AppTextStyles.bodyText16
                                            .copyWith(
                                              color: selectedIndex == index
                                                  ? AppColors.dark
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 3,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 250, 246, 246),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: Alignment(
                            -1 + (2 / (tabs.length - 1)) * selectedIndex,
                            0,
                          ),
                          child: Container(
                            height: 3,
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppColors.amber500,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Cash Received", style: AppTextStyles.headingText20),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // child: const TextField(
                      //   keyboardType: TextInputType.number,
                      //   decoration: InputDecoration(
                      //     prefixText: "₹ ",
                      //     hintText: "Enter amount",
                      //     border: InputBorder.none,
                      //   ),
                      // ),
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
        //   Visibility(
        //     visible: showNotesSection,
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         const Text(
        //           "Additional Notes",
        //           style: AppTextStyles.buttonText16,
        //         ),
        //         const SizedBox(height: 6),

        //         _buildField(
        //           controller: widget.notesController,
        //           hint: "Add any details about this transaction...",
        //           maxLines: 3,
        //         ),

        //         SizedBox(height: size.height * 0.03),
        //         const Divider(),
        //         SizedBox(height: size.height * 0.02),

        //         Row(
        //           children: [
        //             GestureDetector(
        //               onTap: () {
        //                 setState(() {
        //                   widget.categoryController.clear();
        //                   widget.quantityController.clear();
        //                   widget.nameController.clear();
        //                   widget.notesController.clear();

        //                   selectedCategory = null;
        //                   selectedIncrement = null;
        //                   showNotesSection = false; // 👈 hide again
        //                 });
        //               },
        //               child: Container(
        //                 padding: const EdgeInsets.symmetric(
        //                   horizontal: 10,
        //                   vertical: 5,
        //                 ),
        //                 decoration: BoxDecoration(
        //                   color: AppColors.background1,
        //                   borderRadius: BorderRadius.circular(6),
        //                 ),
        //                 child: Text(
        //                   "Clear Form",
        //                   style: AppTextStyles.containerText,
        //                 ),
        //               ),
        //             ),

        //             SizedBox(width: size.width * 0.29),

        //             Container(
        //               padding: const EdgeInsets.symmetric(
        //                 horizontal: 10,
        //                 vertical: 5,
        //               ),
        //               decoration: BoxDecoration(
        //                 color: AppColors.amber600,
        //                 borderRadius: BorderRadius.circular(6),
        //               ),
        //               child: Row(
        //                 children: [
        //                   Icon(Icons.check, color: AppColors.dark),
        //                   const SizedBox(width: 4),
        //                   Text("Log Sale", style: AppTextStyles.containerText),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
        //
        //
     ] ),
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
