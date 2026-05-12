import 'package:flutter/material.dart';

class ExpenseTableHeader extends StatelessWidget {
  const ExpenseTableHeader({super.key});

  Widget item(String text) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xff6B7280),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          item("Date"),
          item("Category"),
          item("Description"),
          item("Amount"),
          item("Status"),
        ],
      ),
    );
  }
}