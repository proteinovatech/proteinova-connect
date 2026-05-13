import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final String percent;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: AppTextStyles.bodyText12
              ),

              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 25),
                    Text(
            widget.value,
            style: AppTextStyles.headingText22,
          ),
                    const SizedBox(height: 5),
                    Row(
            children: [
              const Icon(Icons.trending_up,
                  color: Colors.green, size: 13),
              const SizedBox(width: 3),
              Text(
                widget.percent,
                style: const TextStyle(
                    color: Colors.green, fontSize: 10),
              ),
              const SizedBox(width: 3),
              Text(
                widget.subtitle,
                style:AppTextStyles.bodyText12semibold
              ),
            ],
          ),
        ],
      ),
    );
  }
}