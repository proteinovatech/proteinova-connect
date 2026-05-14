import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminInventoryOverviewSkeletonLoader
    extends StatelessWidget {
  const AdminInventoryOverviewSkeletonLoader({
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
                const SizedBox(height: 18),

                /// HEADER TITLE
                skeletonBox(
                  height: 26,
                  width: 220,
                  radius: 8,
                ),

                const SizedBox(height: 12),

                /// ROLE BADGE
                skeletonBox(
                  height: 32,
                  width: 180,
                  radius: 30,
                ),

                const SizedBox(height: 28),

                /// TITLE + BUTTON
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          skeletonBox(
                            height: 22,
                            width: 180,
                            radius: 8,
                          ),

                          const SizedBox(height: 10),

                          skeletonBox(
                            height: 14,
                            width: 220,
                            radius: 6,
                          ),

                          const SizedBox(height: 6),

                          skeletonBox(
                            height: 14,
                            width: 170,
                            radius: 6,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    skeletonBox(
                      height: 50,
                      width: 120,
                      radius: 14,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                /// GRID CARDS
                GridView.builder(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: 6,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.95,
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
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              skeletonBox(
                                height: 14,
                                width: 90,
                                radius: 6,
                              ),

                              skeletonBox(
                                height: 34,
                                width: 34,
                                radius: 10,
                              ),
                            ],
                          ),

                          const Spacer(),

                          skeletonBox(
                            height: 28,
                            width: 120,
                            radius: 8,
                          ),

                          const SizedBox(height: 10),

                          skeletonBox(
                            height: 12,
                            width: 100,
                            radius: 6,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                /// INVENTORY LEVELS HEADER
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    skeletonBox(
                      height: 24,
                      width: 160,
                      radius: 8,
                    ),

                    skeletonBox(
                      height: 40,
                      width: 110,
                      radius: 12,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// INVENTORY GRAPH CARD
                skeletonBox(
                  height: 180,
                  radius: 24,
                ),

                const SizedBox(height: 32),

                /// RECENT ACTIVITY TITLE
                skeletonBox(
                  height: 24,
                  width: 150,
                  radius: 8,
                ),

                const SizedBox(height: 20),

                /// ACTIVITY CARD
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [
                      skeletonBox(
                        height: 44,
                        width: 44,
                        radius: 22,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            skeletonBox(
                              height: 18,
                              width: 140,
                              radius: 6,
                            ),

                            const SizedBox(height: 10),

                            skeletonBox(
                              height: 14,
                              width: 180,
                              radius: 6,
                            ),
                          ],
                        ),
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
    );
  }
}