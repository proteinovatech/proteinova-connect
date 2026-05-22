import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminDistributionSkeletonLoader
    extends StatelessWidget {
  const AdminDistributionSkeletonLoader({
    super.key,
  });

  Widget skeletonBox({
    double height = 20,
    double? width,
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

  Widget dashboardCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              skeletonBox(
                height: 42,
                width: 42,
                radius: 12,
              ),

              skeletonBox(
                height: 18,
                width: 18,
                radius: 8,
              ),
            ],
          ),

          const SizedBox(height: 18),

          skeletonBox(height: 18, width: 120),

          const SizedBox(height: 16),

          skeletonBox(height: 28, width: 40),

          const SizedBox(height: 14),

          skeletonBox(height: 14, width: 130),
        ],
      ),
    );
  }

  Widget dispatchCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              skeletonBox(
                height: 42,
                width: 42,
                radius: 12,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    skeletonBox(
                      height: 18,
                      width: 80,
                    ),

                    const SizedBox(height: 14),

                    skeletonBox(
                      height: 14,
                      width: double.infinity,
                    ),

                    const SizedBox(height: 10),

                    skeletonBox(
                      height: 14,
                      width: 180,
                    ),

                    const SizedBox(height: 10),

                    skeletonBox(
                      height: 14,
                      width: 140,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  skeletonBox(
                    height: 16,
                    width: 60,
                  ),

                  const SizedBox(height: 18),

                  skeletonBox(
                    height: 34,
                    width: 90,
                    radius: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              /// TOP HEADER
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        skeletonBox(
                          height: 30,
                          width: 220,
                        ),

                        const SizedBox(height: 12),

                        skeletonBox(
                          height: 16,
                          width: 180,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  skeletonBox(
                    height: 48,
                    width: 140,
                    radius: 18,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// DASHBOARD GRID
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  return dashboardCardSkeleton();
                },
              ),

              const SizedBox(height: 30),

              /// TITLE
              skeletonBox(
                height: 28,
                width: 240,
              ),

              const SizedBox(height: 20),

              /// SEARCH + FILTER
              Row(
                children: [
                  Expanded(
                    child: skeletonBox(
                      height: 48,
                      radius: 16,
                    ),
                  ),

                  const SizedBox(width: 12),

                  skeletonBox(
                    height: 48,
                    width: 110,
                    radius: 16,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              /// DISPATCH LIST
              ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  return dispatchCardSkeleton();
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}