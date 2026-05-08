import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
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
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscure = true;
  @override
 Widget build(BuildContext context) {
  
  return Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: AppColors.containerColor),
    ),
    child:TextField(
  controller: widget.controller,
  obscureText: widget.isPassword ? isObscure : false,
  decoration: InputDecoration(
    border: InputBorder.none,
    hintText: widget.hintText,

    suffixIcon: widget.isPassword
        ? IconButton(
           icon: Icon(
          isObscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.black, 
        ),
            onPressed: () {
              setState(() {
                isObscure = !isObscure;
              });
            },
          )
        : null,
  ),
),
  );
}
}