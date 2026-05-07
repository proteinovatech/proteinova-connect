import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class  StockPreviewCard  extends StatelessWidget {
  
  final String available;
  final String selling;
  final String remaining;
  
  final VoidCallback onReceiveTap;

  const StockPreviewCard({
    super.key,
   
    required this.available,
    required this.selling,
    required this.remaining,
    
    required this.onReceiveTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    double totalStock = 8000;
double remainingStock = 7950;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 Top Row (Order + Status)
          
              Text(
                "Stock Preview",
                style: AppTextStyles.headingText20,
              ),

             

          const SizedBox(height: 6),

          /// 🔹 Date & Time
          

        Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: AppColors.background1,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column( 
    children: [
      Row(children: [
        Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child:Icon(Icons.inventory_2_outlined),
            ),
        
        SizedBox(width: 10,),
        Text("Large White Eggs (Tray)",style: AppTextStyles.headingText20,)
      ],),
      const SizedBox(height: 10),
      Row(
        children: [
          
          const Text("Current Available",style: AppTextStyles.bodyText14,),
          const Spacer(),
          Text(
            available,
            style: AppTextStyles.bodyText14dark,
          ),
        ],
      ),

      const SizedBox(height: 10),

      /// 🔹 Product
      Row(
        children: [
         
          const Text("Quantity Selling",style: AppTextStyles.bodyText14,),
          const Spacer(),
          Text(
            selling,
            style: AppTextStyles.bodyText14dark,
          ),
        ],
      ),
      SizedBox(height: 10,),
      Divider(),
      SizedBox(height: 10,),
      Row(
        children: [
         
          const Text("Remaining Stock",style: AppTextStyles.headingText20,),
          const Spacer(),
          Text(
            remaining,
            style:  AppTextStyles.bodyText14dark,
          ),
        ],
      ),
      const SizedBox(height: 10),
      LinearProgressIndicator(
  value: remainingStock / totalStock,
  minHeight: 5,
  backgroundColor: Colors.grey.shade300,
  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
),
    ],
  ),
),

          const SizedBox(height: 16),

          /// 🔹 Button
          GestureDetector(
            onTap: onReceiveTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.green,
                
                borderRadius: BorderRadius.circular(8),
              ),
              child:  Row(
                children: [
                  SizedBox(width:size.width*0.08),
                  Icon(Icons.check_circle_outline,color: AppColors.background,),
                  SizedBox(width: size.width*0.04),
                  Text(
                 "Stock levels will remain healthy",
                  style: AppTextStyles.whiteText
                ),
                      ]),
            ),
          ),
        ],
      ),
    );
  }
}