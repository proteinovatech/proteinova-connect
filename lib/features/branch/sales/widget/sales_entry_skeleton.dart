import 'package:flutter/material.dart';

class SalesEntrySkeleton extends StatelessWidget {
  const SalesEntrySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: const Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),

        title: const Text(
          "Sales Entry",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// TOP TEXT
            _skeletonBox(
              height: 14,
              width: double.infinity,
            ),

            const SizedBox(height: 8),

            _skeletonBox(
              height: 14,
              width: 220,
            ),

            const SizedBox(height: 20),

            /// DROPDOWN
            Center(
              child: _skeletonBox(
                height: 42,
                width: 160,
                radius: 12,
              ),
            ),

            const SizedBox(height: 20),

            /// TRANSACTION CARD
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _skeletonBox(
                    height: 22,
                    width: 180,
                  ),

                  const SizedBox(height: 20),

                  _buildFieldSkeleton(),
                  const SizedBox(height: 18),

                  _buildFieldSkeleton(),
                  const SizedBox(height: 18),

                  _buildFieldSkeleton(),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// PRODUCT SECTION
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _skeletonBox(
                    height: 22,
                    width: 160,
                  ),

                  const SizedBox(height: 20),

                  _skeletonBox(
                    height: 50,
                    width: double.infinity,
                    radius: 14,
                  ),

                  const SizedBox(height: 16),

                  ListView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),

                        child: _skeletonBox(
                          height: 55,
                          width: double.infinity,
                          radius: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// PAYMENT SUMMARY
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _skeletonBox(
                    height: 22,
                    width: 180,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,

                    children: [
                      _skeletonBox(
                        height: 18,
                        width: 80,
                      ),

                      _skeletonBox(
                        height: 18,
                        width: 80,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _summaryRow(),
                  const SizedBox(height: 16),

                  _summaryRow(),
                  const SizedBox(height: 16),

                  _summaryRow(),
                  const SizedBox(height: 25),

                  _skeletonBox(
                    height: 52,
                    width: double.infinity,
                    radius: 14,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  Widget _buildFieldSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _skeletonBox(
          height: 14,
          width: 120,
        ),

        const SizedBox(height: 10),

        _skeletonBox(
          height: 55,
          width: double.infinity,
          radius: 14,
        ),
      ],
    );
  }

  Widget _summaryRow() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        _skeletonBox(
          height: 16,
          width: 120,
        ),

        _skeletonBox(
          height: 16,
          width: 80,
        ),
      ],
    );
  }

  Widget _skeletonBox({
    required double height,
    required double width,
    double radius = 8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,

      builder: (context, value, child) {
        return Opacity(
          opacity: value,

          child: Container(
            height: height,
            width: width,

            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },

      onEnd: () {},
    );
  }
}