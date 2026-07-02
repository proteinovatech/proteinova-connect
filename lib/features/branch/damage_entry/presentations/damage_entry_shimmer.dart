import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DamageEntryShimmer extends StatelessWidget {
  const DamageEntryShimmer({super.key});

  Widget shimmerBox({
    double width = double.infinity,
    double height = 16,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Back Button
              Row(
                children: [
                  shimmerBox(width: 20, height: 20, radius: 20),
                  const SizedBox(width: 8),
                  shimmerBox(width: 130),
                ],
              ),

              const SizedBox(height: 25),

              /// Title
              Row(
                children: [
                  shimmerBox(width: 28, height: 28, radius: 20),
                  const SizedBox(width: 10),
                  shimmerBox(width: 220, height: 24),
                ],
              ),

              const SizedBox(height: 10),

              shimmerBox(height: 14),
              const SizedBox(height: 6),
              shimmerBox(width: 280, height: 14),

              const SizedBox(height: 25),

              //--------------------------------------
              // FORM CARD
              //--------------------------------------

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    shimmerBox(width: 170, height: 22),

                    const SizedBox(height: 15),

                    shimmerBox(height: 1),

                    const SizedBox(height: 20),

                    shimmerBox(width: 120),

                    const SizedBox(height: 10),

                    shimmerBox(height: 48),

                    const SizedBox(height: 20),

                    shimmerBox(width: 180),

                    const SizedBox(height: 10),

                    shimmerBox(height: 50),

                    const SizedBox(height: 10),

                    shimmerBox(width: 170, height: 12),

                    const SizedBox(height: 25),

                    shimmerBox(height: 48),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------
              // HISTORY CARD
              //--------------------------------------

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    shimmerBox(width: 160, height: 22),

                    const SizedBox(height: 15),

                    shimmerBox(height: 1),

                    const SizedBox(height: 20),

                    /// Table Header
                    Row(
                      children: [
                        Expanded(child: shimmerBox(height: 18)),
                        const SizedBox(width: 10),
                        Expanded(child: shimmerBox(height: 18)),
                        const SizedBox(width: 10),
                        Expanded(child: shimmerBox(height: 18)),
                        const SizedBox(width: 10),
                        Expanded(child: shimmerBox(height: 18)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    ...List.generate(
                      6,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Row(
                          children: [

                            Expanded(child: shimmerBox(height: 16)),

                            const SizedBox(width: 10),

                            Expanded(child: shimmerBox(height: 16)),

                            const SizedBox(width: 10),

                            Expanded(child: shimmerBox(height: 16)),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: shimmerBox(
                                  width: 80,
                                  height: 28,
                                  radius: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}