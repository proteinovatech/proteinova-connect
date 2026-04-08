import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background, // light background
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.containerColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: AppTextStyles.bodyText16,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTextStyles.formInputs15
        ),
      ),
    );
  }
}