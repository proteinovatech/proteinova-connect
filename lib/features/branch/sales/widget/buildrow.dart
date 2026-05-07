// import 'package:flutter/material.dart';
// import 'package:proteinova_connect/core/theme/app_text_styles.dart';

// Widget buildSummaryRow(String title, String value, {bool isBold = false}) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         title,
//         style: isBold
//             ? AppTextStyles.headingText20
//             : AppTextStyles.bodyText14,
//       ),
//       Text(
//         value,
//         style: isBold
//             ? AppTextStyles.headingText20
//             : AppTextStyles.bodyText14,
//       ),
//     ],
//   );
// }
import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildSummaryRow(String title, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
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
          style: isBold
              ? AppTextStyles.headingText20
              : AppTextStyles.bodyText14,
        ),
      ],
    ),
  );
}
