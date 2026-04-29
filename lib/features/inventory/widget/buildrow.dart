import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildRow(String title, String value, String s, {bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: isBold
            ? AppTextStyles.headingText20
            : AppTextStyles.bodyText14,
      ),
      Text(
        value,
        style: AppTextStyles.headingText20,
      ),
    ],
  );
}