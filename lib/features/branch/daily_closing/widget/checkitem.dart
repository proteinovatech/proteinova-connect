import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class CheckItem extends StatefulWidget {
  final String text;

  const CheckItem({super.key, required this.text});

  @override
  State<CheckItem> createState() => _CheckItemState();
}

class _CheckItemState extends State<CheckItem> {
  bool isChecked = true; // initially green

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isChecked ? Colors.green : Colors.white,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: AppTextStyles.bodyText14dark,
          ),
        ],
      ),
    );
  }
}