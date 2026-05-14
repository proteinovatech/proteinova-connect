import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:shimmer/shimmer.dart';

class DashboardOverviewSkeleton extends StatelessWidget {
  const DashboardOverviewSkeleton({super.key});

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

        child: ListView(
          children: [
            /// Card 1
            skeletonBox(
              height: getHeight(context, 120),
              width: double.infinity,
            ),

            SizedBox(height: getHeight(context, 12)),

            /// Card 2
            skeletonBox(
              height: getHeight(context, 120),
              width: double.infinity,
            ),

            SizedBox(height: getHeight(context, 12)),

            /// Card 3
            skeletonBox(
              height: getHeight(context, 120),
              width: double.infinity,
            ),

            SizedBox(height: getHeight(context, 12)),

            /// Card 4
            skeletonBox(
              height: getHeight(context, 120),
              width: double.infinity,
            ),

            SizedBox(height: getHeight(context, 12)),

            /// Card 5
            skeletonBox(
              height: getHeight(context, 120),
              width: double.infinity,
            ),

            SizedBox(height: getHeight(context, 12)),

            /// Card 6
            skeletonBox(
              height: getHeight(context, 120),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}