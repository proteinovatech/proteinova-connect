import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminIncomingStockQueueSkeletonLoader
    extends StatelessWidget {
  const AdminIncomingStockQueueSkeletonLoader({
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
              horizontal: 16,
              vertical: 20,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                /// TOP SPACE
                const SizedBox(height: 10),

                /// HEADER TITLE
                skeletonBox(
                  height: 28,
                  width: 240,
                  radius: 8,
                ),

                const SizedBox(height: 12),

                /// SUBTITLE
                skeletonBox(
                  height: 14,
                  width: 280,
                  radius: 6,
                ),

                const SizedBox(height: 6),

                skeletonBox(
                  height: 14,
                  width: 180,
                  radius: 6,
                ),

                const SizedBox(height: 24),

                /// TOP CARDS
                ListView.separated(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: 3,

                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),

                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(18),

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
                                height: 16,
                                width: 130,
                                radius: 6,
                              ),

                              skeletonBox(
                                height: 42,
                                width: 42,
                                radius: 12,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          skeletonBox(
                            height: 32,
                            width: 170,
                            radius: 8,
                          ),

                          const SizedBox(height: 12),

                          skeletonBox(
                            height: 14,
                            width: 140,
                            radius: 6,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                /// FILTERS
                Row(
                  children: [
                    Expanded(
                      child: skeletonBox(
                        height: 52,
                        radius: 14,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: skeletonBox(
                        height: 52,
                        radius: 14,
                      ),
                    ),

                    const SizedBox(width: 12),

                    skeletonBox(
                      height: 52,
                      width: 52,
                      radius: 14,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// TABLE CARD
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [
                      /// TABLE HEADER
                      Row(
                        children: [
                          Expanded(
                            child: skeletonBox(
                              height: 16,
                              radius: 6,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: skeletonBox(
                              height: 16,
                              radius: 6,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: skeletonBox(
                              height: 16,
                              radius: 6,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// TABLE ROWS
                      ListView.separated(
                        shrinkWrap: true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        itemCount: 4,

                        separatorBuilder: (_, __) =>
                            const Divider(height: 28),

                        itemBuilder: (context, index) {
                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    skeletonBox(
                                      height: 18,
                                      width: 70,
                                      radius: 6,
                                    ),

                                    const SizedBox(height: 10),

                                    skeletonBox(
                                      height: 14,
                                      width: 110,
                                      radius: 6,
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    skeletonBox(
                                      height: 18,
                                      width: 120,
                                      radius: 6,
                                    ),

                                    const SizedBox(height: 10),

                                    skeletonBox(
                                      height: 14,
                                      width: 80,
                                      radius: 6,
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [
                                    skeletonBox(
                                      height: 18,
                                      width: 90,
                                      radius: 6,
                                    ),

                                    const SizedBox(height: 10),

                                    skeletonBox(
                                      height: 14,
                                      width: 70,
                                      radius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
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