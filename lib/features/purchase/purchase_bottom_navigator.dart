import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/presentation/purchase_dashboard.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/presentation/newpurchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseBottomNavigator extends StatefulWidget {
  const PurchaseBottomNavigator({super.key});

  @override
  State<PurchaseBottomNavigator> createState() => _PurchasebottomnavigatorState();
}
final cache = PurchaseCacheService();
class _PurchasebottomnavigatorState extends State<PurchaseBottomNavigator> {
  int selectedIndex = 0;
  late final PurchaseBloc purchaseBloc;

@override
void initState() {
  super.initState();

  purchaseBloc = PurchaseBloc(
    SupplierRepository(DioClient().dio),
    PurchaseRepository(DioClient().dio, cache),
    cache,
  )..add(GetCachedPurchasesEvent()); // preload
}
  
  
  void _showProfileOptions(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:  Text("Profile",style: AppTextStyles.headingText20,),
        content: Text("Do you want to logout?",style: AppTextStyles.bodyText14,),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child:  Text("Cancel",style: AppTextStyles.browntext,),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); 

  Navigator.pushNamedAndRemoveUntil(
    context,
    "/signup", 
    (route) => false,); 
             
             
            },
            child: const Text("Logout",style: AppTextStyles.browntext,),
          ),
        ],
      );
    },
  );
}

 

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
   PurchaseDashboard(),
  

   Newpurchase(
      isEdit: false,
      purchaseData: null,
    ),
  

  Center(child: Text("Notifications Screen")),
];
    return BlocProvider.value(
      value: purchaseBloc,
      child: Scaffold(
        body:IndexedStack(
        index: selectedIndex,
        children: pages,
      ) ,
      
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
              _buildNavItem(Icons.person_outline, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
  bool isSelected = selectedIndex == index;

  return GestureDetector(
    onTap: () {
  if (index == 2) {
    _showProfileOptions(context); 
  } else {
    setState(() {
      selectedIndex = index;
    });
  }
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
        return "Purchase";
      case 2:
        return "Profile";
      default:
        return "";
    }
  }
}