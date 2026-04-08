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
                style: AppTextStyles.heading1,
              ),
           

          
           SizedBox(height: size.height*0.01),

          // 🔹 Empty rows (placeholders)
          _buildRow("Supplier"),
          _buildRow("Location"),
          _buildRow("Product"),
          _buildRow("Quantity"),
          _buildRow("Rate"),
          _buildRow("Logistics Surcharge"),

          SizedBox(height: size.height*0.01),


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
            children: const [
              Text(
                "Total Estimated Cost",
                style: AppTextStyles.heading2,
              ),
              Text(
                "--", // placeholder
                style: AppTextStyles.amount,
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
                 SizedBox(width: size.width*0.1),

                Icon(Icons.check_circle_outline, color: AppColors.dark),
                 SizedBox(width: size.width*0.03),
                Text(
                        "Submit Purchase Entry",
                        style: AppTextStyles.heading2
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
            child:  Row(
              children: [
                 SizedBox(width: size.width*0.2),

                Icon(Icons.save_outlined, color: AppColors.dark),
                 SizedBox(width: size.width*0.03),
                Text(
                        "Save as Draft",
                        style: AppTextStyles.heading2
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Icon(Icons.info_outline,color: AppColors.textSecondary,),
            SizedBox(width: size.width*0.01,),
            Text("Stock will be marked as \'incoming\'  upon\nsubmission",style: AppTextStyles.subtitle),
          ],
        )
         
         

        ],
      ),
    );
  }

  // 🔧 Row without value (placeholder)
  Widget _buildRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          const Text(
            "--", // placeholder
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }
}