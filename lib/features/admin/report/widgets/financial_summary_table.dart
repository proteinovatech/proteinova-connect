import 'package:flutter/material.dart';

import '../data/report_dummy_data.dart';

class FinancialSummaryTable extends StatelessWidget {
  const FinancialSummaryTable({super.key});

  Widget header(String text, double width) {
    return SizedBox(
      width: width,

      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xff6B7280),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget cell(String text, double width) {
    return SizedBox(
      width: width,

      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),

      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),

            decoration: const BoxDecoration(
              color: Color(0xffF9FAFB),

              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),

            child: Row(
              children: [

                header("BRANCH NAME", 230),

                header("TOTAL REVENUE", 180),

                header("TOTAL PURCHASES", 180),

                header("NET PROFIT", 160),

                header("PROFIT MARGIN", 150),
              ],
            ),
          ),

          ...reportBranches.map(
            (e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 22,
                ),

                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),

                child: Row(
                  children: [

                    cell(e.branchName, 230),

                    cell(e.revenue, 180),

                    cell(e.purchases, 180),

                    cell(e.profit, 160),

                    cell(e.margin, 150),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}