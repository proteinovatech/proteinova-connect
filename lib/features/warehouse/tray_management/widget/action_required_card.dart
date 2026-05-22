import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

class ActionsRequiredCard extends StatelessWidget {
  const ActionsRequiredCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.09),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Row(
            children: [
              Expanded(
                child: Text(
                  "Actions Required",
                  style: AppTextStyles.headingText16,
                ),
              ),

              Text("3 Alerts", style: AppTextStyles.redtext),
            ],
          ),

          SizedBox(height: getHeight(context, 16)),

          /// ITEM 1
          _buildActionItem(
            title: "Low Stock Alert",
            body: "Egg trays are running low in Chennai warehouse.",
            subtitle: "Needs immediate refill",
            lineColor: AppColors.red,
            context,
          ),

          SizedBox(height: getHeight(context, 12)),

          /// ITEM 2
          _buildActionItem(
            title: "Pending Dispatch",
            body: "3 shipments are waiting for dispatch approval.",
            subtitle: "Pending since 4 hours",
            lineColor: AppColors.orange,
            context,
          ),

          SizedBox(height: getHeight(context, 12)),

          /// ITEM 3
          _buildActionItem(
            title: "Payment Due",
            body: "Supplier payment needs to be completed today.",
            subtitle: "Due by 6:00 PM",
            lineColor: AppColors.blue,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required String body,
    required String subtitle,
    required Color lineColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT LINE
          Container(
            width: getWidth(context, 5),
            height: getHeight(context, 110),
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ICON
                  Container(
                    height: getHeight(context, 38),
                    width: getWidth(context, 38),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: lineColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),

                    child: Center(
                      child: Icon(
                        Icons.priority_high,
                        color: lineColor,
                        size: 22,
                      ),
                    ),
                  ),

                  SizedBox(width: getWidth(context, 12)),

                  /// TEXTS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.bodyText14dark),

                        SizedBox(height: getHeight(context, 6)),

                        Text(body, style: AppTextStyles.bodyText14),

                        SizedBox(height: getHeight(context, 8)),

                        Text(subtitle, style: AppTextStyles.blueText2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
