import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class EditButton extends StatelessWidget {
  const EditButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 238, 238),
        border: Border.all(
          color: const Color.fromARGB(255, 214, 210, 210),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 16),
          const SizedBox(width: 6),
          Text("Edit", style: AppTextStyles.headingText21),
        ],
      ),
    );
  }
}