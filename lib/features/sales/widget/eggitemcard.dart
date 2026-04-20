import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class EggItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String stock;

  const EggItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.containerText),
          const SizedBox(height: 6),
         RichText(
  text: TextSpan(
    children: [
      TextSpan(
       text: price,
        style: AppTextStyles.containerText.copyWith(
          color: AppColors.textPrimary, // first color
        ),
      ),
      TextSpan(
        text: "per tray",
        style: AppTextStyles.containerText.copyWith(
          color: Colors.grey, // second color
        ),
      ),
    ],
  ),
),
          const SizedBox(height: 6),
          Text(stock, style: AppTextStyles.bodyText14),
        ],
      ),
    );
  }
}