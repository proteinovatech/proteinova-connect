import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

class RecentActivityCard extends StatelessWidget {
  final List<dynamic> activities;

  const RecentActivityCard({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.grey.shade200),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text("Recent Activity", style: AppTextStyles.headingText16),

              TextButton(
                onPressed: () {},

                child: Text("View All", style: AppTextStyles.blueText13),
              ),
            ],
          ),

          SizedBox(height: getHeight(context, 10)),

          activities.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),

                    child: Text("No recent activity"),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: activities.length,

                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade200, height: 24),

                  itemBuilder: (context, index) {
                    final item = activities[index] as Map<String, dynamic>;
                    final trayId = item['tray_id'] ?? "Unknown Tray";
                    final status = item['status'] ?? "Unknown";
                    final movementType = item['movement_type'] ?? "Movement";
                    final toLocation = item['to_location'] ?? "";
                    final createdAt = item['created_at'] != null
                        ? DateTime.parse(
                            item['created_at'],
                          ).toString().split(' ').first
                        : "Recently";

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: getHeight(context, 38),
                          width: getWidth(context, 38),
                          decoration: const BoxDecoration(
                            color: AppColors.background1,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              movementType == "DELIVERY"
                                  ? Icons.local_shipping
                                  : Icons.inventory,
                              size: 18,
                              color: AppColors.blueAccent,
                            ),
                          ),
                        ),
                        SizedBox(width: getWidth(context, 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$trayId - $status",
                                style: AppTextStyles.bodyText14dark,
                              ),
                              SizedBox(height: getHeight(context, 4)),
                              Text(
                                "$movementType ${toLocation.isNotEmpty ? 'to $toLocation' : ''}",
                                style: AppTextStyles.bodyText12,
                              ),
                              SizedBox(height: getHeight(context, 6)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: getWidth(context, 4)),
                                  Text(
                                    createdAt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
