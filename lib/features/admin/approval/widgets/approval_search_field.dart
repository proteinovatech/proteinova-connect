import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

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
    return Container(
      height: getHeight(context, 52),

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

        textAlignVertical: TextAlignVertical.center,

        decoration: InputDecoration(
          hintText: "Search requests...",

          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),

          border: InputBorder.none,

          prefixIcon: const Icon(
            Icons.search,
            color: Colors.black,
            size: 22,
          ),

          contentPadding: EdgeInsets.symmetric(
            vertical: getHeight(context, 14),
          ),
        ),
      ),
    );
  }
}