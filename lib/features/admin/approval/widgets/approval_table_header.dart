import 'package:flutter/material.dart';

class ApprovalTableHeader extends StatelessWidget {
  const ApprovalTableHeader({super.key});

  Widget item(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [

          item("REQUEST ID", 2),

          item("TYPE", 2),

          item("CUSTOMER", 2),

          item("DETAILS", 2),

          item("DATE & REQUESTER", 3),

          item("STATUS", 2),

          item("ACTIONS", 2),
        ],
      ),
    );
  }
}