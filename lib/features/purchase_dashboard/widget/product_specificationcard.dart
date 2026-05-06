import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class ProductSpecificationCard extends StatefulWidget {
  final Function(String category) onCategoryChanged;

  final TextEditingController trayController;
  final TextEditingController quantityController;
  final TextEditingController countController;
  final TextEditingController neccController;
  final TextEditingController minusController;
  final TextEditingController rateController;
  final TextEditingController notesController;
  final TextEditingController loadingController;
  final TextEditingController unloadingController;
  final TextEditingController transportController;
  final TextEditingController miscController;

  const ProductSpecificationCard({
    super.key,
    required this.onCategoryChanged,
    required this.trayController,
    required this.quantityController,
    required this.countController,
    required this.neccController,
    required this.minusController,
    required this.rateController,
    required this.notesController,
    required this.loadingController,
    required this.unloadingController,
    required this.transportController,
    required this.miscController,
  });

  @override
  State<ProductSpecificationCard> createState() =>
      _ProductSpecificationCardState();
}

class _ProductSpecificationCardState extends State<ProductSpecificationCard> {
  String? selectedCategory;
  String? selectedTray;
  List<int> specificationCards = [0];
  List<ProductSpecificationModel> specifications = [
    ProductSpecificationModel(),
  ];
  bool isExpanded = false;
  void calculateTotalEggs() {
    int qty = int.tryParse(widget.quantityController.text) ?? 0;

    int totalEggs = qty * 30;

    widget.countController.text = totalEggs.toString();
  }

  final List<String> eggCategories = [
    "White Eggs - Grade A",
    "White Eggs - Grade B",
    "Brown Eggs - Grade A",
    "Brown Eggs - Grade B",
    "Organic Eggs",
  ];
  final List<String> trayType = ["Plastic Tray", "Paper Tray"];
  @override
  void initState() {
    super.initState();

    widget.quantityController.addListener(calculateTotalEggs);
  }

  @override
  void dispose() {
    widget.quantityController.removeListener(calculateTotalEggs);

    super.dispose();
  }

  @override
  // Widget build(BuildContext context) {
  //   final Size size = MediaQuery.of(context).size;
  //   return Column(
  //     children: specificationCards.map((e) {
  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 16),
  //         padding: const EdgeInsets.all(14),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   isExpanded = !isExpanded;
  //                 });
  //               },
  //               child: Row(
  //                 // children: [
  //                 //   Icon(Icons.inventory_2_outlined, color: AppColors.blueAccent),
  //                 //   SizedBox(width: size.width * 0.02),
  //                 //   Expanded(
  //                 //     child: Text(
  //                 //       "Product Specification",
  //                 //       style: AppTextStyles.headingText20,
  //                 //     ),
  //                 //   ),
  //                 //   Icon(
  //                 //     isExpanded
  //                 //         ? Icons.keyboard_arrow_up
  //                 //         : Icons.keyboard_arrow_down,
  //                 //   ),
  //                 // ],
  //                 children: [
  //                   Icon(
  //                     Icons.inventory_2_outlined,
  //                     color: AppColors.blueAccent,
  //                   ),
  //                   SizedBox(width: size.width * 0.02),
  //                   Expanded(
  //                     child: Text(
  //                       "Product Specification",
  //                       style: AppTextStyles.headingText20,
  //                     ),
  //                   ),
  //                   /// PLUS ICON
  //                   IconButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         specifications.add(ProductSpecificationModel());
  //                       });
  //                     },
  //                     icon: const Icon(Icons.add_circle_outline),
  //                   ),
  //                   Icon(
  //                     isExpanded
  //                         ? Icons.keyboard_arrow_up
  //                         : Icons.keyboard_arrow_down,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             if (isExpanded) ...[
  //               const SizedBox(height: 8),
  //               const Divider(),
  //               const SizedBox(height: 10),
  //               // 🔹 1. Egg Category
  //               const Text(
  //                 "Egg Category & Grade",
  //                 style: AppTextStyles.buttonText16,
  //               ),
  //               const SizedBox(height: 6),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 10),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.containerColor,
  //                   border: Border.all(color: AppColors.border),
  //                   borderRadius: BorderRadius.circular(5),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     SizedBox(width: size.width * 0.027),
  //                     Icon(Icons.egg_outlined, color: AppColors.light),
  //                     SizedBox(width: size.width * 0.02),
  //                     Expanded(
  //                       child: DropdownButton<String>(
  //                         value: selectedCategory,
  //                         isExpanded: true,
  //                         hint: const Text("Select Category"),
  //                         underline: const SizedBox(),
  //                         items: eggCategories.map((category) {
  //                           return DropdownMenuItem(
  //                             value: category,
  //                             child: Text(category),
  //                           );
  //                         }).toList(),
  //                         onChanged: (value) {
  //                           setState(() {
  //                             selectedCategory = value;
  //                           });
  //                           widget.onCategoryChanged(value ?? "");
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 14),
  //               // 🔹 2. Quantity
  //               const Text(
  //                 "Number Trays (per Trays of 30 eggs)",
  //                 style: AppTextStyles.buttonText16,
  //               ),
  //               const SizedBox(height: 6),
  //               _buildField(
  //                 controller: widget.quantityController,
  //                 hint: "Enter quantity",
  //                 icon: Icons.grid_view_outlined,
  //                 isNumeric: true,
  //               ),
  //               const SizedBox(height: 14),
  //               const Text(
  //                 "Total Eggs (Auto)",
  //                 style: AppTextStyles.buttonText16,
  //               ),
  //               const SizedBox(height: 6),
  //               _buildField(
  //                 controller: widget.countController,
  //                 hint: "Auto calculated",
  //                 icon: null,
  //                 isNumeric: true,
  //                 enabled: false,
  //               ),
  //               const SizedBox(height: 14),
  //               const Text(
  //                 "NECC Rate(per egg)",
  //                 style: AppTextStyles.buttonText16,
  //               ),
  //               const SizedBox(height: 6),
  //               _buildField(
  //                 controller: widget.neccController,
  //                 hint: "Enter rate per egg",
  //                 icon: null,
  //                 isNumeric: true,
  //                 prefixText: "₹",
  //               ),
  //               const SizedBox(height: 14),
  //               const Text(
  //                 "Market Minus(per egg)",
  //                 style: AppTextStyles.buttonText16,
  //               ),
  //               const SizedBox(height: 6),
  //               _buildField(
  //                 controller: widget.minusController,
  //                 hint: "Enter deduction per egg",
  //                 icon: null,
  //                 isNumeric: true,
  //                 prefixText: "₹ ",
  //               ),
  //               const SizedBox(height: 14),
  //               // 🔹 3. Rate
  //               const Text(
  //                 "Final Rate (per egg)",
  //                 style: AppTextStyles.buttonText16,
  //               ),
  //               const SizedBox(height: 6),
  //               _buildField(
  //                 controller: widget.rateController,
  //                 hint: "Auto calculated final rate",
  //                 icon: null,
  //                 isNumeric: true,
  //                 // enabled: false,
  //                 prefixText: "₹ ",
  //               ),
  //               const SizedBox(height: 14),
  //               const Text("Tray Type", style: AppTextStyles.buttonText16),
  //               const SizedBox(height: 6),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 10),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.containerColor,
  //                   border: Border.all(color: AppColors.border),
  //                   borderRadius: BorderRadius.circular(5),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     SizedBox(width: size.width * 0.027),
  //                     Expanded(
  //                       child: DropdownButton<String>(
  //                         value: selectedTray,
  //                         isExpanded: true,
  //                         hint: const Text("Select Type"),
  //                         underline: const SizedBox(),
  //                         items: trayType.map((category) {
  //                           return DropdownMenuItem(
  //                             value: category,
  //                             child: Text(category),
  //                           );
  //                         }).toList(),
  //                         onChanged: (value) {
  //                           setState(() {
  //                             selectedTray = value;
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 14),
  //               // 🔹 4. Notes
  //               const Text(
  //                 "Additional Costs",
  //                 style: AppTextStyles.buttonText16,
  //               ),
  //               const SizedBox(height: 6),
  //               buildAdditionalCosts(),
  //             ],
  //           ],
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
      children: List.generate(specifications.length, (index) {
        final item = specifications[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),

            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// HEADER
              InkWell(
                onTap: () {
                  setState(() {
                    item.isExpanded = !item.isExpanded;
                  });
                },

                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.blueAccent,
                    ),

                    SizedBox(width: size.width * 0.02),

                    Expanded(
                      child: Text(
                        "Product Specification ${index + 1}",
                        style: AppTextStyles.headingText20,
                      ),
                    ),

                    /// ADD BUTTON
                    IconButton(
                      onPressed: () {
                        setState(() {
                          specifications.add(ProductSpecificationModel());
                        });
                      },

                      icon: const Icon(Icons.add_circle_outline),
                    ),

                    /// REMOVE BUTTON
                    if (specifications.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            specifications.removeAt(index);
                          });
                        },

                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),

                    Icon(
                      item.isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),

              if (item.isExpanded) ...[
                const SizedBox(height: 8),

                const Divider(),

                const SizedBox(height: 10),

                /// CATEGORY
                const Text(
                  "Egg Category & Grade",
                  style: AppTextStyles.buttonText16,
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),

                  decoration: BoxDecoration(
                    color: AppColors.containerColor,

                    border: Border.all(color: AppColors.border),

                    borderRadius: BorderRadius.circular(5),
                  ),

                  child: Row(
                    children: [
                      SizedBox(width: size.width * 0.027),

                      Icon(Icons.egg_outlined, color: AppColors.light),

                      SizedBox(width: size.width * 0.02),

                      Expanded(
                        child: DropdownButton<String>(
                          value: item.selectedCategory,

                          isExpanded: true,

                          hint: const Text("Select Category"),

                          underline: const SizedBox(),

                          items: eggCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setState(() {
                              item.selectedCategory = value;
                            });

                            widget.onCategoryChanged(value ?? "");
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                /// QUANTITY
                const Text("Number Trays", style: AppTextStyles.buttonText16),

                const SizedBox(height: 6),

                _buildField(
                  controller: item.quantityController,

                  hint: "Enter quantity",

                  icon: Icons.grid_view_outlined,

                  isNumeric: true,
                ),

                const SizedBox(height: 14),

                /// TOTAL EGGS
                const Text("Total Eggs", style: AppTextStyles.buttonText16),

                const SizedBox(height: 6),

                _buildField(
                  controller: item.countController,

                  hint: "Auto calculated",

                  isNumeric: true,

                  enabled: false,
                ),

                const SizedBox(height: 14),

                /// NECC RATE
                const Text(
                  "NECC Rate(per egg)",
                  style: AppTextStyles.buttonText16,
                ),

                const SizedBox(height: 6),

                _buildField(
                  controller: item.neccController,

                  hint: "Enter rate",

                  isNumeric: true,

                  prefixText: "₹ ",
                ),

                const SizedBox(height: 14),

                /// MARKET MINUS
                const Text(
                  "Market Minus(per egg)",
                  style: AppTextStyles.buttonText16,
                ),

                const SizedBox(height: 6),

                _buildField(
                  controller: item.minusController,

                  hint: "Enter deduction",

                  isNumeric: true,

                  prefixText: "₹ ",
                ),

                const SizedBox(height: 14),

                /// FINAL RATE
                const Text(
                  "Final Rate(per egg)",
                  style: AppTextStyles.buttonText16,
                ),

                const SizedBox(height: 6),

                _buildField(
                  controller: item.rateController,

                  hint: "Final rate",

                  isNumeric: true,

                  prefixText: "₹ ",
                ),

                const SizedBox(height: 14),

                /// TRAY TYPE
                const Text("Tray Type", style: AppTextStyles.buttonText16),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),

                  decoration: BoxDecoration(
                    color: AppColors.containerColor,

                    border: Border.all(color: AppColors.border),

                    borderRadius: BorderRadius.circular(5),
                  ),

                  child: DropdownButton<String>(
                    value: item.selectedTray,

                    isExpanded: true,

                    underline: const SizedBox(),

                    hint: const Text("Select Tray"),

                    items: trayType.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        item.selectedTray = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 14),

                /// ADDITIONAL COSTS
                const Text(
                  "Additional Costs",
                  style: AppTextStyles.buttonText16,
                ),

                const SizedBox(height: 6),

                buildAdditionalCosts(),
              ],
            ],
          ),
        );
      }),
    );
  }

  // 🔧 Reusable Field
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    int maxLines = 1,
    IconData? icon,
    bool isNumeric = false,
    String? prefixText, // 👈 add this
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
        enabled: enabled,
        maxLines: maxLines,
        style: AppTextStyles.formInputs15,
        keyboardType: isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,

        inputFormatters: isNumeric
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
            : [],
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.light) : null,
          prefixText: prefixText,
        ),
      ),
    );
  }

  Widget buildAdditionalCosts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Additional Costs", style: AppTextStyles.buttonText16),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _costField("Loading Charges", widget.loadingController),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _costField("Unloading", widget.unloadingController),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              Expanded(
                child: _costField("Transport", widget.transportController),
              ),

              const SizedBox(width: 10),
              Expanded(
                child: _costField("Misc Expenses", widget.miscController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyText14),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: "Enter amount",
              prefixText: "₹ ",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductSpecificationModel {
  TextEditingController quantityController = TextEditingController();

  TextEditingController countController = TextEditingController();

  TextEditingController neccController = TextEditingController();

  TextEditingController minusController = TextEditingController();

  TextEditingController rateController = TextEditingController();

  String? selectedCategory;
  String? selectedTray;
  bool isExpanded = true;
}
