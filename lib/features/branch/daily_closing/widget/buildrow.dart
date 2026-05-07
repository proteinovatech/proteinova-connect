import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildRow(String title, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isBold
              ? AppTextStyles.bodyText14dark.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodyText14,
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.bodyText14dark.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodyText14,
        ),
      ],
    ),
  );
}