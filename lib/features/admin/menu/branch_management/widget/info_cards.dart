import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

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
      padding: const EdgeInsets.all(10),
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
              Text(widget.title, style: AppTextStyles.bodyText12),
              Icon(widget.topIcon, size: 16, color: widget.topIconColor),
            ],
          ),
          SizedBox(height: getHeight(context, 25)),
          Text(widget.value, style: AppTextStyles.headingText22),
          SizedBox(height: getHeight(context, 5)),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 13),
              SizedBox(width: getWidth(context, 3)),
              Text(
                widget.percent,
                style: const TextStyle(color: Colors.green, fontSize: 10),
              ),
              SizedBox(width: getWidth(context, 3)),
              Text(widget.subtitle, style: AppTextStyles.bodyText12semibold),
            ],
          ),
        ],
      ),
    );
  }
}
