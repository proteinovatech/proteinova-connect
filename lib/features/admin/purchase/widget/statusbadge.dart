import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;
  final VoidCallback? onPressed;

  const StatusBadge({
    super.key,
    this.icon,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor,
              size: 18,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppTextStyles.bodyText16.copyWith(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}