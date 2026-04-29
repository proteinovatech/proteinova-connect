import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Stockdetails extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
 final bool highlightUnit;

  const Stockdetails({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.highlightUnit = false, 
  });

  @override
  State<Stockdetails> createState() => _StockdetailsState();
}

class _StockdetailsState extends State<Stockdetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
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
                style: AppTextStyles.bodyText12,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),
          widget.highlightUnit && widget.value.contains(" ")
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.value.split(" ")[0] + " ",
                        style: AppTextStyles.headingText22.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: widget.value
                            .split(" ")
                            .sublist(1)
                            .join(" "),
                        style: AppTextStyles.headingText22.copyWith(
                          color: Colors.grey, 
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  widget.value,
                  style: AppTextStyles.headingText22,
                ),
        ],
      ),
    );
  }
}