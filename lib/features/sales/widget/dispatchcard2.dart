import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Dispatchcard2 extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const Dispatchcard2({
    super.key,
    required this.title,
    required this.value,   
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  State<Dispatchcard2> createState() => _Dispatchcard2State();
}

class _Dispatchcard2State extends State<Dispatchcard2> {
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
            Row(
            children: [
                                     Text(
                widget.subtitle,
                style:AppTextStyles.bodyText12semibold
              ),
            ],
          ),

          const SizedBox(height: 25),
          Text(
            widget.value,
            style: AppTextStyles.headingText22,
          ),

          const SizedBox(height: 5),
                
        ],
      ),
    );
  }
}