import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildField(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.bodyText14dark),
      const SizedBox(height: 4),
      Text(title, style: AppTextStyles.bodyText14), // same text
    ],
  );
}