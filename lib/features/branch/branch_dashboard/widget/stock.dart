import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Stock extends StatefulWidget {
  final String title;
  final String value;
  final String percent;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  // 🔥 Control unit color
  final bool highlightUnit;

  const Stock({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.highlightUnit = false,
  });

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
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
          /// 🔹 Title & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(widget.title, style: AppTextStyles.bodyText12),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 15),
              ),
            ],
          ),

          const SizedBox(height: 25),

          /// 🔹 Value with optional grey unit
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
                        text: widget.value.split(" ").sublist(1).join(" "),
                        style: AppTextStyles.headingText22.copyWith(
                          color: Colors.grey, // 🔥 trays in grey
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(widget.value, style: AppTextStyles.headingText22),

          const SizedBox(height: 4),

          /// 🔹 Percentage row
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 10),
              const SizedBox(width: 2),
              Text(
                widget.percent,
                style: const TextStyle(color: Colors.green, fontSize: 9),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  widget.subtitle,
                  style: AppTextStyles.bodyText12semibold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
