import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSkeletonLoader extends StatelessWidget {
  const DashboardSkeletonLoader({super.key});

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
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,

        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(context, 20),
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(height: getHeight(context, 60)),

                /// Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    skeletonBox(
                      height: getHeight(context, 40),
                      width: getWidth(context, 130),
                    ),

                    skeletonBox(
                      height: getHeight(context, 40),
                      width: getWidth(context, 40),
                      radius: 20,
                    ),
                  ],
                ),

                SizedBox(height: getHeight(context, 20)),

                skeletonBox(
                  height: getHeight(context, 25),
                  width: getWidth(context, 180),
                ),

                SizedBox(height: getHeight(context, 20)),

                /// Opening stock card
                skeletonBox(
                  height: getHeight(context, 120),
                  width: double.infinity,
                ),

                SizedBox(height: getHeight(context, 15)),

                /// Two cards
                Row(
                  children: [
                    Expanded(
                      child: skeletonBox(
                        height: getHeight(context, 120),
                      ),
                    ),

                    SizedBox(width: getWidth(context, 10)),

                    Expanded(
                      child: skeletonBox(
                        height: getHeight(context, 120),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: getHeight(context, 20)),

                skeletonBox(
                  height: getHeight(context, 25),
                  width: getWidth(context, 150),
                ),

                SizedBox(height: getHeight(context, 15)),

                /// Grid skeletons
                GridView.builder(
                  itemCount: 4,

                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.3,
                      ),

                  itemBuilder: (context, index) {
                    return skeletonBox(
                      height: getHeight(context, 120),
                    );
                  },
                ),

                SizedBox(height: getHeight(context, 20)),

                /// Low stock
                skeletonBox(
                  height: getHeight(context, 220),
                  width: double.infinity,
                ),

                SizedBox(height: getHeight(context, 20)),

                /// Chart
                skeletonBox(
                  height: getHeight(context, 300),
                  width: double.infinity,
                ),

                SizedBox(height: getHeight(context, 20)),

                /// Recent activity title
                skeletonBox(
                  height: getHeight(context, 25),
                  width: getWidth(context, 180),
                ),

                SizedBox(height: getHeight(context, 20)),

                /// Activity list
                ListView.builder(
                  itemCount: 5,

                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: getHeight(context, 15),
                      ),

                      child: Row(
                        children: [
                          skeletonBox(
                            height: getHeight(context, 50),
                            width: getWidth(context, 50),
                            radius: 25,
                          ),

                          SizedBox(width: getWidth(context, 12)),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                skeletonBox(
                                  height: getHeight(context, 16),
                                  width: double.infinity,
                                ),

                                SizedBox(
                                  height: getHeight(context, 8),
                                ),

                                skeletonBox(
                                  height: getHeight(context, 14),
                                  width: getWidth(context, 180),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: getHeight(context, 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}