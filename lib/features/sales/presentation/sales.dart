import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/sales/widget/dashboardcard.dart';


class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  Size get size => MediaQuery.of(context).size;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.background,
         body: Padding(padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             SizedBox(height: size.height * 0.07),

          Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    SizedBox(width: 10),
      Icon(
      Icons.search,
      color: Colors.grey,
    ),
    Icon(
      Icons.notifications_none,
      color: Colors.grey,
    ),
    const SizedBox(width: 12),
    CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade300,
    ),
  ],
),
            const Divider(),
            Text("Sales & Dispatch",style: AppTextStyles.headingText22,),
            SizedBox(height: 20,),
               GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Newpurchase(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.amber600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: AppColors.dark),
                            const SizedBox(width: 8),
                            Text(
                              "New Sale",
                              style: AppTextStyles.headingText20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                      Expanded(child:SingleChildScrollView(child: Column(
              crossAxisAlignment: .start,
              children: [
                SizedBox(height: 10,),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [     
                Row(
               children: [
               
                 /// 🔹 FIRST CARD
                 Expanded(
                   child: DashboardCard(
                     title: "Sales today",
                     value: "\$49,300",
                     percent: "+2.4%",
                     subtitle: "Vs yesterday",
                     icon: Icons.inventory_2,
                     iconBg: Colors.blue.shade100,
                     iconColor: Colors.blue,
                   ),
                 ),
               
                 const SizedBox(width: 10),
               
                 /// 🔹 SECOND CARD
                 Expanded(
                   child: DashboardCard(
                     title: "Pending Dispatches",
                     value: "1,245",
                     percent: "+1.8%",
                     subtitle: "vs yesterday",
                     icon: Icons.shopping_cart,
                     iconBg: Colors.orange.shade100,
                     iconColor: Colors.orange,
                   ),
                 ),
               ],
               )
                 ],
               ),SizedBox(height: 15,)])))
                    ]))
    );
  }
}