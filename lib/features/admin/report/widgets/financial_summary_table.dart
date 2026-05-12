import 'package:flutter/material.dart';

class FinancialSummaryTable extends StatelessWidget {
  final List<dynamic> branches;

  const FinancialSummaryTable({super.key, required this.branches});

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
          color: Color(0xff111827),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xffE5E7EB)),
      ),

      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

            decoration: const BoxDecoration(
              color: Color(0xffF9FAFB),

              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),

            child: Row(
              children: [
                header("BRANCH NAME", 230),

                header("TOTAL SALES", 180),

                header("TOTAL ORDERS", 180),

                header("AVG ORDER VALUE", 160),
              ],
            ),
          ),

          /// ROWS
          ...branches.map((e) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),

              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),

              child: Row(
                children: [
                  cell(e["branchName"]?.toString() ?? "", 230),

                  cell("₹ ${e["revenue"] ?? 0}", 180),

                  cell("${e["totalOrders"] ?? 0}", 180),

                  cell("₹ ${e["avgOrderValue"] ?? 0}", 160),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
