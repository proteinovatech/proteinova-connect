import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

Widget buildCustomerInput(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.background,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer Number", style: AppTextStyles.bodyText14dark),
                  const SizedBox(height: 4),
                  _inputField("Enter number"),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer Name", style: AppTextStyles.bodyText14dark),
                  const SizedBox(height: 4),
                  _inputField("Name"),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
  "Sales Date",
  style: AppTextStyles.bodyText14dark,
),

const SizedBox(height: 4),

TextField(
  readOnly: true,

  decoration: InputDecoration(
    hintText: "DD/MM/YY",

    suffixIcon: IconButton(
      onPressed: () async {
        DateTime? pickedDate =
            await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          print(pickedDate);
        }
      },

      icon: const Icon(
        Icons.calendar_month,
      ),
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
),
      ],
    ),
  );
}
Widget _inputField(String hint, {bool isNumber = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(5),
    ),
    child: TextField(
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
      ),
    ),
  );
}