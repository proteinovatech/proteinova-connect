import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch/sales/widget/eggitemcard.dart';
import 'package:proteinova_connect/features/sales/widget/buildcustomerinput.dart';

class TransactionDetailscard extends StatefulWidget {
  final TextEditingController categoryController;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  final TextEditingController notesController;

  const TransactionDetailscard({
    super.key,
    required this.categoryController,
    required this.quantityController,
    required this.nameController,
    required this.notesController,
  });
  @override
  State<TransactionDetailscard> createState() => _TransactionDetailscardState();
}

class _TransactionDetailscardState extends State<TransactionDetailscard> {
  List<String> items = [];
  String? selectedCategory;
  int? selectedIncrement;
  bool showNotesSection = false;
  bool showCustomerInput = false;
  String? selectedPayment;
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

  final List<String> tabs = ["Cash", "UPI"];
  List<IconData> tabIcons = [Icons.money, Icons.phone_android_outlined];
  Map<String, dynamic> offerCard = {};
  List<dynamic> offersList = [];
  bool isLoadingOffers = true;
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getInt("branch_id");

      final response = await http.get(
        Uri.parse("$baseUrl/api/offers/dashboard?branch_id=$branchId"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            offerCard = decodedData["data"]["card"] ?? {};
            offersList = decodedData["data"]["offers_list"] ?? [];
            isLoadingOffers = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingOffers = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingOffers = false;
        });
      }
      print("OFFERS ERROR : $e");
    }
  }

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
                      "price": tray["price"] ?? "0",
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
                  Text("Customer Details", style: AppTextStyles.headingText22),
               GestureDetector(
  onTap: () {
    setState(() {
      showCustomerInput = !showCustomerInput;
    });
  },

  child: const SizedBox(),
),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
            ],
          ),

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
                            Text(item["Stock"] ?? "",
                              style: AppTextStyles.bodyText14,
                            ),
                                                    ],
                        ),
                        Column(
                          children: [
                               Text(
      "Dozen",
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 6),
                            Row(
                              children: [
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
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _offerCountCard(
                          "Active",
                          offerCard["active_offers"]?.toString() ?? "0",
                          Colors.green,
                        ),

                        _offerCountCard(
                          "Products",
                          offerCard["products_on_offer"]?.toString() ?? "0",
                          Colors.orange,
                        ),

                        _offerCountCard(
                          "Expiring",
                          offerCard["expiring_soon"]?.toString() ?? "0",
                          Colors.red,
                        ),

                        _offerCountCard(
                          "Inactive",
                          offerCard["deactive_offers"]?.toString() ?? "0",
                          Colors.grey,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    isLoadingOffers
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : offersList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "No Offers Available",
                                style: AppTextStyles.bodyText14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: offersList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),

                            itemBuilder: (context, index) {
                              final offer = offersList[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),

                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${offer["offer_name"] ?? ""} ",
                                            style: AppTextStyles.headingText22
                                                .copyWith(
                                                  color: AppColors.textPrimary,
                                                ),
                                          ),

                                          TextSpan(
                                            text:
                                                "(${offer["product_name"] ?? "Product"})",
                                            style: AppTextStyles.headingText22
                                                .copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    if (offer["offer_type"] == "buy_x_get_y")
                                      Text(
                                        "Buy ${offer["buy_qty"]} Get ${offer["free_qty"]} Free",
                                        style: AppTextStyles.bodyText14
                                            .copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),

                                    if (offer["discount_value"] != null)
                                      Text(
                                        "Discount: ${offer["discount_value"]} per ${offer["discount_unit"] ?? "unit"}",
                                        style: AppTextStyles.bodyText14
                                            .copyWith(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.w600,
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

                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),

                                            child: Text(
                                              "Remove",
                                              style:
                                                  AppTextStyles.containerText,
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

                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),

                                            child: Text(
                                              "Accept",
                                              style:
                                                  AppTextStyles.containerText,
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? icon,
    bool isNumeric = false,
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
            ? [FilteringTextInputFormatter.digitsOnly]
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
          selectedItems.add({
            "title": title,
            "price": price.replaceAll("\$", ""),
            "stock": stock,
            "qty": "1",
          });
        });
      },
      child: EggItemCard(title: title, price: price, Stock: stock),
    );
  }

 Widget _offerCountCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
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
            Text(title, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}
