import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

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
    final Size size =
        MediaQuery.of(context).size;

    final bool isTablet =
        size.width >= 700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        getWidth(context, 12),
      ),

      child: Container(
        constraints: BoxConstraints(
          minHeight: getHeight(context, 130),
        ),

        padding: EdgeInsets.all(
          isTablet
              ? getWidth(context, 12)
              : getWidth(context, 16),
        ),

        margin: EdgeInsets.symmetric(
          horizontal: getWidth(context, 4),
        ),

        decoration: BoxDecoration(
          color: AppColors.background,

          borderRadius: BorderRadius.circular(
            getWidth(context, 12),
          ),

          border: Border.all(
            color: AppColors.border,
            width: getWidth(context, 1),
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,

                    style: AppTextStyles
                        .bodyText12semibold
                        .copyWith(
                      fontSize:
                          getWidth(context, 12),
                    ),
                  ),
                ),

                SizedBox(
                  width: getWidth(context, 8),
                ),

                Icon(
                  icon,
                  size: getWidth(context, 16),
                  color:
                      iconColor ?? AppColors.dark,
                ),
              ],
            ),

            SizedBox(
              height: getHeight(context, 12),
            ),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,

              child: Text(
                count,
                style: AppTextStyles
                    .headingText20
                    .copyWith(
                  fontSize:
                      getWidth(context, 20),
                ),
              ),
            ),

            SizedBox(
              height: getHeight(context, 8),
            ),

            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,

              style: AppTextStyles.bodyText12
                  .copyWith(
                fontSize:
                    getWidth(context, 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}