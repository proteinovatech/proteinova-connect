import 'package:flutter/material.dart';

class ExpenseTableHeader extends StatelessWidget {
  const ExpenseTableHeader({super.key});

  Widget item(String text, {int flex = 1, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,

      child: Text(
        text,

        textAlign: align,

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xff6B7280),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),

      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          item("Date", flex: 2),

          item("Category", flex: 2),

          item("Description", flex: 3, align: TextAlign.center),

          item("Amount", flex: 2, align: TextAlign.center),

          item("Status", flex: 2, align: TextAlign.center),
        ],
      ),
    );
  }
}
