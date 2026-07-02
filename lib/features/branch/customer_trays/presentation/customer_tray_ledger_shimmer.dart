import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';

class CustomerTrayLedgerShimmer extends StatelessWidget {
  const CustomerTrayLedgerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                /// Header
                Row(
                  children: [
                    _circle(38),
                    const SizedBox(width: 12),
                    _circle(20),
                    const SizedBox(width: 10),
                    _box(190, 20),
                  ],
                ),

                const SizedBox(height: 10),

                _box(260, 12),

                const SizedBox(height: 20),

                /// Search Field
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Customer & Location
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _box(140, 18),
                                _box(70, 16),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _row(),
                            const SizedBox(height: 10),
                            _row(),
                            const SizedBox(height: 10),
                            _row(),
                            const SizedBox(height: 10),
                            _row(),
                            const SizedBox(height: 10),
                            _row(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _box(80, 14),
        _box(60, 14),
      ],
    );
  }

  static Widget _box(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  static Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}