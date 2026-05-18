import 'package:flutter/material.dart';

Widget conditionBox({
  required int index,
  required int selectedIndex,
  required VoidCallback onTap,
  required IconData icon,
  required String text,
  required Color color,
}) {
  bool isSelected = index == selectedIndex;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? color : Colors.grey,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : Colors.grey,
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}