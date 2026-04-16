import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stock.dart';
import 'package:proteinova_connect/features/branch_dashboard/widget/stockdetails.dart';

class Dashboardoverview extends StatelessWidget {
  const Dashboardoverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Stocks"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [

                     Stock(
              title: "Closing Stock",
              value: "4,200 trays",
              percent: "13.5%",
              subtitle: "Yesterday",
              icon: Icons.timer_outlined,
              iconBg: Color(0xFFE6EBF0),
              iconColor: Colors.brown,
              highlightUnit: true,
            ),

            const SizedBox(height: 12),

                    Stockdetails(
              title: "Opening Stock",
              value: "3,800 trays",
              icon: Icons.inventory,
              iconBg: Color(0xFFE6EBF0),
              iconColor: Colors.grey,
              highlightUnit: true,
            ),

            const SizedBox(height: 12),

            /// 🔹 Stock
            Stock(
              title: "Sales Today",
              value: "\$42,850",
              percent: "-2%",
              subtitle: "vs yesterday",
              icon: Icons.attach_money_outlined,
              iconBg: Color(0xFFE6EBF0),
              iconColor: Colors.orangeAccent,
              highlightUnit: false,
            ),

            const SizedBox(height: 12),

            /// 🔹 Stockdetails
            Stockdetails(
              title: "Incoming Stocks",
              value: "14,200 trays",
              icon: Icons.local_shipping,
              iconBg: Color(0xFFE6EBF0),
              iconColor: Colors.red,
              highlightUnit: true,
            ),

            const SizedBox(height: 12),

            /// 🔹 Stockdetails
            Stockdetails(
              title: "Damage stock",
              value: "10 trays",
              icon: Icons.send_outlined,
              iconBg: Color(0xFFE6EBF0),
              iconColor: Colors.red,
              highlightUnit: true,
            ),

            const SizedBox(height: 12),

            /// 🔹 Stockdetails
            Stockdetails(
              title: "Today Expense",
              value: "\$4,220",
              icon: Icons.trending_up,
              iconBg: Color(0xFFE6EBF0),
              iconColor: Colors.red,
              highlightUnit: false,
            ),
          ],
        ),
      ),
    );
  }
}