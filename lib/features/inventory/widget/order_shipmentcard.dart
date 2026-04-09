import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class OrderShipmentcard extends StatelessWidget {
  final String orderId;
  final String dateTime;
  final String status;
final Color statusBgColor;
final Color statusTextColor;
  final String supplier;
  final String product;
  final String quantity;
  final Color buttonColor;
  final String buttonText;
  final VoidCallback onReceiveTap;

  const OrderShipmentcard({
    super.key,
    required this.orderId,
    required this.dateTime,
    required this.status,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.supplier,
    required this.product,
    required this.quantity,
    required this.buttonColor,
    required this.buttonText,
    required this.onReceiveTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 Top Row (Order + Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: AppTextStyles.headingText20,
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusTextColor
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// 🔹 Date & Time
          Text(
            dateTime,
            style: AppTextStyles.bodyText14,
          ),

          const SizedBox(height: 12),

        Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: AppColors.containerColor,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column( 
    children: [
   
      Row(
        children: [
          const Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          const Text("Supplier",style: AppTextStyles.bodyText12semibold,),
          const Spacer(),
          Text(
            supplier,
            style: const TextStyle(color:  AppColors.blueAccent),
          ),
        ],
      ),

      const SizedBox(height: 10),

      /// 🔹 Product
      Row(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 18, color:AppColors.textSecondary),
          const SizedBox(width: 6),
          const Text("Products",style: AppTextStyles.bodyText12semibold,),
          const Spacer(),
          Text(
            "$quantity ($product)",
            style: const TextStyle(color: AppColors.blueAccent),
          ),
        ],
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
                color: buttonColor,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child:  Center(
                child: Text(
                  buttonText,
                  style: AppTextStyles.containerText
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}