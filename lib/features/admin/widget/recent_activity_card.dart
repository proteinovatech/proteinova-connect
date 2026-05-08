import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {

    final activities = [
      {
        "id": "TRAY-32-uj056f",
        "from": "Chennai",
        "to": "www",
      },
      {
        "id": "TRAY-32-9yxagq",
        "from": "Chennai",
        "to": "www",
      },
      {
        "id": "TRAY-32-c38j5j",
        "from": "Chennai",
        "to": "www",
      },
      {
        "id": "TRAY-32-e9vnfq",
        "from": "Chennai",
        "to": "www",
      },
      {
        "id": "TRAY-32-x7vfx3",
        "from": "Chennai",
        "to": "www",
      },
    ];

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

          /// HEADER
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [

              const Text(
                "Recent Activity",
                style: AppTextStyles.headingText20
              ),

              TextButton(
                onPressed: () {},
                child:  Text("View All",style: AppTextStyles.blueText2,),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// LIST
          ListView.separated(
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

              final item = activities[index];

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// LEADING CIRCLE
                  Container(
                    height: 38,
                    width: 38,

                    decoration: BoxDecoration(
                      color: AppColors.background1,
                      shape: BoxShape.circle,
                    ),

                    child: const Center(
                      child: Text(
                        "P",
                        style: AppTextStyles.blueText2
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        RichText(
                          text: TextSpan(
                            style:
                               AppTextStyles.bodyText14,
                            children: [

                              const TextSpan(
                                text: "PURCHASE ",
                                style: AppTextStyles.bodyText14dark
                              ),

                              TextSpan(
                                text:
                                    "Tray ${item["id"]} moved from ${item["from"]} to ${item["to"]}.",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [

                            Icon(
                              Icons.access_time,
                              size: 14,
                              color:
                                  Colors.grey.shade600,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              "20 hours ago",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "• IN_TRANSIT",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.grey.shade600,
                                fontWeight:
                                    FontWeight.w500,
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