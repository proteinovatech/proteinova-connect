import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class TrayDetailsCard extends StatelessWidget {
  final String title;

  const TrayDetailsCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

                 Text(
            title,
            style: AppTextStyles.bodyText14dark,
          ),

          const SizedBox(height: 12),
                    const Row(
            children: [
              Expanded(child: Text("Received")),
              Expanded(child: Text("Damaged")),
            ],
          ),
          const SizedBox(height: 6),
         Row(
            children: [
              Expanded(child: _inputField("Enter count")),
              const SizedBox(width: 10),
              Expanded(child: _inputField("Enter broken")),
            ],
          ),

          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: Text("Good")),
              Expanded(child: Text("Notes")),
            ],
          ),
          const SizedBox(height: 6),
                 Row(
            children: [
              Expanded(child: _inputField("Enter good trays")),
              const SizedBox(width: 10),
              Expanded(child: _inputField("Enter notes")),
            ],
          ),
        ],
      ),
    );
  }
  Widget _inputField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}