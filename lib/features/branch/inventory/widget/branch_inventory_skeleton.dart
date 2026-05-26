import 'package:flutter/material.dart';

class BranchInventorySkeleton extends StatelessWidget {
  const BranchInventorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 52),

            // Header
            _box(height: 32, width: 260),

            const SizedBox(height: 12),

            _box(height: 16, width: 130),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 24),

            // Title
            _box(height: 34, width: 260),

            const SizedBox(height: 12),

            _box(height: 16),
            const SizedBox(height: 6),
            _box(height: 16, width: 260),

            const SizedBox(height: 28),

            // Metric Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: width >= 1000
                  ? 4
                  : width >= 700
                  ? 2
                  : 2,

              crossAxisSpacing: 16,
              mainAxisSpacing: 16,

              childAspectRatio: 1.2,

              children: List.generate(
                4,
                (_) => _metricCard(),
              ),
            ),

            const SizedBox(height: 28),

            // Search
            Container(
              height: 56,

              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            const SizedBox(height: 20),

            // Shipment Cards
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16),

                child: Container(
                  height: 180,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),

                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      _box(height: 18, width: 180),

                      const SizedBox(height: 14),

                      _box(height: 14),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: _box(
                              height: 16,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _box(
                              height: 16,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 42,

                              decoration:
                                  BoxDecoration(
                                color: const Color(
                                  0xFFF1F5F9,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Container(
                            width: 42,
                            height: 42,

                            decoration:
                                BoxDecoration(
                              color: const Color(
                                0xFFF1F5F9,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                    10,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _metricCard() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(
          16,
        ),

        border: Border.all(
          color: const Color(
            0xFFE2E8F0,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              _box(
                height: 14,
                width: 90,
              ),

              _box(
                height: 28,
                width: 28,
              ),
            ],
          ),

          const Spacer(),

          _box(
            height: 28,
            width: 120,
          ),

          const SizedBox(height: 10),

          _box(
            height: 14,
          ),
        ],
      ),
    );
  }

  static Widget _box({
    required double height,
    double? width,
  }) {
    return Container(
      height: height,
      width: width,

      decoration: BoxDecoration(
        color: const Color(
          0xFFE2E8F0,
        ),

        borderRadius:
            BorderRadius.circular(8),
      ),
    );
  }
}