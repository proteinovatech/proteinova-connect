import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

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
  String? selectedCategory;
  int? selectedIncrement;

final List<String> eggCategories = [
  "White Eggs (Tray)",
  "Brown Eggs (Tray)",
  "Organic Eggs (Tray)",
];

  @override
  Widget build(BuildContext context) {
     final Size size=MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
       
      ),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
          "Transaction Details",
          style: AppTextStyles.headingText20,
        ),
      
    
    const SizedBox(height: 10),

    // 🔹 1. Egg Category
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
          Icon(Icons.inventory_2_outlined,color: AppColors.light,),
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
    const Text("Quantity Sold (Units/Trays)", style: AppTextStyles.buttonText16),
    const SizedBox(height: 6),
    _buildField(
      controller: widget.quantityController,
      hint: "Enter quantity",
      icon: null,
      isNumeric: true
    ),
    const SizedBox(height: 10),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [10, 20, 50, 100].map((value) {
    final isSelected = selectedIncrement == value;

    return GestureDetector(
      onTap: () {
        int current = int.tryParse(widget.quantityController.text) ?? 0;

        setState(() {
          selectedIncrement = value; // 👈 track selected
          widget.quantityController.text = (current + value).toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.containerColor2: AppColors.containerColor,
          border: Border.all(
            color: isSelected ? AppColors.border2 : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "+$value",
          style: isSelected
              ? AppTextStyles.containerText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                )
              : AppTextStyles.containerText,
        ),
      ),
    );
  }).toList(),
),
    const SizedBox(height: 14),

    // 🔹 3. Rate
    const Text("Customer / Reference (Optional)", style: AppTextStyles.buttonText16),
    const SizedBox(height: 6),
    _buildField(
      controller: widget.nameController,
      hint: " Name of Customer",
      icon: Icons.person_outline,
      
    ),

    const SizedBox(height: 14),

    // 🔹 4. Notes
    const Text("Additional Notes", style: AppTextStyles.buttonText16),
    const SizedBox(height: 6),
    _buildField(
      controller: widget.notesController,
      hint: "Add any details about this transaction...",
      maxLines: 3,
    ),
    SizedBox(height: size.height*0.03,),
    Divider(),
    SizedBox(height: size.height*0.02 ,),
    Row(
      children: [     
        GestureDetector(
          onTap: () {
    setState(() {
      widget.categoryController.clear();
      widget.quantityController.clear();
      widget.nameController.clear();
      widget.notesController.clear();

      selectedCategory = null;       // reset dropdown
      selectedIncrement = null;      // reset +buttons (if using)
    });
  },
          child: Container(
                  padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background1,
                   
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: 
                      Text(
                        "Clear Form",
                        style:AppTextStyles.containerText
                                    ),
                  
                ),
        ),
              SizedBox(width: size.width*0.37,),
               Container(
                padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.amber600,
                 
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check,color: AppColors.dark,),
                    Text(
                      "Log Sale",
                      style:AppTextStyles.containerText
                                  ),
                  ],
                ),
              ),



],)



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
        color: AppColors.background,
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