import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget trayItem({
  required String title,
  required String status,
  required String description,
  required String count,
}) {

  // ✅ Status color
  Color statusColor =
      status.toLowerCase().contains("non") ? Colors.orange : Colors.green;

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ✅ TITLE WITH GREY BRACKETS ONLY
        buildTitle(title),

        SizedBox(height: 8),

               Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
  status,
  style: AppTextStyles.bodyText12.copyWith(
    color: Colors.white,
  ),
),
        ),

        SizedBox(height: 6),

        Text(
          description,
          style: AppTextStyles.bodyText12,
            overflow: TextOverflow.ellipsis,
        ),

        Divider(),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Trays", style: AppTextStyles.headingText20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(count),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildTitle(String title) {
  final regex = RegExp(r'\((.*?)\)');
  final match = regex.firstMatch(title);

  if (match != null) {
    final before = title.substring(0, match.start);
    final inside = match.group(0); // (text)
    final after = title.substring(match.end);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: before,
            style: AppTextStyles.headingText20.copyWith(color: Colors.black),
          ),
          TextSpan(
            text: inside,
            style: AppTextStyles.bodyText12.copyWith(color: Colors.grey),
          ),
          TextSpan(
            text: after,
            style: AppTextStyles.headingText20.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  } else {
    return Text(
      title,
      style: AppTextStyles.headingText20,
    );
  }
}