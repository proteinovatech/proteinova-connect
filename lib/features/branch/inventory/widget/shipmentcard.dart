import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';

class ShipmentCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ShipmentCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed, screen-independent sizing for consistent design and no runaway scaling
    const double titleFontSize = 12;
    const double valueFontSize = 24;
    const double subFontSize = 12;
    const double iconSize = 18;
    const double iconPadding = 8;
    const double iconRadius = 10;
    const double cardPadding = 12;
    const double cardRadius = 12;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(cardRadius),
      child: Container(
        padding: const EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title & Icon Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.dark).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(iconRadius),
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: iconColor ?? AppColors.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Value & Subtitle Pin
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    count,
                    style: const TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: subFontSize,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
