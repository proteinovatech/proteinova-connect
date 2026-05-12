import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class RecentActivityCard extends StatelessWidget {
  final List<dynamic> activities;

  const RecentActivityCard({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              const Text(
                "Recent Activity",
                style: AppTextStyles.headingText20,
              ),

              TextButton(
                onPressed: () {},

                child: Text(
                  "View All",
                  style: AppTextStyles.blueText2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          activities.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),

                    child: Text(
                      "No recent activity",
                    ),
                  ),
                )

              : ListView.separated(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: activities.length,

                  separatorBuilder: (_, __) =>
                      Divider(
                    color: Colors.grey.shade200,
                    height: 24,
                  ),

                  itemBuilder: (context, index) {
                    final item = activities[index] as Map<String, dynamic>;
                    final trayId = item['tray_id'] ?? "Unknown Tray";
                    final status = item['status'] ?? "Unknown";
                    final movementType = item['movement_type'] ?? "Movement";
                    final toLocation = item['to_location'] ?? "";
                    final createdAt = item['created_at'] != null 
                        ? DateTime.parse(item['created_at']).toString().split(' ').first 
                        : "Recently";

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.background1,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              movementType == "DELIVERY" ? Icons.local_shipping : Icons.inventory,
                              size: 18,
                              color: AppColors.blueAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$trayId - $status",
                                style: AppTextStyles.bodyText14dark,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$movementType ${toLocation.isNotEmpty ? 'to $toLocation' : ''}",
                                style: AppTextStyles.bodyText12,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
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