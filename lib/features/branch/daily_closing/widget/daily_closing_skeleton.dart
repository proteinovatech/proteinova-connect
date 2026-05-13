import 'package:flutter/material.dart';

class DailyClosingSkeleton extends StatefulWidget {
  const DailyClosingSkeleton({super.key});

  @override
  State<DailyClosingSkeleton> createState() =>
      _DailyClosingSkeletonState();
}

class _DailyClosingSkeletonState
    extends State<DailyClosingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget skeletonBox({
    double height = 16,
    double width = double.infinity,
    double radius = 10,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: child,
    );
  }

  Widget infoCard() {
    return Expanded(
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            skeletonBox(height: 14, width: 70),
            const Spacer(),
            skeletonBox(height: 20, width: 90),
          ],
        ),
      ),
    );
  }

  Widget stockItem() {
    return Expanded(
      child: Column(
        children: [
          skeletonBox(height: 12, width: 80),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: skeletonBox(
                height: 18,
                width: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          skeletonBox(height: 14, width: 120),
          skeletonBox(height: 14, width: 70),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              skeletonBox(
                height: 28,
                width: 180,
              ),

              const SizedBox(height: 12),

              skeletonBox(
                height: 14,
                width: double.infinity,
              ),

              const SizedBox(height: 6),

              skeletonBox(
                height: 14,
                width: 250,
              ),

              const SizedBox(height: 20),

              /// STOCK SUMMARY
              sectionCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        skeletonBox(
                          height: 22,
                          width: 150,
                        ),
                        skeletonBox(
                          height: 24,
                          width: 24,
                          radius: 50,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    for (int i = 0; i < 3; i++) ...[
                      skeletonBox(
                        height: 16,
                        width: 180,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          stockItem(),
                          const SizedBox(width: 10),
                          stockItem(),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          stockItem(),
                          const SizedBox(width: 10),
                          stockItem(),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),

              /// SALES SUMMARY
              sectionCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    skeletonBox(
                      height: 22,
                      width: 160,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        infoCard(),
                        const SizedBox(width: 10),
                        infoCard(),
                        const SizedBox(width: 10),
                        infoCard(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    skeletonBox(
                      height: 1,
                      width: double.infinity,
                    ),

                    const SizedBox(height: 20),

                    skeletonBox(
                      height: 22,
                      width: 180,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        infoCard(),
                        const SizedBox(width: 10),
                        infoCard(),
                        const SizedBox(width: 10),
                        infoCard(),
                      ],
                    ),
                  ],
                ),
              ),

              /// CASH SUMMARY
              sectionCard(
                child: Column(
                  children: List.generate(
                    10,
                    (index) => summaryRow(),
                  ),
                ),
              ),

              /// CLOSING STOCK
              sectionCard(
                child: Column(
                  children: List.generate(
                    6,
                    (index) => summaryRow(),
                  ),
                ),
              ),

              /// TODAY SUMMARY
              sectionCard(
                child: Column(
                  children: List.generate(
                    6,
                    (index) => summaryRow(),
                  ),
                ),
              ),

              /// CHECKLIST
              sectionCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    skeletonBox(
                      height: 22,
                      width: 120,
                    ),

                    const SizedBox(height: 20),

                    for (int i = 0; i < 3; i++) ...[
                      Row(
                        children: [
                          skeletonBox(
                            height: 22,
                            width: 22,
                            radius: 6,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: skeletonBox(
                              height: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: skeletonBox(
                      height: 50,
                      radius: 12,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: skeletonBox(
                      height: 50,
                      radius: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}