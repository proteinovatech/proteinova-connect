import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class PurchaseSummaryCard extends StatelessWidget {
  const PurchaseSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
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
          _buildRow("Order Reference"),
          SizedBox(height: size.height*0.01),
          _buildRow("Supplier"),
          SizedBox(height: size.height*0.01),
          _buildRow("Product"),
          SizedBox(height: size.height*0.01),
          _buildRow("Total Quantity"),
          
    
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
            children: const [
              Text(
                "Total Cost",
                style: AppTextStyles.headingText20,
              ),
              Text(
                "--", // placeholder
                style: AppTextStyles.blueText,
              ),
            ],
          ),
          
        
    
        ],
      ),
    );
  }

  // 🔧 Row without value (placeholder)
  Widget _buildRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.formInputs15),
          const Text(
            "--", // placeholder
            style: AppTextStyles.bodyText16,
          ),
        ],
      ),
    );
  }
}