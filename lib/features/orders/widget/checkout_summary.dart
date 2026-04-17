import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/orders/presentation/checkout.dart';

class CheckoutSummary extends StatelessWidget {
  final String supplier;
  final String location;
  final String product;
  final String quantity;
  final String rate;
  final String totalEggs;

  final String loading;
  final String unloading;
  final String transport;
  final String misc;

  
  const CheckoutSummary({
    super.key,
    required this.supplier,
    required this.location,
    required this.product,
    required this.quantity,
    required this.rate,
    required this.totalEggs,
    required this.loading,
    required this.unloading,
    required this.transport,
    required this.misc,
    });

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    final qty = double.tryParse(quantity) ?? 0;
final r = double.tryParse(rate) ?? 0;

final load = double.tryParse(loading) ?? 0;
final unload = double.tryParse(unloading) ?? 0;
final trans = double.tryParse(transport) ?? 0;
final miscCost = double.tryParse(misc) ?? 0;

final additionalTotal = load + unload + trans + miscCost;
final totalCost = (qty * r) + additionalTotal;
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

          // 🔹 Title
          
              Text(
                "Purchase Summary",
                style: AppTextStyles.headingText25,
              ),
           

          
           SizedBox(height: size.height*0.01),

          // 🔹 Empty rows (placeholders)
          _buildRow("Supplier",supplier),
          _buildRow("Location",location),
          _buildRow("Product",product),
            SizedBox(height: size.height*0.01),
          Divider(),
            SizedBox(height: size.height*0.01),
          _buildRow("Quantity",quantity),
          _buildRow("Per Egg Rate", "₹ $rate"),
          _buildRow("Total Eggs",totalEggs),
            SizedBox(height: size.height*0.01),
          Divider(),
            SizedBox(height: size.height*0.01),
          Text("Additional Costs",style: AppTextStyles.formInputs15dark,),
          _buildRow("Loading Charges", "₹ $loading"),
          _buildRow("Unloading Charges", "₹ $unloading"),
          _buildRow("Transport", "₹ $transport"),
          _buildRow("Misc Expense", "₹ $misc"),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                "Total Additional Cost",
                style: AppTextStyles.formInputs15dark,
              ),
              Text(
                "₹ $additionalTotal", // placeholder
                style: AppTextStyles.bodyText14dark,
              ),
            ],
          ),
            SizedBox(height: size.height*0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Cost per Tray",
                style: AppTextStyles.formInputs15dark,
              ),
              Text(
                "--", // placeholder
                style: AppTextStyles.bodyText14dark,
              ),
            ],
          ),

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

          SizedBox(height: size.height*0.01),

          // 🔹 Total Row (empty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Estimated Cost",
                style: AppTextStyles.headingText22,
              ),
              Text(
                "₹ $totalCost", // placeholder
                style: AppTextStyles.blueText,
              ),
            ],
          ),
          
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.amber600
            ),
          
          child: ElevatedButton(
            onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: 
        (context)=>Checkout()));
             
            },
            style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
            ),
            child:  Row(
              children: [
                 SizedBox(width: size.width*0.2),
                    
                Icon(Icons.lock_outline, color: AppColors.dark),
                 SizedBox(width: size.width*0.02),
                Text(
                        "Pay",
                        style: AppTextStyles.headingText20
                ),
                
                SizedBox(width: size.width*0.02),
                Text(
                        "₹ $totalCost",
                        style: AppTextStyles.headingText20
                ),
              ],
            ),
          ),
        ),
        
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerColor
            ),
          
          child: ElevatedButton(
            onPressed: () {
        
             
            },
            style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
            ),
            child:  
                Text(
                        "Save cancel",
                        style: AppTextStyles.headingText20
                ),
             
          ),
        ),
        Row(
          children: [
            Icon(Icons.info_outline,color: AppColors.textSecondary,),
            SizedBox(width: size.width*0.01,),
            Text("Stock will be marked as \'incoming\'  upon\nsubmission",style: AppTextStyles.formInputs15),
          ],
        )
         
         

        ],
      ),
    );
  }

  // 🔧 Row without value (placeholder)
  Widget _buildRow(String title,String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.formInputs15),
           Text(
            value.isEmpty ? "--" : value, // placeholder
            style: AppTextStyles.bodyText16,
          ),
        ],
      ),
    );
  }
}