import 'package:flutter/material.dart';

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({super.key});

  Widget bar(double revenue, double purchase, String month) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 10,
              height: revenue,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 6),

            Container(
              width: 10,
              height: purchase,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(month),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Revenue vs Purchases",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 18,
            runSpacing: 10,

            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 14, height: 14, color: Colors.green),

                  const SizedBox(width: 6),

                  const Text("Revenue"),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 14, height: 14, color: Colors.orange),

                  const SizedBox(width: 6),

                  const Text("Purchases"),
                ],
              ),
            ],
          ),

          const SizedBox(height: 34),

          SizedBox(
            height: 240,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                bar(90, 60, "Jan"),
                bar(120, 80, "Feb"),
                bar(75, 60, "Mar"),
                bar(150, 95, "Apr"),
                bar(110, 80, "May"),
                bar(160, 100, "Jun"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
