import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

class ApprovalEmptyWidget extends StatelessWidget {
  const ApprovalEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 24),

          const Text(
            "No approvals found",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),

          SizedBox(height: getHeight(context, 12)),

          const Text(
            "No approvals found in this status.",
            style: TextStyle(fontSize: 13, color: Color(0xff6B7280)),
          ),

          SizedBox(height: getHeight(context, 20)),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(context, 24),
                vertical: getHeight(context, 15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xffE5E7EB)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text(
              "Change Status",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
