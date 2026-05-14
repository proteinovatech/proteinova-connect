import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class InfoCards extends StatefulWidget {
  final String title;
  final String value;
  final String percent;
  final String subtitle;

  final IconData icon;
  final IconData topIcon;

  final Color topIconColor;
  final Color iconColor;

  const InfoCards({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    required this.subtitle,
    required this.icon,
    required this.topIcon,
    required this.topIconColor,
    required this.iconColor,
  });

  @override
  State<InfoCards> createState() => _InfoCardsState();
}

class _InfoCardsState extends State<InfoCards> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: AppColors.background,

        border: Border.all(color: Colors.grey.shade300),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(widget.title, style: AppTextStyles.bodyText12),

              Icon(widget.topIcon, size: 16, color: widget.topIconColor),
            ],
          ),

          const SizedBox(height: 25),

          /// VALUE + ICON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(widget.value, style: AppTextStyles.headingText22),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 13,
                      ),

                      const SizedBox(width: 3),

                      Text(
                        widget.percent,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(width: 3),

                      Text(
                        widget.subtitle,
                        style: AppTextStyles.bodyText12semibold,
                      ),
                    ],
                  ),
                ],
              ),

              /// RIGHT ICON
              Container(
                height: 46,
                width: 46,

                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(.12),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(widget.icon, color: widget.iconColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}