import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/activityitem.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/customccard.dart';

class BranchDashboard extends StatefulWidget {
  const BranchDashboard({super.key});

  @override
  State<BranchDashboard> createState() => _BranchDashboardState();
}

class _BranchDashboardState extends State<BranchDashboard> {
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
            Text("Dashboard Overview",style: AppTextStyles.headingText22,),
            Expanded(child:SingleChildScrollView(child: Column(
              crossAxisAlignment: .start,
              children: [
                SizedBox(height: 10,),
               Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [     
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Stock Value",
            style:TextStyle(color: Color.fromARGB(255, 133, 132, 132)), 
          ),         
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.blue,
              size: 18,
            ),
          ),
        ],
      ),
       SizedBox(height: 25),      
      const Text(
        "\$1,37,67,289",
        style: AppTextStyles.headingText25
      ),
      const SizedBox(height: 5),
      Row(
  children: const [
    Icon(
      Icons.trending_up, // waved arrow style
      color: Colors.green,
      size: 20,
    ),
     SizedBox(width: 6),
    Text(
      "+2.4%",
      style: TextStyle(
        color: Colors.green,
        fontSize: 14,
      ),
    ),
    SizedBox(width: 6),
    Text(
      "Vs last mont",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
    ),
  ],
)
    ],
  ),
),SizedBox(height: 15,),
Row(
  children: [
    Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 247, 248),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.deepOrange,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Incoming Stocks",
              style: TextStyle(
                color: Color.fromARGB(255, 133, 132, 132),
                fontSize: 13
              ),
            ),
            const SizedBox(height: 25),
         Row(
              children: const [
              
                Text("14,200",
                    style: AppTextStyles.headingText20),
                SizedBox(width: 6),
                Text("Trays",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: const [
                Icon(Icons.trending_up,
                    color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text("+12.1%",
                    style: TextStyle(color: Colors.green)),              
              ],
            ),
          ],
        ),
      ),
    ),
    const SizedBox(width: 10),
      Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 247, 248),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home,
                color: Colors.deepOrange,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Branch sales Revenue",
              style: TextStyle(
                color: Color.fromARGB(255, 133, 132, 132),
                fontSize: 12
              ),
            ),
            const SizedBox(height: 25),
         Text("\$432,200",
             style: AppTextStyles.headingText20),
            const SizedBox(height: 5),
            Row(
              children: const [
                Icon(Icons.trending_up,
                    color: Colors.green, size: 20),
                SizedBox(width: 6),
                Text("+8.1%",
                    style: TextStyle(color: Colors.green)),              
              ],
            ),
          ],
        ),
      ),
    ),
  ],
),
SizedBox(height: 60,),
Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Action Required",
            style:AppTextStyles.headingText22 
          ),         
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 251, 187, 230),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text("3 Alerts",style: TextStyle(color: Colors.pink),)
          ),
        ],
      ),
      SizedBox(height: 15,),
       CustomCard(
              icon: Icons.error_outline,
              title: "Critical Stock Depletion ",
              text1: "SQU-811 has dropped below the\n minimum safety thrushold.currentstock\nfour unit",
              text2: "Review and Reorder",
            
            ),
             SizedBox(height: 12),

            CustomCard(
              icon: Icons.timer_outlined,
              title: "Shipment Delayed",
              text1: "Inbound Shipment PO-420 delayed by 48\n hours.Expected delivery was today",
              text2: "Track Shipment",
             
            ),

            SizedBox(height: 12),

            CustomCard(
              icon: Icons.pending_actions_outlined,
              title: "Pendding Approvals",
              text1: "5 purchase orders are waiting for\n management approval before processing",
              text2: "Go to approvals",
             
            ),
            SizedBox(height: 20,),
Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Resent activity",
            style:AppTextStyles.headingText22 
          ),         
          Text("view all",style: TextStyle(color: Colors.blue,fontSize: 16),),                  
        ],
      ),
      SizedBox(height: 20,),
     Column(
  children: [

    /// 🔹 FIRST ITEM
    ActivityItem(
      leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: "Sarah jenzkin generated purchase order",
      subtitle: Row(
        children: const [
          Text("#PO-4092",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(width: 5),
          Text("for 500x wireless headset",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
      time: "10 min ago",
      tag: "procurement",
    ),

    const SizedBox(height: 15),
    const Divider(),
    const SizedBox(height: 10),
        ActivityItem(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.local_shipping_outlined,
            color: Colors.green),
      ),
      title: "Dispatch DS-110 marked as in transit to",
      subtitle: const Text(
        "Branch (Downtown)",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      time: "10 min ago",
      tag: "procurement",
    ),
    const SizedBox(height: 15),
    const Divider(),
    const SizedBox(height: 10),
        ActivityItem(
     leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: "Marcus Doe recorded anew bulk sales",
      subtitle: const Text(
        "entry #NV",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
      ),
      time: "5 min ago",
      tag: "delivery",
    ),
    const SizedBox(height: 15),
    const Divider(),
    const SizedBox(height: 10),
      ActivityItem(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.error_outline,
            color: Colors.red),
      ),
      title: "Dispatch DS-110 marked as in transit to",
      subtitle: const Text(
        "Branch (Downtown)",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      time: "10 min ago",
      tag: "procurement",
    ),
    const SizedBox(height: 15),
    const Divider(),
    const SizedBox(height: 10),
        ActivityItem(
     leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: "Marcus Doe recorded anew bulk sales",
      subtitle: const Text(
        "entry #NV",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
      ),
      time: "5 min ago",
      tag: "delivery",
    ),
  ],
)

              ],
            ),) )
           ],
        )),
    );
  }
}