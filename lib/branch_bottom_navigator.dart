import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch_dashboard/presentation/branch_dashboard.dart';
import 'package:proteinova_connect/features/inventory/presentation/inventory.dart';
import 'package:proteinova_connect/features/sales/presentation/dispatchscreen.dart';
import 'package:proteinova_connect/features/sales/presentation/sales.dart';

class BranchBottomNavigator extends StatefulWidget {
  const BranchBottomNavigator({super.key});

  @override
  State<BranchBottomNavigator> createState() => _BranchBottomNavigatorState();
}

class _BranchBottomNavigatorState extends State<BranchBottomNavigator> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    BranchDashboard(),
    Inventory(),
    Sales(),
    Dispatchscreen(),
    const Center(child: Text("Notifications Screen")),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: pages[selectedIndex],

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: AppColors.textSecondary, blurRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view, 0),
            _buildNavItem(Icons.inventory, 1),
            _buildNavItem(Icons.shopping_cart_outlined,2),
            _buildNavItem(Icons.local_shipping_outlined, 3),
             _buildNavItem(Icons.menu_outlined, 4),
             
          ],
        ),
      ),
    );
  }
  Widget _buildNavItem(IconData icon, int index) {
  bool isSelected = selectedIndex == index;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedIndex = index;
      });
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.amber600 : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.dark : AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 4),

        // ✅ Show text ONLY when selected
        if (isSelected)
          Text(
            _getLabel(index),
            style: AppTextStyles.bodyText16,
          ),
      ],
    ),
  );
}

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Inventory";
      case 2:
        return "Sales";
      case 3:
        return "Dispatches";
      case 4:
        return "Menu";
      default:
        return "";
    }
  }
}