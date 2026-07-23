import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesCategoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> branchSales;
  final List<Map<String, dynamic>> recentSales;
  const SalesCategoryCard({
    super.key,
    required this.branchSales,
    required this.recentSales,
  });

  @override
  Widget build(BuildContext context) {
    final double totalSales = branchSales.fold<double>(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item["total_sales"].toString()) ?? 0.0),
    );

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
                    sectionsSpace: 0,
                    centerSpaceRadius: 58,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: totalSales == 0 ? 1 : totalSales,
                        color: const Color(0xFF3B82F6), // Single blue color
                        radius: 22,
                        showTitle: false,
                      ),
                    ],
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
          const SizedBox(height: 20),

          const Text(
            "Recent Sales Orders",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 15),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSales.length > 5 ? 5 : recentSales.length,
            separatorBuilder: (_, __) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final sale = recentSales[index];

              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.green,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale["customer"]?.toString() ??
                              sale["customer_name"]?.toString() ??
                              "Walk-in Customer",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (sale["payment_method"] ??
                                  sale["payment_mode"] ??
                                  "CASH")
                              .toString()
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${sale["amount"] ?? sale["total_amount"] ?? 0}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${sale["items_qty"] ?? sale["total_eggs_sold"] ?? 0} Eggs",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
