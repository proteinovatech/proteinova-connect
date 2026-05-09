import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildField(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title.replaceAll("*", ""),
              style: AppTextStyles.bodyText14dark,
            ),

            if (title.contains("*"))
              TextSpan(
                text: " *",
                style: AppTextStyles.bodyText14dark.copyWith(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),

      const SizedBox(height: 4),

     
    ],
  );
}