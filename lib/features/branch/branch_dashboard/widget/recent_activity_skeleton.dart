import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecentActivitySkeleton extends StatelessWidget {
  const RecentActivitySkeleton({super.key});

  Widget skeletonBox({
    double? height,
    double? width,
    double radius = 12,
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

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: ListView.builder(
          itemCount: 8,

          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// Avatar
                    skeletonBox(
                      height: 50,
                      width: 50,
                      radius: 25,
                    ),

                    const SizedBox(width: 12),

                    /// Text section
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
                            width: 220,
                          ),

                          const SizedBox(height: 10),

                          skeletonBox(
                            height: 12,
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                const Divider(),

                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}