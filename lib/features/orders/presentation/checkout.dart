import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  @override
  Widget build(BuildContext context) {
      final Size size=MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(children: [
          Row(
            children: [
              Icon(Icons.arrow_back_sharp),
              Center(child: Text("Check out",style: AppTextStyles.heading1,)),
            ],
          ),
          SizedBox(height:size.height*0.05 ,),
          Divider(),
           SizedBox(height:size.height*0.03 ,),
Row(
  children: [
    Text("Sales & Dispatch",style:TextStyle(color:  Colors.grey,)),
    Text("Order #ORD-8921",style: AppTextStyles.heading2,),
    SizedBox(height: size.height * 0.03,),
    Row(children: [
      Expanded(child: SingleChildScrollView(
        child: Padding(padding:const EdgeInsets.all(1.0),
        child: Column(
          children: [Container(
             margin: const EdgeInsets.symmetric(vertical: 8), // only vertical
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   
                    Text(
                      "Order Summery",
                      style: AppTextStyles.heading1
                    ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.amber100,
                        borderRadius: BorderRadius.circular(20),),
                        child: Text(
                        "pending",
                        style: AppTextStyles.heading1
                                            ),
                      ),
                  ],),
                  SizedBox(height:size.height*0.05,),
                  Text("Delivery details",
                   style: AppTextStyles.body.copyWith(
                          
                          fontSize: 14,
                        ),),
                        Divider(),
                        SizedBox(height: size.height*2.0,),
                        Divider(),
                        Text("subtotal",style: TextStyle(color: Colors.grey),),
                          Text("Taxes(5%)",style: TextStyle(color: Colors.grey),),
                            Text("Delivery fee",style: TextStyle(color: Colors.grey),),
                           SizedBox(height:size.height*0.05,),
                  Text("Total Amount",
                  style: AppTextStyles.heading1,
                        ),  
              ],
            ),
          )],
        ),
         ),
        
      ))
    ],)
  ],
)
        ],
        
        ),
    );
  }
}