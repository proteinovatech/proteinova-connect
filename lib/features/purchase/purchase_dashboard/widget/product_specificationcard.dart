import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/product_input_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/product_summary_model.dart';

class ProductSpecificationCard extends StatefulWidget {
  
  final Function(String category) onCategoryChanged;
  final Function(List<ProductInput>) onProductsChanged;
  final List<ProductInput> initialProducts;
  final TextEditingController trayController;
  final TextEditingController quantityController;
  final TextEditingController countController;
  final TextEditingController neccController;
  final TextEditingController minusController;
  final TextEditingController rateController;
  
  final TextEditingController loadingController;
  final TextEditingController unloadingController;
  final TextEditingController transportController;
  final TextEditingController miscController;

  const ProductSpecificationCard({
    super.key,

    required this.onProductsChanged,
    required this.onCategoryChanged,
    required this.trayController,
    required this.quantityController,
    required this.countController,
    required this.neccController,
    required this.minusController,
    required this.rateController,
    
    required this.loadingController,
    required this.unloadingController,
    required this.transportController,
    required this.miscController,
     this.initialProducts = const []
  });

  @override
  State<ProductSpecificationCard> createState() =>
      _ProductSpecificationCardState();
}

class _ProductSpecificationCardState extends State<ProductSpecificationCard> {
  bool isExpanded = false;

  

 late List<ProductInput> products;
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> neccControllers = [];
List<TextEditingController> minusControllers = [];
List<TextEditingController> countControllers = [];
  @override
void initState() {
  super.initState();

  products = widget.initialProducts.isNotEmpty
      ? widget.initialProducts.map((e) => e.copyWith()).toList()
      : [ProductInput()];

  quantityControllers.add(TextEditingController());
  neccControllers.add(TextEditingController());
  minusControllers.add(TextEditingController());
  countControllers.add(TextEditingController());
}
 void calculateFinalRate(int index) {
  final product = products[index];

  final necc = double.tryParse(product.necc) ?? 0;
  final minus = double.tryParse(product.minus) ?? 0;

  product.rate = (necc - minus).toStringAsFixed(2);

  setState(() {});
  widget.onProductsChanged(products);
}
 
  String? selectedCategory;
  String? selectedTray;
  List<ProductSummary> productList = [];
  final List<String> eggCategories = [
    "White Medium",
    "White Bullet",
    "White Small Eggs",
    "Brown Eggs",
    "Country Eggs",
    "Quail Eggs",
    "Duck Eggs"
  ];

  final List<String> trayType = [
    "Plastic Tray",
    "Paper Tray",
  ];
  void updateProduct(int index) {
  final product = ProductSummary(
    category: selectedCategory ?? "",
    quantity: widget.quantityController.text,
    rate: widget.rateController.text,
    totalEggs: widget.countController.text,
  );

  if (productList.length > index) {
    productList[index] = product;
  } else {
    productList.add(product);
  }

  widget.onProductsChanged(products);
}
void updateTotalEggs(ProductInput product) {
  final qty = int.tryParse(product.quantity) ?? 0;
  product.totalEggs = (qty * 30).toString();
}

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
     
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 HEADER
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    color: AppColors.blueAccent),
                SizedBox(width: size.width * 0.02),
                const Expanded(
                  child: Text(
                    "Product Specification",
                    style: AppTextStyles.headingText20,
                  ),
                ),
                Icon(isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down),
              ],
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 10),
            const Divider(),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add,
                    color: Colors.grey, size: 28),
                onPressed: () {
                  setState(() {
                    products.add(ProductInput());
                     quantityControllers.add(TextEditingController());
                      neccControllers.add(TextEditingController());
    minusControllers.add(TextEditingController());
    countControllers.add(TextEditingController());

                  });
                   widget.onProductsChanged(products);
                },
              ),
            ),

           
           

            ...products.asMap().entries.map((entry) {
  int index = entry.key;
  return buildProduct(size, index);
}).toList(),
          ],
        ],
      ),
    );
  }

  Widget buildProduct(Size size,int index) {
    final product = products[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

      Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Product ${index + 1}",
      style: AppTextStyles.buttonText16,
    ),

    
    if (products.length > 1)
      IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: () {
          setState(() {
            products.removeAt(index);
           if (index < quantityControllers.length) {
      quantityControllers.removeAt(index);
    }
  });

  widget.onProductsChanged(products);
        },
      ),
  ],
),

        const SizedBox(height: 10),
const Text("Egg Category & Grade", style: AppTextStyles.buttonText16),
 const SizedBox(height: 6),
        // CATEGORY
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.containerColor,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButton<String>(
            value:product.category.isEmpty ? null : product.category ,
            isExpanded: true,
            hint: Row(
              children:const [
                SizedBox(width: 14),
                Icon(Icons.egg_outlined, size: 20,color:AppColors.textSecondary),
                SizedBox(width: 16),
                Text("Select Category"),
              ],
            ),
            underline: const SizedBox(),
            
            items: eggCategories.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                product.category = value ?? "";
              });
              widget.onProductsChanged(products);
            },
          ),
        ),

        const SizedBox(height: 14),
        const Text("Number Trays (per Trays of 30 eggs)", style: AppTextStyles.buttonText16),
         const SizedBox(height: 6),
        _buildField(
          controller:quantityControllers[index],
          hint: "Enter quantity",
          icon: Icons.grid_view_outlined,
          isNumeric: true,
          onChanged: (value) {
           setState(() {
      product.quantity = value;
      final qty = int.tryParse(value) ?? 0;
      product.totalEggs = (qty * 30).toString();
      countControllers[index].text = product.totalEggs; 
    });

    widget.onProductsChanged(products);
  },
        ),

        const SizedBox(height: 14),
        const Text("Total Eggs (Auto)", style: AppTextStyles.buttonText16),
         const SizedBox(height: 6),
        _buildField(
          controller: countControllers[index],
          hint: "Auto calculated",
          enabled: false,
          isNumeric: true,
          
         
        ),

        const SizedBox(height: 14),
        const Text("NECC Rate(per egg)", style: AppTextStyles.buttonText16), 
        const SizedBox(height: 6),
        _buildField(
          controller: neccControllers[index],
          hint: "NECC Rate",
          isNumeric: true,
          prefixText: "₹ ",
          icon: Icons.trending_up_outlined,
          onChanged: (value) {
  setState(() {
    product.necc = value;
  });

  calculateFinalRate(index);
   widget.onProductsChanged(products);
},
        ),

        const SizedBox(height: 14),
         const Text("Market Minus(per egg)", style: AppTextStyles.buttonText16),
          const SizedBox(height: 6),
        _buildField(
          controller: minusControllers[index],
          hint: "Market Minus",
          isNumeric: true,
          prefixText: "₹ ",
          icon: Icons.trending_down_outlined,
          onChanged: (value) {
  setState(() {
    product.minus = value;
  });

  calculateFinalRate(index);
   widget.onProductsChanged(products);
},
        ),

        const SizedBox(height: 14),
        const Text("Final Rate (per egg)", style: AppTextStyles.buttonText16), 
        const SizedBox(height: 6),
     _buildField(
  controller: TextEditingController(
    text: product.rate.isEmpty ? "0.00" : product.rate,
  ),
  hint: "Final Rate",
  isNumeric: true,
  prefixText: "₹ ",
  isDisplayOnly: true,
),

        const SizedBox(height: 14),
        const Text("Tray Type", style: AppTextStyles.buttonText16), 
        const SizedBox(height: 6),
        // TRAY TYPE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.containerColor,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButton<String>(
            value:product.trayType.isEmpty ? null : product.trayType ,
            isExpanded: true,
            hint: Row(
              children:const [
                SizedBox(width: 14),
                Icon(Icons.all_inbox_outlined,color:AppColors.textSecondary,),
                SizedBox(width: 16),
                Text("Select Tray Type"),
              ],
            ),
            underline: const SizedBox(),
            items: trayType.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(t),
              );
            }).toList(),
            onChanged: (value) {
  setState(() {
    product.trayType = value ?? "";
  });

  widget.onProductsChanged(products);
},
          ),
        ),
      ],
    );
  }


  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    bool isNumeric = false,
     bool isDisplayOnly = false,
    IconData? icon,
    String? prefixText,
    Function(String)? onChanged,  
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.containerColor,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        onChanged: onChanged,
        controller: controller,
         enabled: enabled && !isDisplayOnly,
      readOnly: isDisplayOnly,
        
        keyboardType:
            isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric
    ? [
        FilteringTextInputFormatter.allow(
         RegExp(r'^\d{0,9}(\.\d{0,2})?$'), 
        ),
      ]
    : [],
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.light) : null,
          prefixText: prefixText,
        ),
      ),
    );
  }
}