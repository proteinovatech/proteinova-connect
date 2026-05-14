import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class ExpenseCategory extends StatelessWidget {
  final IconData icon;
  final String title;

  const ExpenseCategory({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyText12,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      
    );
  }
}