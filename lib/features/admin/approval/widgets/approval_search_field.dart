import 'package:flutter/material.dart';

class ApprovalSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const ApprovalSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xffE5E7EB),
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: "Search requests...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}