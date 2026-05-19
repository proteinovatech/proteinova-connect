import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class ShipmentCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  const ShipmentCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
     final Size size =MediaQuery.of(context).size;
    return Container(
      height:size.height*0.18,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                     Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyText12semibold
              ),               
                             Icon(icon, size: 18, color: iconColor ?? AppColors.dark),
            ],
          ),
          SizedBox(height: size.height*0.01),
                  Text(
            count,
            style: AppTextStyles.headingText20
          ),
         SizedBox(height: size.height*0.01),
          Text(
            subtitle,
            style: AppTextStyles.bodyText12
          ),
        ],
      ),
    );
  }
}
