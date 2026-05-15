import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SupplierShimmer extends StatelessWidget {
  const SupplierShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor:
              Colors.grey.shade100,
          child: Container(
            margin:
                const EdgeInsets.symmetric(
              vertical: 8,
            ),

            padding:
                const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                /// STATUS
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 24,
                      width: 80,
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// COMPANY NAME
                Container(
                  height: 20,
                  width: 180,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                /// ID
                Container(
                  height: 14,
                  width: 100,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                /// LOCATION
                Container(
                  height: 14,
                  width: 220,
                  color: Colors.white,
                ),

                const SizedBox(height: 20),

                Container(
                  height: 1,
                  color: Colors.white,
                ),

                const SizedBox(height: 20),

                /// CONTACT
                Row(
                  children: [

                    Container(
                      height: 40,
                      width: 40,
                      decoration:
                          const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      height: 16,
                      width: 140,
                      color: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// PHONE
                Container(
                  height: 20,
                  width: 160,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                /// EMAIL
                Container(
                  height: 14,
                  width: 220,
                  color: Colors.white,
                ),

                const SizedBox(height: 20),

                /// BOTTOM BOX
                Container(
                  padding:
                      const EdgeInsets.all(10),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Container(
                            height: 16,
                            width: 120,
                            color:
                                Colors.white,
                          ),

                          const SizedBox(
                              height: 8),

                          Container(
                            height: 14,
                            width: 80,
                            color:
                                Colors.white,
                          ),
                        ],
                      ),

                      Container(
                        height: 36,
                        width: 70,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                  8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}