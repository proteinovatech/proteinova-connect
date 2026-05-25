import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/admin/purchase/data/models/purchase_model.dart';

class PurchaseSummaryCard extends StatelessWidget {
   final PurchaseRequest purchase; 

  const PurchaseSummaryCard({super.key,
  required this.purchase});

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    int totalQty = 0;

for (var item in purchase.items) {
  totalQty += item.trays;
}
double productTotal = 0;

for (var item in purchase.items) {
  productTotal += item.trays * item.capacity * item.perEggPrice;
}

final additionalTotal =
    purchase.loadingCharge +
    purchase.unloadingCharge +
    purchase.transportCharge +
    purchase.miscExpense+
    purchase.brokerFee;

final totalCost = productTotal + additionalTotal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.containerColor,
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          // 🔹 Title
     
           SizedBox(height: size.height*0.01),
    
          // 🔹 Empty rows (placeholders)
          _buildRow("Order Reference","--"),
          SizedBox(height: size.height*0.01),
         _buildRow("Supplier", purchase.supplierName),
         SizedBox(height: size.height*0.01),
         _buildRow("Product",purchase.items.map((e) => e.eggCategoryGrade).join(", "),),
          SizedBox(height: size.height*0.01),
         _buildRow("Total Quantity", "$totalQty trays"),
          
    
          SizedBox(height: size.height*0.02),
    
    
          // 🔹 Dotted Divider
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 1,
                  color: index % 2 == 0
                      ? Colors.grey
                      : Colors.transparent,
                ),
              ),
            ),
          ),
    
          SizedBox(height: size.height*0.02),
    
          // 🔹 Total Row (empty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Cost",
                style: AppTextStyles.headingText20,
              ),
              Text(
                 "₹ ${totalCost.toStringAsFixed(2)}",
                style: AppTextStyles.blueText,
              ),
            ],
          ),
       
        ],
      ),
    );
  }

  Widget _buildRow(String title,String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.formInputs15),
           Text(
          value.isEmpty ? "--" : value,
          style: AppTextStyles.bodyText16,
        ),
        ],
      ),
    );
  }
}