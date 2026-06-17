import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminReportDashboardShimmer extends StatelessWidget {
  const AdminReportDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  const _ShimmerBox(height: 40, width: 40),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _ShimmerBox(height: 24),
                  ),
                  const SizedBox(width: 12),
                  _ShimmerBox(
                    height: 40,
                    width: 90,
                    radius: BorderRadius.circular(12),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Filter Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _filterBox(context),
                    _filterBox(context),
                    _filterBox(context),
                    _filterBox(context),

                    const _ShimmerBox(
                      height: 58,
                      width: 150,
                    ),

                    const _ShimmerBox(
                      height: 58,
                      width: 150,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Stats Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (_, __) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(height: 18, width: 100),
                      SizedBox(height: 12),
                      _ShimmerBox(height: 28, width: 120),
                      SizedBox(height: 12),
                      _ShimmerBox(height: 14, width: 60),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const _ShimmerBox(
                  height: 250,
                ),
              ),

              const SizedBox(height: 24),

              /// Top Branches
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _ShimmerBox(
                        height: 22,
                        width: 220,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ...List.generate(
                      4,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: _ShimmerBox(height: 60),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Table
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _ShimmerBox(
                        height: 22,
                        width: 250,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ...List.generate(
                      5,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _ShimmerBox(height: 50),
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

  static Widget _filterBox(BuildContext context) {
    return _ShimmerBox(
      height: 58,
      width: MediaQuery.of(context).size.width * .38,
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? radius;

  const _ShimmerBox({
    required this.height,
    this.width = double.infinity,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}