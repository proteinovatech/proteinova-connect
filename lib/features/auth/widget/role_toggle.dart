import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class RoleToggle extends StatefulWidget {
  final Function(String)? onChanged; // to send value to parent
  final String initialValue;
  const RoleToggle({super.key, this.onChanged,required this.initialValue});

  @override
  State<RoleToggle> createState() => _RoleToggleState();
}

class _RoleToggleState extends State<RoleToggle> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.amber600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab("Admin", 0),
          _buildTab("Branch", 1),
          _buildTab("Purchase", 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          // send value to parent screen
          if (widget.onChanged != null) {
            widget.onChanged!(title);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cardBackground
                : AppColors.amber600,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: isSelected
                  ? AppTextStyles.buttonText16.copyWith(color: Colors.black)
                  : AppTextStyles.bodyText16,
            ),
          ),
        ),
      ),
    );
  }
}
