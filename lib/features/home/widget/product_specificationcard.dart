import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class ProductSpecificationCard extends StatefulWidget {
  final TextEditingController categoryController;
  final TextEditingController quantityController;
  final TextEditingController rateController;
  final TextEditingController notesController;

  const ProductSpecificationCard({
    super.key,
    required this.categoryController,
    required this.quantityController,
    required this.rateController,
    required this.notesController,
  });

  @override
  State<ProductSpecificationCard> createState() => _ProductSpecificationCardState();
}

class _ProductSpecificationCardState extends State<ProductSpecificationCard> {
  String? selectedCategory;

final List<String> eggCategories = [
  "White Eggs - Grade A",
  "White Eggs - Grade B",
  "Brown Eggs - Grade A",
  "Brown Eggs - Grade B",
  "Organic Eggs",
];

  @override
  Widget build(BuildContext context) {
     final Size size=MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Row(
      children: [
        Icon(Icons.inventory_2_outlined, color: AppColors.amber600),
        SizedBox(width: size.width * 0.02),
        Text(
          "Product Specification",
          style: AppTextStyles.headingText21,
        ),
      ],
    ),

    const SizedBox(height: 8),
    const Divider(),
    const SizedBox(height: 10),

    // 🔹 1. Egg Category
    const Text("Egg Category & Grade", style: AppTextStyles.buttonText16),
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
          Icon(Icons.egg_outlined,color: AppColors.light,),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: DropdownButton<String>(
              value: selectedCategory,
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
                  selectedCategory = value;
                });
              },
            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 14),

    // 🔹 2. Quantity
    const Text("Quantity (Tray of 30)", style: AppTextStyles.buttonText16),
    const SizedBox(height: 6),
    _buildField(
      controller: widget.quantityController,
      hint: "Enter quantity",
      icon: Icons.grid_view_outlined,
      isNumeric: true
    ),

    const SizedBox(height: 14),

    // 🔹 3. Rate
    const Text("Rate per Box (INR)", style: AppTextStyles.buttonText16),
    const SizedBox(height: 6),
    _buildField(
      controller: widget.rateController,
      hint: "Enter rate",
      icon: Icons.attach_money_outlined,
      isNumeric: true
    ),

    const SizedBox(height: 14),

    // 🔹 4. Notes
    const Text("Additional Notes", style: AppTextStyles.buttonText16),
    const SizedBox(height: 6),
    _buildField(
      controller: widget.notesController,
      hint: "Add any notes regarding quality,\ntransport...",
      maxLines: 3,
    ),
  ],
),
  );}

  // 🔧 Reusable Field
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
     IconData? icon,
     bool isNumeric = false,  // 👈 add this
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
        maxLines: maxLines,
        style: AppTextStyles.formInputs15,
         keyboardType:
          isNumeric ? TextInputType.number : TextInputType.text, // 👈

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
}