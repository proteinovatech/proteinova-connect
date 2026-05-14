import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,

      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
      },

      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),

        transform: isPressed
            ? (Matrix4.identity()..scale(0.97))
            : Matrix4.identity(),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: isPressed ? Colors.grey.shade100 : AppColors.background,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: isPressed
                ? widget.iconColor.withOpacity(0.3)
                : Colors.grey.shade200,
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
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
            /// TOP ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Expanded(
                  child: Text(
                    widget.title,

                    style: AppTextStyles.bodyText12semibold.copyWith(
                      color: Colors.grey.shade600,
                    ),

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(4),

                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Icon(widget.icon, color: widget.iconColor, size: 18),
                ),
              ],
            ),

             SizedBox(height:getHeight(context, 10),),

            /// VALUE
            Text(
              widget.value,

              style: AppTextStyles.headingText22.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
