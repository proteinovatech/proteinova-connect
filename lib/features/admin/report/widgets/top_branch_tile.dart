import 'package:flutter/material.dart';

class TopBranchTile extends StatelessWidget {
  final String branch;
  final String amount;
  final double progress;

  const TopBranchTile({
    super.key,
    required this.branch,
    required this.amount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Wrap(
          alignment:
              WrapAlignment.spaceBetween,
          runSpacing: 8,

          children: [

            SizedBox(
              width: 180,

              child: Text(
                branch,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(20),

          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                const Color(0xffE5E7EB),
            valueColor:
                const AlwaysStoppedAnimation(
              Color(0xffFACC15),
            ),
          ),
        ),
      ],
    );
  }
}