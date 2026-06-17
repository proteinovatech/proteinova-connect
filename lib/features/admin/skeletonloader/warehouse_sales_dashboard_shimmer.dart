import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WarehouseSalesDashboardShimmer extends StatelessWidget {
  const WarehouseSalesDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: _shimmerBox(
          width: 220,
          height: 22,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _shimmerBox(
              width: 150,
              height: 40,
              radius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Stats Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (_, __) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(
                      width: 120,
                      height: 14,
                    ),

                    const SizedBox(height: 12),

                    _shimmerBox(
                      width: 60,
                      height: 28,
                    ),

                    const SizedBox(height: 8),

                    _shimmerBox(
                      width: 90,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Dispatch Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(
                    width: 220,
                    height: 18,
                  ),

                  const SizedBox(height: 20),

                  ...List.generate(
                    6,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _dispatchCard(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dispatchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(
                width: 90,
                height: 16,
              ),
              _shimmerBox(
                width: 70,
                height: 24,
                radius: BorderRadius.circular(20),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _rowShimmer(),
          const SizedBox(height: 10),

          _rowShimmer(),
          const SizedBox(height: 10),

          _rowShimmer(),

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(
                width: 70,
                height: 14,
              ),
              _shimmerBox(
                width: 50,
                height: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowShimmer() {
    return Row(
      children: [
        _shimmerBox(
          width: 16,
          height: 16,
          radius: BorderRadius.circular(4),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _shimmerBox(
            height: 14,
          ),
        ),
      ],
    );
  }

  static Widget _shimmerBox({
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
          borderRadius:
              radius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}