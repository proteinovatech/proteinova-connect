import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserManagementShimmer extends StatelessWidget {
  const UserManagementShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 50, width: double.infinity),
          const SizedBox(height: 24),

          _shimmerBox(height: 250, width: double.infinity),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _shimmerBox(height: 52)),
              const SizedBox(width: 16),
              Expanded(child: _shimmerBox(height: 52)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _shimmerBox(height: 52)),
              const SizedBox(width: 16),
              Expanded(child: _shimmerBox(height: 52)),
            ],
          ),

          const SizedBox(height: 24),

          _shimmerBox(height: 52, width: 180),

          const SizedBox(height: 30),

          ...List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _shimmerBox(
                height: 60,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}