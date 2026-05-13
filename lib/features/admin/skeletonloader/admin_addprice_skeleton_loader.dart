import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminAddpriceSkeletonLoader extends StatelessWidget {
  const AdminAddpriceSkeletonLoader({super.key});

  Widget skeletonBox({
    double height = 20,
    double? width,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP TITLE
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                skeletonBox(height: 34, width: 190),
                skeletonBox(
                  height: 50,
                  width: 50,
                  radius: 16,
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            skeletonBox(
                              height: 22,
                              width: 140,
                            ),
                            const SizedBox(height: 10),
                            skeletonBox(
                              height: 16,
                              width: 120,
                            ),
                          ],
                        ),
                      ),

                      skeletonBox(
                        height: 48,
                        width: 140,
                        radius: 16,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Align(
                    alignment: Alignment.centerRight,
                    child: skeletonBox(
                      height: 50,
                      width: 170,
                      radius: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// TABLE HEADER
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: skeletonBox(
                    height: 16,
                    width: double.infinity,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: skeletonBox(
                    height: 16,
                    width: double.infinity,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// TABLE ROWS
            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 18),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    /// LEFT FULL WIDTH
                    Expanded(
                      flex: 2,
                      child: skeletonBox(
                        height: 18,
                        width: double.infinity,
                      ),
                    ),

                    const SizedBox(width: 20),

                    /// RIGHT PRICE BOX
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: skeletonBox(
                          height: 48,
                          width: double.infinity,
                          radius: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}