import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/purchase_dashboard.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/newpurchase.dart';

class PurchaseBottomNavigator extends StatefulWidget {
  const PurchaseBottomNavigator({super.key});

  @override
  State<PurchaseBottomNavigator> createState() => _PurchasebottomnavigatorState();
}

class _PurchasebottomnavigatorState extends State<PurchaseBottomNavigator> {
  int selectedIndex = 0;

  final List<Widget> pages = [
   PurchaseDashboard(),
   Newpurchase(),
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
            _buildNavItem(Icons.shopping_cart_outlined, 1),
            _buildNavItem(Icons.notifications_none, 2),
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

          // ❌ No text when selected (your requirement)
          if (!isSelected)
            const SizedBox(height: 4),

          if (!isSelected)
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
        return "Purchase";
      case 2:
        return "Notifications";
      default:
        return "";
    }
  }
}