import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildPaymentItem({
  required IconData icon,
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.dark),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.containerText.copyWith(
                decoration: isSelected
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor:
                    isSelected ? Colors.yellow : Colors.black,
                decorationThickness: 3,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}