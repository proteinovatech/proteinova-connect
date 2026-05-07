import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PurchaseShimmer extends StatelessWidget {
  const PurchaseShimmer({super.key});

  Widget box(double h, {double w = double.infinity}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          box(20, w: 200),
          const SizedBox(height: 16),

          box(100),
          const SizedBox(height: 16),

          box(250),
          const SizedBox(height: 16),

          box(120),
          const SizedBox(height: 16),

          box(120),
          const SizedBox(height: 16),

          box(180),
        ],
      ),
    );
  }
}