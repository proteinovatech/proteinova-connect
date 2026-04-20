import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/inventory/widget/buildrow.dart';
import 'package:proteinova_connect/features/sales/widget/buildcustomerinput.dart';
import 'package:proteinova_connect/features/sales/widget/buildpaymentitem.dart';
import 'package:proteinova_connect/features/sales/widget/eggitemcard.dart';

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

  @override
  Widget build(BuildContext context) {
       String? selectedPayment;
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
          "Product Details",
          style: AppTextStyles.headingText20,
        ),
      
    
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

    // 🔹 2. Quantity
   Visibility(
  visible: false, // 👈 change to true when needed
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Quantity Sold (Units/Trays)", style: AppTextStyles.buttonText16),
      const SizedBox(height: 6),
      _buildField(
        controller: widget.quantityController,
        hint: "Enter quantity",
        icon: null,
        isNumeric: true,
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
                selectedIncrement = value;
                widget.quantityController.text =
                    (current + value).toString();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.containerColor2
                    : AppColors.containerColor,
                border: Border.all(
                  color: isSelected
                      ? AppColors.border2
                      : AppColors.border,
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
    ],
  ),
),
    const SizedBox(height: 14),
    // 🔹 3. Product List (Reusable Containers)
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
      Text("Product Details", style: AppTextStyles.buttonText16),
      const SizedBox(height: 10),

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
), ],
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

      /// 🔥 HEADER
      selectedItems.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sales Items",
                    style: AppTextStyles.headingText20),
                Icon(Icons.add, color: AppColors.dark),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sales Items",
                    style: AppTextStyles.headingText20),
                const SizedBox(height: 10),
                Center(
                  child: Icon(Icons.add, color: AppColors.dark),
                ),
              ],
            ),

      const SizedBox(height: 10),

      /// 🔥 SHOW ALL SELECTED ITEMS
      ...selectedItems.asMap().entries.map((entry) {
        int index = entry.key;
        var item = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.containerColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.containerColor2)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// 🔹 ITEM DETAILS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["title"]!,
                      style: AppTextStyles.headingText20),
                  Text("${item["price"]} per tray"),
                  Text(item["stock"]!,
                      style: AppTextStyles.bodyText14),
                ],
              ),

              /// 🔴 DELETE ICON
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItems.removeAt(index);

                    if (selectedItems.isEmpty) {
                      items.clear(); // reset condition
                    }
                  });
                },
                child: Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    ],
  ),
  ),SizedBox(height: 10,),
      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Offers",
      style: AppTextStyles.headingText20,
    ),

    const SizedBox(height: 10),

    /// 🔥 MAIN CONTAINER
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
                onTap: () {
                                 },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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
                onTap: () {
                                  },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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
 SizedBox(height: 10,),
 
              SizedBox(height: 10,),
     Align(
   alignment: Alignment.centerLeft,
   child: Text(
     "Bill Summery",
     style: AppTextStyles.headingText22,
   ),
 ),
          Container(
   padding: const EdgeInsets.all(10),
   margin: const EdgeInsets.all(12),
   decoration: BoxDecoration(
     color: Colors.white,
     borderRadius: BorderRadius.circular(12),
     border:Border.all(color: const Color.fromARGB(255, 218, 217, 217)) 
      ),
   child: Column(
     children: [
 buildRow("Items(6- Trays)", "₹275"),
       const SizedBox(height: 5),
       const Divider(),
       buildRow("Offers Discount", "-₹45"),
       const SizedBox(height: 5),
       const Divider(),
      
    buildRow("Sub Total", "₹230", isBold: true),
       const Divider(),
 
       buildRow("Tax(0%)", "₹0"),
       const SizedBox(height: 5),
       const Divider(),
       buildRow("Total Amount", "₹230", isBold: true),
     ],
   ),
 )
        , SizedBox(height: 10,),  
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

      /// 🔹 PAYMENT METHOD
      Text(
        "Payment Method",
        style: AppTextStyles.headingText22,
      ),

      const SizedBox(height: 10),
     Row(
     children: [
       Expanded(
         child: Center(
           child: buildPaymentItem(
             icon: Icons.money,
             title: "Cash",
             isSelected: selectedPayment == "Cash",
             onTap: () {
               setState(() {
                 selectedPayment = "Cash";
               });
             },
           ),
         ),
       ),
     
       Expanded(
         child: Center(
           child: buildPaymentItem(
             icon: Icons.qr_code,
             title: "UPI",
             isSelected: selectedPayment == "UPI",
             onTap: () {
               setState(() {
                 selectedPayment = "UPI";
               });
             },
           ),
         ),
       ),
     
       Expanded(
         child: Center(
           child: buildPaymentItem(
             icon: Icons.credit_card,
             title: "Card",
             isSelected: selectedPayment == "Card",
             onTap: () {
               setState(() {
                 selectedPayment = "Card";
               });
             },
           ),
         ),
       ),
     ],
     ),

      const SizedBox(height: 16),
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
        child: const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
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
          Text(
            "Change",
            style: AppTextStyles.containerText,
          ),
          Text(
            "₹20.00",
            style: AppTextStyles.headingText20,
          ),
        ],
      ),
      SizedBox(height: 10,),
      Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.green,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Center(
    child: Text(
      "Collect Payment   ₹230",
      style: AppTextStyles.containerText.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
    ],
  ),
)],
),
  Visibility(
  visible: showNotesSection,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Additional Notes", style: AppTextStyles.buttonText16),
      const SizedBox(height: 6),

      _buildField(
        controller: widget.notesController,
        hint: "Add any details about this transaction...",
        maxLines: 3,
      ),

      SizedBox(height: size.height * 0.03),
      const Divider(),
      SizedBox(height: size.height * 0.02),

      Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.categoryController.clear();
                widget.quantityController.clear();
                widget.nameController.clear();
                widget.notesController.clear();

                selectedCategory = null;
                selectedIncrement = null;
                showNotesSection = false; // 👈 hide again
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.background1,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("Clear Form",
                  style: AppTextStyles.containerText),
            ),
          ),

          SizedBox(width: size.width * 0.29),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.amber600,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.check, color: AppColors.dark),
                const SizedBox(width: 4),
                Text("Log Sale",
                    style: AppTextStyles.containerText),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
)
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
  Widget _buildItem(String title, String price, String stock) {
  return InkWell(
    onTap: () {
      setState(() {
        selectedItems.add({
          "title": title,
          "price": price,
          "stock": stock,
        });

        items.add(title); // keeps your existing condition working
      });
    },
    child: EggItemCard(
      title: title,
      price: price,
      stock: stock,
    ),
  );
}
}
