import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;
  final VoidCallback? onPressed;

  const StatusBadge({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(
        getWidth(context, 20),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(context, 10),
          vertical: getHeight(context, 4),
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(
            getWidth(context, 20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor,
                size: getWidth(context, 16),
              ),
              SizedBox(
                width: getWidth(context, 6),
              ),
            ],
            Text(
              text,
              style: AppTextStyles.bodyText16.copyWith(
                color: textColor,
                fontSize: getWidth(context, 12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}