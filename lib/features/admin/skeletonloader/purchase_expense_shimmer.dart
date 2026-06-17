import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PurchaseExpenseShimmer extends StatelessWidget {
  const PurchaseExpenseShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _shimmerBox(height: 20, width: 160),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _shimmerBox(
              height: 32,
              width: 120,
              radius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Header Text
            Align(
              alignment: Alignment.centerLeft,
              child: _shimmerBox(
                height: 14,
                width: 180,
              ),
            ),

            const SizedBox(height: 16),

            /// Filter Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _shimmerBox(
                    height: 50,
                    radius: BorderRadius.circular(12),
                  ),

                  const SizedBox(height: 12),

                  _shimmerBox(
                    height: 50,
                    radius: BorderRadius.circular(12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Purchase Cards
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPurchaseCard(),
              ),
            ),

            const SizedBox(height: 20),

            /// Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(height: 12, width: 140),
                Row(
                  children: [
                    _shimmerBox(height: 32, width: 32),
                    const SizedBox(width: 8),
                    _shimmerBox(height: 12, width: 50),
                    const SizedBox(width: 8),
                    _shimmerBox(height: 32, width: 32),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(height: 16, width: 80),
              _shimmerBox(
                height: 24,
                width: 90,
                radius: BorderRadius.circular(8),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: _shimmerBox(
              height: 12,
              width: 100,
            ),
          ),

          const SizedBox(height: 16),

          _shimmerBox(height: 14, width: double.infinity),

          const SizedBox(height: 12),

          _shimmerBox(height: 14, width: double.infinity),

          const SizedBox(height: 12),

          _shimmerBox(height: 14, width: double.infinity),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  height: 40,
                  radius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _shimmerBox(
                  height: 40,
                  radius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double width = double.infinity,
    BorderRadius? radius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}