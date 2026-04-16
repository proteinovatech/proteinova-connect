import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/branch_dashboard/dashboardoverview.dart';
import 'package:proteinova_connect/features/branch_dashboard/presentation/resentactivity.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/activityitem.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/legenditem.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stockdetails.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/trayitem.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/zigzagclipper.dart';

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
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
      Image.asset(
        "assets/erplogo.png",
        height: 40,
        width: 130,
      ),
      SizedBox(width: 120,),
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
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Dashboard Overview",
      style: AppTextStyles.headingText22,
    ),
    GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Dashboardoverview(),
      ),
    );
  },
  child: Text(
    "View All",
    style: TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w500,
    ),
  ),
)
  ],
),
SizedBox(height: 15,),
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
            "Opening Stocks",
            style:TextStyle(color: Color.fromARGB(255, 133, 132, 132)), 
          ),         
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 235, 240, 245),
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
       SizedBox(height: 15),      
     Row(
  children: [
        Text(
      "6,700",
      style: AppTextStyles.headingText20
    ),
    SizedBox(width: 6),
    Text(
      "Trays",
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
              child: Stockdetails(
                title: "Today Tray Sold",
                value: "40 trays",
               icon: Icons.check_circle_outline,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: const Color.fromARGB(255, 6, 94, 167),
                 highlightUnit: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Stock(
                title: "Closing Stock",
                value: "4,200 trays",
                percent: "13.5%",
                subtitle: "Yesterday",
                icon: Icons.timer_outlined,
                iconBg: const Color.fromARGB(255, 230, 235, 240),
                iconColor: Colors.brown,
                 highlightUnit: true,
              ),
            ),
          ],
        ),
      
SizedBox(height: 20,),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white, // Big container color
    borderRadius: BorderRadius.circular(12),
  border: Border.all(color: AppColors.border)
  ),  
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
         Text(
          "Stock Summery",
          style: AppTextStyles.headingText22,
        ),
            GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  childAspectRatio: 0.75,
  children: [
    trayItem(
      title: "Plastic trays(with eggs)",
      status: "Returnable",
      description: "Durable plastic trays used for egg transport",
      count: "200",
    ),
    trayItem(
      title: "Paper Trays(with Eggs)",
      status: "Non-Returnable",
      description: "Paper pulp trays used for egg transport",
      count: "50",
    ),
    trayItem(
      title: "Plastic trays(empty)",
      status: "Returnable",
      description: "Durable plastic trays used for egg transport",
      count: "150",
    ),
    trayItem(
      title: "Paper trays(empty)",
      status: "non-Returnable",
      description: "Paper pulp trays used for egg transport",
      count: "80",
    ),
  ],
),
    ],
      ),
),SizedBox(height: 10,),
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color:AppColors.background,
    borderRadius: BorderRadius.circular(8),
     border: Border.all(color: Colors.grey.shade300),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

            Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Active Offers",
            style: AppTextStyles.headingText22,
          ),
          Text(
            "View all",
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ],
      ),

      SizedBox(height: 10),
      Row(
        children: [

                  Expanded(
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           ClipPath(
  clipper: ZigZagClipper(),
  child: Container(
    padding: const EdgeInsets.all(14),
    color: Colors.green.shade50,
    child: Icon(
      Icons.percent,
      color: Colors.green,
      size: 15,
    ),
  ),
),

            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Buy 5 Trays Get 1 Free",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          "Medium White Eggs",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
),
          SizedBox(width: 10),

                  Expanded(
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           ClipPath(
  clipper: ZigZagClipper(),
  child: Container(
    padding: const EdgeInsets.all(14),
    color: Colors.green.shade50,
    child: Icon(
      Icons.percent,
      color: Colors.green,
      size: 15,
    ),
  ),
),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                "10% Offer",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),
        Text(
          "On white Eggs",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
)
        ],
      ),
    ],
  ),
)
 
 
  ],
),
 Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daily Sales Volume",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
Divider(),
          const SizedBox(height: 10),

          Row(
            children: [
              legendItem(Colors.orange, "Retail Sales (Units)"),
             const SizedBox(width: 16),
              legendItem(Colors.blue, "Wholesale Sales (Units)"),
            ],
          ),

          const SizedBox(height: 20),

                   SizedBox(
            height: 250, // give fixed height for chart
            child: BarChart(
              BarChartData(
                gridData:  FlGridData(
  show: true,
  drawHorizontalLine: true,
 drawVerticalLine: false,
  getDrawingVerticalLine: (value) {
    return FlLine(
      color: Colors.grey.shade300,
      strokeWidth: 1,
    );
  },
),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                        return Text(days[value.toInt()]);
                      },
                    ),
                  ),
                ),
                barGroups: _barData(),
              ),
            ),
          ),
        ],
      ),
    ),
   
                 SizedBox(height: 20,),
Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recent activity",
            style:AppTextStyles.headingText22 
          ),         
           GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>Resentactivity(),
      ),
    );
  },
  child: Text(
    "View All",
    style: TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w500,
    ),
  ),
)                  
        ],
      ),
      SizedBox(height: 20,),
     Column(
  children: [

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
     ],
)

              ],
            ),) )
           ],
        )),
    );
  }
  List<BarChartGroupData> _barData() {
    return [
      makeGroup(0, 8, 12),
      makeGroup(1, 10, 17),
      makeGroup(2, 7, 11),
      makeGroup(3, 12, 19),
      makeGroup(4, 14, 16),
      makeGroup(5, 17, 7),
    ];
  }

  BarChartGroupData makeGroup(int x, double retail, double wholesale) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: retail,
          color: Colors.orange,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: wholesale,
          color: Colors.blue,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

}