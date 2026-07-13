import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReceivingDashboardShimmer extends StatelessWidget {
  const ReceivingDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [

                    _circle(20),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _line(
                        width: double.infinity,
                        height: 18,
                      ),
                    ),

                    const SizedBox(width: 12),

                    _box(
                      width: 120,
                      height: 38,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Receiving badge
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _box(
                    width: 110,
                    height: 34,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Metric Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (_, __) {
                    return _box(
                      width: double.infinity,
                      height: 120,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// Incoming Dispatches Container
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    Align(
                      alignment: Alignment.centerLeft,
                      child: _line(
                        width: 180,
                        height: 18,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ...List.generate(
                      6,
                      (index) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 18),
                        child: Row(
                          children: [

                            _circle(46),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  _line(width: 160),

                                  const SizedBox(height: 8),

                                  _line(width: 120),

                                  const SizedBox(height: 8),

                                  _line(width: 90),
                                ],
                              ),
                            ),

                            _box(
                              width: 70,
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _line({
    required double width,
    double height = 14,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _circle(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}