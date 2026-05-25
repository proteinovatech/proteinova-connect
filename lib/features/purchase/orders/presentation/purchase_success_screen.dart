import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/purchase/data/models/purchase_model.dart';
import 'package:proteinova_connect/features/admin/purchase/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/admin/purchase/data/repository/supplier_repository.dart';
import 'package:proteinova_connect/features/admin/purchase/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/purchase_bottom_navigator.dart';
// import 'package:proteinova_connect/features/purchase/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/purchase/orders/widget/purchase_summarycard.dart';

class PurchaseSuccessScreen extends StatefulWidget {
  final PurchaseRequest purchase;
  const PurchaseSuccessScreen({super.key, required this.purchase});

  @override
  State<PurchaseSuccessScreen> createState() => _PurchaseSuccessScreenState();
}

class _PurchaseSuccessScreenState extends State<PurchaseSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
     final purchase = widget.purchase;
    return Scaffold(backgroundColor: AppColors.background,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: size.height*0.02, right:size.height*0.02 ),
          child: Column(
            children: [
              SizedBox(height: size.height*0.06,),
             
              SizedBox(height: size.height*0.06,),
              Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(height: size.height*0.02,),
              Text("Purchase Order Created",style: AppTextStyles.headingText25,),
              Text("       Your purchase entry has been\nsuccessfully recorded and added to the\n             incoming stock queue.",
              style: AppTextStyles.bodyText16,),
              SizedBox(height: size.height*0.02,),
              PurchaseSummaryCard(purchase: purchase,),
              SizedBox(height: size.height*0.02,),
               Container(
                width: double.infinity,
                height: getHeight(context, 50),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.amber600
                  ),
                
                child: ElevatedButton(
                  onPressed: () {
                  Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
          create: (context) => PurchaseBloc(
            SupplierRepository(DioClient().dio),
            PurchaseRepository(DioClient().dio,PurchaseCacheService(),),PurchaseCacheService(),
          ),
          child: PurchaseBottomNavigator(),
              ),
            ),
            (route) => false,
          );
                   
                  },
                  style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
                  ),
                  child:  
                      Text(
                              "Back to Dashboard",
                              style: AppTextStyles.containerText
                      ),
                    
                ),
              ),
              SizedBox(height: size.height*0.01,),
              Container(
                width: double.infinity,
                height: getHeight(context, 50),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.containerColor
                  ),
                
                child: ElevatedButton(
                  onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: 
              (context)=>Newpurchase()));
                   
                  },
                  style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
                  ),
                  child:  
                      Text(
                              "Create Another Purchase",
                              style: AppTextStyles.containerText
                      ),
                    
                ),
              ),
          
            ],
          ),
        ),
      ),
    ),
    );
  }
}
