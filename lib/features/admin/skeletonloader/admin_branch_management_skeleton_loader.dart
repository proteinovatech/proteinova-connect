import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminBranchManagementSkeletonLoader extends StatelessWidget {
  const AdminBranchManagementSkeletonLoader({super.key});

  Widget box({
    double height = 20,
    double width = double.infinity,
    double radius = 14,
  }) {
    return Container(
      height: height,
      width: width,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      direction: ShimmerDirection.rtl,

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// TOP CARDS
            Row(
              children: [
                Expanded(
                  child: box(height: 110, radius: 18),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: box(height: 110, radius: 18),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: box(height: 110, radius: 18),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: box(height: 110, radius: 18),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// DIRECTORY CARD
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  /// HEADER
                  Row(
                    children: [
                      Expanded(
                        child: box(height: 26, width: 160),
                      ),

                      const SizedBox(width: 16),

                      box(height: 45, width: 150),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH
                  box(height: 52),

                  const SizedBox(height: 14),

                  /// FILTERS
                  Row(
                    children: [
                      Expanded(
                        child: box(height: 50),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: box(height: 50),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// TABLE HEADER
                  box(height: 50, radius: 8),

                  const SizedBox(height: 14),

                  /// TABLE ITEMS
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: 5,

                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      return box(height: 72, radius: 16);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}