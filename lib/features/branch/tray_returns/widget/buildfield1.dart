import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildRowField(
  String label,
  String hint, {
  TextEditingController? controller,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return Row(
    children: [
      SizedBox(
        width: 130,
        child: Text(label, style: AppTextStyles.headingText20),
      ),

      Expanded(
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background1,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget buildDropdownField(
  String label,
  String hint,
  List<String> items, {
  required ValueChanged<String?> onChanged,
  String? value,
}) {
  return Row(
    children: [
      SizedBox(
        width: 130,
        child: Text(
          label,
          style: AppTextStyles.headingText20,
        ),
      ),
      Expanded(
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background1,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              value: value != null && value.isNotEmpty ? value : null,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    ],
  );
}
