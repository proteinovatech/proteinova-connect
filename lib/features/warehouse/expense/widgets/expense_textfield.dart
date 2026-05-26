import 'package:flutter/material.dart';

class ExpenseTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final Widget? prefixIcon;

  const ExpenseTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xffE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xffE5E7EB),
          ),
        ),
      ),
    );
  }
}