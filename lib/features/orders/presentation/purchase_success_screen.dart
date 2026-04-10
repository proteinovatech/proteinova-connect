import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/purchase_bottom_navigator.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/orders/widget/purchase_summarycard.dart';

class PurchaseSuccessScreen extends StatefulWidget {
  const PurchaseSuccessScreen({super.key});

  @override
  State<PurchaseSuccessScreen> createState() => _PurchaseSuccessScreenState();
}

class _PurchaseSuccessScreenState extends State<PurchaseSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Scaffold(backgroundColor: AppColors.background,
    body: Padding(
      padding: EdgeInsets.only(left: size.height*0.02, right:size.height*0.02 ),
      child: Column(
        children: [
          SizedBox(height: size.height*0.06,),
          Padding(
            padding: EdgeInsets.only(right: size.width*0.8 ),
            child: Container(
              width:size.height*0.04 ,
              height: size.height*0.04 ,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dark,width: 2),
                
              ),
            ),
          ),
          Divider(),
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
          PurchaseSummaryCard(),
          SizedBox(height: size.height*0.02,),
           Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppColors.amber600
              ),
            
            child: ElevatedButton(
              onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: 
          (context)=>PurchaseBottomNavigator()));
               
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
            height: 50,
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
    );
  }
}