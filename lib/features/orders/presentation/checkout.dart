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
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 HEADER
          SizedBox(
            height: size.height * 0.09,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    "Check out",
                    style: AppTextStyles.headingText25,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.arrow_back_sharp),
                ),
              ],
            ),
          ),

          
          const Divider(),

          /// 🔹 TITLE SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Sales & Dispatch  >",
                      style: AppTextStyles.formInputs15,
                    ),
                    SizedBox(width: size.width*0.01,),
                    Text(
                  "Order #ORD-8921",
                  style: AppTextStyles.headingText21,
                ),
                  ],
                ),
                
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          /// 🔥 SCROLLABLE AREA
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [

                    /// 🔹 CARD
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                         
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order Summary",
                                style: AppTextStyles.headingText22,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.amber100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Pending",
                                  style: AppTextStyles.bodyText16,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.03),

                          /// 🔹 DELIVERY
                          Text(
                            "Delivery details",
                            style: AppTextStyles.headingText21,
                          ),

                          const SizedBox(height: 10),
                          Divider(),

                          SizedBox(height: size.height * 0.03),

                         
                          Text("Subtotal", style:AppTextStyles.formInputs15),
                          Text("Taxes (5%)", style:AppTextStyles.formInputs15 ),
                          Text("Delivery fee", style: AppTextStyles.formInputs15),

                          SizedBox(height: size.height * 0.02),

                          /// 🔹 TOTAL
                          Text(
                            "Total Amount",
                            style: AppTextStyles.headingText21,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}