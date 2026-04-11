import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/sales/widget/recent_sales_card.dart';
import 'package:proteinova_connect/features/sales/widget/stock_preview_card.dart';
import 'package:proteinova_connect/features/sales/widget/transaction_detailscard.dart';

class SalesEntry extends StatefulWidget {
  const SalesEntry({super.key});

  @override
  State<SalesEntry> createState() => _SalesEntryState();
}

class _SalesEntryState extends State<SalesEntry> {
   final TextEditingController categoryController = TextEditingController();
final TextEditingController quantityController = TextEditingController();
final TextEditingController nameController = TextEditingController();
final TextEditingController notesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
     final Size size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background1,
    body:
     Padding(
      padding: EdgeInsets.only(left: size.height*0.01, right:size.height*0.01 ),
      child: 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: size.height*0.06,),

          Padding(
            padding:  EdgeInsets.only(left: size.width*0.72),
            child: 
            Row(
              children: [
              Icon(Icons.notifications_outlined),

              SizedBox(width:  size.width*0.02,),

               Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
               
              ),
            ),
            
            ],),
          ),
          Divider(),
           
           Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Daily Sales Entry",style: AppTextStyles.headingText22,),

                  SizedBox(width:  size.width*0.07,),

                   Container(
                padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.containerColor2,
                  border: Border.all(color: AppColors.border2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu,color: AppColors.blueAccent,),
                    Text(
                      "Today's Sales",
                      style:AppTextStyles.blueText2
                                  ),
                  ],
                ),
              ),
             
              ],
              ),

              SizedBox(height: size.height*0.02,),

               Text("Log new sales transactions to automatically update\nbranch inventory.",style: AppTextStyles.bodyText14,),

               SizedBox(height: size.height*0.02,),

               TransactionDetailscard(
                categoryController: categoryController, 
                quantityController: quantityController, 
                nameController: nameController, 
                notesController: notesController
                ),
                SizedBox(height: size.height*0.02,),

                StockPreviewCard(
               
                available: "8,000",
                selling: "- 50",
                remaining: "7,950",
               
                onReceiveTap: () {},
              ),
              SizedBox(height: size.height*0.02,),

              RecentSalesCard(
  sales: [
    SaleItem(time: "10:45 AM", quantity: 12, customer: "Walk-in"),
    SaleItem(time: "09:12 AM", quantity: 200, customer: "City Supermarket"),
    SaleItem(time: "08:30 AM", quantity: 15, customer: "Walk-in"),
  ],
),
SizedBox(height: size.height*0.05,),

    ])
    )
    )
    ])
    )
    );
  }
}