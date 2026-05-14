import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:shimmer/shimmer.dart';

class SalesSkeletonLoader extends StatelessWidget {
  const SalesSkeletonLoader({super.key});

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
            horizontal: getWidth(context, 15),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: getHeight(context, 15)),

              /// Header
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

              SizedBox(height: getHeight(context, 10)),

              const Divider(),

              /// Title
              skeletonBox(
                height: getHeight(context, 28),
                width: getWidth(context, 180),
              ),

              SizedBox(height: getHeight(context, 15)),

              /// Button
              skeletonBox(
                height: getHeight(context, 50),
                width: double.infinity,
              ),

              SizedBox(height: getHeight(context, 20)),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// Dashboard cards
                      Row(
                        children: [
                          Expanded(
                            child: skeletonBox(
                              height: getHeight(context, 140),
                            ),
                          ),

                          SizedBox(width: getWidth(context, 10)),

                          Expanded(
                            child: skeletonBox(
                              height: getHeight(context, 140),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: getHeight(context, 10)),

                      Row(
                        children: [
                          Expanded(
                            child: skeletonBox(
                              height: getHeight(context, 140),
                            ),
                          ),

                          SizedBox(width: getWidth(context, 10)),

                          Expanded(
                            child: skeletonBox(
                              height: getHeight(context, 140),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: getHeight(context, 25)),

                      /// Recent sales container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            skeletonBox(
                              height: getHeight(context, 24),
                              width: getWidth(context, 200),
                            ),

                            SizedBox(height: getHeight(context, 20)),

                            /// Table header
                            skeletonBox(
                              height: getHeight(context, 45),
                              width: double.infinity,
                              radius: 8,
                            ),

                            SizedBox(height: getHeight(context, 15)),

                            /// Table rows
                            ListView.builder(
                              itemCount: 6,

                              shrinkWrap: true,

                              physics:
                                  const NeverScrollableScrollPhysics(),

                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        getHeight(context, 15),
                                  ),

                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: skeletonBox(
                                          height:
                                              getHeight(context, 14),
                                        ),
                                      ),

                                      SizedBox(
                                        width:
                                            getWidth(context, 10),
                                      ),

                                      Expanded(
                                        flex: 2,
                                        child: skeletonBox(
                                          height:
                                              getHeight(context, 14),
                                        ),
                                      ),

                                      SizedBox(
                                        width:
                                            getWidth(context, 10),
                                      ),

                                      Expanded(
                                        flex: 3,
                                        child: skeletonBox(
                                          height:
                                              getHeight(context, 14),
                                        ),
                                      ),

                                      SizedBox(
                                        width:
                                            getWidth(context, 10),
                                      ),

                                      Expanded(
                                        flex: 1,
                                        child: skeletonBox(
                                          height:
                                              getHeight(context, 14),
                                        ),
                                      ),

                                      SizedBox(
                                        width:
                                            getWidth(context, 10),
                                      ),

                                      Expanded(
                                        flex: 2,
                                        child: skeletonBox(
                                          height:
                                              getHeight(context, 14),
                                        ),
                                      ),

                                      SizedBox(
                                        width:
                                            getWidth(context, 10),
                                      ),

                                      Expanded(
                                        flex: 2,
                                        child: skeletonBox(
                                          height:
                                              getHeight(context, 28),
                                          radius: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(context, 100)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}