import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class ActionsRequiredCard extends StatelessWidget {
  const ActionsRequiredCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
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
                  style: AppTextStyles.headingText20
                           ),
               ),
                
                 Text(
                "3 Alerts",
                style: AppTextStyles.redtext
                         ),

             ],
           ),

          const SizedBox(height: 16),

          /// ITEM 1
          _buildActionItem(
            title: "Low Stock Alert",
            body:
                "Egg trays are running low in Chennai warehouse.",
            subtitle: "Needs immediate refill",
            lineColor: Colors.red,
          ),

          const SizedBox(height: 12),

          /// ITEM 2
          _buildActionItem(
            title: "Pending Dispatch",
            body:
                "3 shipments are waiting for dispatch approval.",
            subtitle: "Pending since 4 hours",
            lineColor: Colors.orange,
          ),

          const SizedBox(height: 12),

          /// ITEM 3
          _buildActionItem(
            title: "Payment Due",
            body:
                "Supplier payment needs to be completed today.",
            subtitle: "Due by 6:00 PM",
            lineColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
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
            width: 5,
            height: 110,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// ICON
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color:
                          lineColor.withOpacity(0.12),
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

                  const SizedBox(width: 12),

                  /// TEXTS
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          title,
                          style: AppTextStyles.bodyText14dark
                        ),

                        const SizedBox(height: 6),

                        Text(
                          body,
                          style: AppTextStyles.bodyText14
                        ),

                        const SizedBox(height: 8),

                        Text(
                          subtitle,
                          style: AppTextStyles.blueText2
                        ),
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