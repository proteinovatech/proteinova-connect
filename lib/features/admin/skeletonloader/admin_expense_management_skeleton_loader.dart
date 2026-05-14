import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminExpenseManagementSkeletonLoader
    extends StatelessWidget {
  const AdminExpenseManagementSkeletonLoader({
    super.key,
  });

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

      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          direction: ShimmerDirection.rtl,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                /// TOP SPACE
                const SizedBox(height: 20),

                /// TOP FILTERS
                Row(
                  children: [
                    Expanded(
                      child: skeletonBox(
                        height: 52,
                        radius: 16,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: skeletonBox(
                        height: 52,
                        radius: 16,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: skeletonBox(
                        height: 52,
                        radius: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                /// GRID CARDS
                GridView.builder(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: 8,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.92,
                      ),

                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          /// TITLE + ICON
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              skeletonBox(
                                height: 16,
                                width: 70,
                                radius: 8,
                              ),

                              skeletonBox(
                                height: 42,
                                width: 42,
                                radius: 12,
                              ),
                            ],
                          ),

                          const Spacer(),

                          /// VALUE
                          skeletonBox(
                            height: 28,
                            width: 90,
                            radius: 8,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                /// CATEGORY TITLE
                skeletonBox(
                  height: 24,
                  width: 180,
                  radius: 8,
                ),

                const SizedBox(height: 20),

                /// CHART / LIST
                skeletonBox(
                  height: 220,
                  radius: 24,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}