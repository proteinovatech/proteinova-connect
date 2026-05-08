import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Expenses extends StatefulWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon; 
 final String? subtitle;

  const Expenses({
    super.key,
    required this.title,
    required this.value,
    this.color = Colors.white,
    required this.icon, 
    this.subtitle,
  });

  @override
  State<Expenses> createState() => _ExpensesState();
}
class _ExpensesState extends State<Expenses> {
  @override
   Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
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
                Icon(widget.icon, size: 16, color: Colors.grey),
              ],
            ),
      
            const SizedBox(height: 6),
      
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (widget.subtitle != null) ...[
        const SizedBox(height: 4),
        Text(
      widget.subtitle!,
      style: AppTextStyles.bodyText12
        ),
      ],
          ],
        ),
      ),
    );
  }
}