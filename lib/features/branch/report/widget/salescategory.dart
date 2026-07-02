import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesCategoryCard extends StatelessWidget {
  const SalesCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final totalSales = 165.0;

    final categories = [
      {
        "name": "without tray",
        "amount": 120.0,
        "color": const Color(0xFF3B82F6),
      },
      {
        "name": "Plastic tray (With egg)",
        "amount": 30.0,
        "color": const Color(0xFF8B5CF6),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              const Text(
                "Sales by Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(Icons.open_in_new, size: 18, color: Colors.blue.shade400),
            ],
          ),

          const SizedBox(height: 30),

          /// Donut Chart
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 58,
                    sections: categories.map((item) {
                      return PieChartSectionData(
                        value: item["amount"] as double,
                        color: item["color"] as Color,
                        radius: 22,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),

                /// Center Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Total Sales",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹ ${totalSales.toInt()}",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Category List
          ...categories.map((item) {
            final amount = item["amount"] as double;
            final percentage = ((amount / totalSales) * 100);

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 5,
                        backgroundColor: item["color"] as Color,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          item["name"].toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),

                      Text(
                        "₹ ${amount.toInt()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${percentage.toStringAsFixed(2)}%",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Divider(color: Colors.grey.shade200, height: 1),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
