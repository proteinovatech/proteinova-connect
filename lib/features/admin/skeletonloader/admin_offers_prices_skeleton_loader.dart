import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminOffersPricesSkeletonLoader extends StatelessWidget {
  const AdminOffersPricesSkeletonLoader({super.key});

  Widget skeletonBox({
    double height = 20,
    double width = double.infinity,
    double radius = 16,
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
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
        },

        child: SafeArea(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            direction: ShimmerDirection.rtl,

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// TOP SPACE
                  const SizedBox(height: 8),

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      skeletonBox(height: 28, width: 180, radius: 8),

                      skeletonBox(height: 46, width: 120, radius: 12),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// TOP CARDS
                  GridView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: 4,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.05,
                        ),

                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Expanded(
                                  child: skeletonBox(height: 14, radius: 6),
                                ),
                                const SizedBox(width: 8),

                                skeletonBox(height: 36, width: 36, radius: 10),
                              ],
                            ),

                            const Spacer(),

                            skeletonBox(height: 30, width: 60, radius: 8),

                            const SizedBox(height: 10),

                            skeletonBox(height: 14, width: 100, radius: 6),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  /// ACTIVE OFFERS CARD
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            skeletonBox(height: 24, width: 140, radius: 8),

                            skeletonBox(height: 18, width: 70, radius: 6),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// TABLE HEADER
                        Row(
                          children: [
                            Expanded(child: skeletonBox(height: 16, radius: 6)),

                            const SizedBox(width: 10),

                            Expanded(child: skeletonBox(height: 16, radius: 6)),

                            const SizedBox(width: 10),

                            Expanded(child: skeletonBox(height: 16, radius: 6)),
                          ],
                        ),

                        const SizedBox(height: 60),

                        /// EMPTY ICON
                        Center(
                          child: skeletonBox(height: 70, width: 70, radius: 35),
                        ),

                        const SizedBox(height: 24),

                        /// EMPTY TEXT
                        Center(
                          child: skeletonBox(height: 20, width: 150, radius: 6),
                        ),

                        const SizedBox(height: 40),

                        /// BOTTOM LINE
                        Center(
                          child: skeletonBox(height: 4, width: 180, radius: 10),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
