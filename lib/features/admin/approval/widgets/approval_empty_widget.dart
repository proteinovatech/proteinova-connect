import 'package:flutter/material.dart';

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
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "No approvals found in this status.",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xff6B7280),
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(
                color: Color(0xffE5E7EB),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text(
              "Change Status",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}