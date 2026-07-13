import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SalesDashboardShimmer extends StatelessWidget {
  const SalesDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Buttons
          Row(
            children: [
              Expanded(child: _buttonShimmer()),
              const SizedBox(width: 12),
              Expanded(child: _buttonShimmer()),
            ],
          ),

          const SizedBox(height: 24),

          /// Title
          _line(width: 180, height: 24),

          const SizedBox(height: 8),

          _line(width: 240),

          const SizedBox(height: 24),

          /// Revenue Card
          _largeCard(),

          const SizedBox(height: 16),

          /// Orders & Eggs
          Row(
            children: [
              Expanded(child: _smallCard()),
              const SizedBox(width: 12),
              Expanded(child: _smallCard()),
            ],
          ),

          const SizedBox(height: 30),

          /// Recent Sales Title
          _line(width: 150, height: 22),

          const SizedBox(height: 16),

          /// Table Container
          _tableShimmer(),
        ],
      ),
    );
  }

  Widget _buttonShimmer() {
    return _box(
      height: 48,
      radius: 12,
    );
  }

  Widget _largeCard() {
    return _box(
      height: 120,
      radius: 18,
    );
  }

  Widget _smallCard() {
    return _box(
      height: 110,
      radius: 18,
    );
  }

  Widget _tableShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          /// Filters
          Row(
            children: [
              Expanded(child: _box(height: 45, radius: 10)),
              const SizedBox(width: 12),
              Expanded(child: _box(height: 45, radius: 10)),
            ],
          ),

          const SizedBox(height: 20),

          /// Header
          Row(
            children: List.generate(
              6,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _line(width: double.infinity),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: List.generate(
                  6,
                  (_) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _line(width: double.infinity),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line({
    double width = double.infinity,
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

  Widget _box({
    required double height,
    required double radius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}