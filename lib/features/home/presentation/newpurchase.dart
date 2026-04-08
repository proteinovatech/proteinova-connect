import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/home/widget/product_specificationcard.dart';
import 'package:proteinova_connect/features/home/widget/purchase_summarycard.dart';
import 'package:proteinova_connect/features/home/widget/supplier_locationcard.dart';

class Newpurchase extends StatefulWidget {
  const Newpurchase({super.key});

  @override
  State<Newpurchase> createState() => _NewpurchaseState();
}

class _NewpurchaseState extends State<Newpurchase> {
  final TextEditingController categoryController = TextEditingController();
final TextEditingController quantityController = TextEditingController();
final TextEditingController rateController = TextEditingController();
final TextEditingController notesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Scaffold(backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title:  Text("New Purchase",style: AppTextStyles.heading1,),

      actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
             
            ),
          ),
        ],),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: size.width*0.04,right: size.width*0.04 ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height*0.02,),
               
                Padding(
                  padding: EdgeInsets.only( left: size.width * 0.02,),
                  child: Text("Record new form procurement and \nstock.",style: AppTextStyles.body,),
                ),
                SizedBox(height: size.height*0.02,),
                SupplierLocationCard(),
                SizedBox(height: size.height*0.02,),
                ProductSpecificationCard(
            categoryController: categoryController,
            quantityController: quantityController,
            rateController: rateController,
            notesController: notesController,
          ),
          SizedBox(height: size.height*0.02,),
           PurchaseSummaryCard(),
                ],),
          ),
        ),
    );
  }
}