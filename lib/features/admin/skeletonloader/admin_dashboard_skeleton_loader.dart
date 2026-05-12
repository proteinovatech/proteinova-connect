import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminDashboardSkeletonLoader extends StatelessWidget {
  const AdminDashboardSkeletonLoader({super.key});

  Widget skeletonBox({
    double height = 100,
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

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  skeletonBox(height: 28, width: 220),
                  skeletonBox(height: 28, width: 28, radius: 8),
                ],
              ),

              const SizedBox(height: 24),

              /// DASHBOARD CARDS
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  return skeletonBox(height: 120);
                },
              ),

              const SizedBox(height: 28),

              /// RECENT ACTIVITY TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  skeletonBox(height: 24, width: 180),
                  skeletonBox(height: 20, width: 70),
                ],
              ),

              const SizedBox(height: 20),

              /// RECENT ACTIVITY LIST
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ICON
                      skeletonBox(
                        height: 50,
                        width: 50,
                        radius: 25,
                      ),

                      const SizedBox(width: 12),

                      /// TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            skeletonBox(
                              height: 16,
                              width: double.infinity,
                            ),

                            const SizedBox(height: 10),

                            skeletonBox(
                              height: 14,
                              width: 180,
                            ),

                            const SizedBox(height: 10),

                            skeletonBox(
                              height: 12,
                              width: 120,
                            ),
                          ],
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
      ),
    );
  }
}