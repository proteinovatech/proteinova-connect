import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Receiveditem extends StatefulWidget {
  final String title;

  const Receiveditem({
    super.key,
    required this.title,
  });

  @override
  State<Receiveditem> createState() => _ReceiveditemState();
}

class _ReceiveditemState extends State<Receiveditem> {
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

          // 🔹 Dynamic Title
          Text(
            widget.title,
            style: AppTextStyles.bodyText14dark,
          ),

          const SizedBox(height: 12),

          // 🔹 Row 1 Titles
          const Row(
            children: [
              Expanded(child: Text("Trays")),
              Expanded(child: Text("Eggs")),
            ],
          ),

          const SizedBox(height: 6),

          // 🔹 Row 1 Inputs
          Row(
            children: [
              Expanded(child: _inputField("Enter count")),
              const SizedBox(width: 10),
              Expanded(child: _inputField("Enter count")),
            ],
          ),
          ],
      ),
    );
  }

  // 🔥 Reusable input field
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