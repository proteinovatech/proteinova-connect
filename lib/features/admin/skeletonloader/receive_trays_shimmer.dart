import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReceiveTraysShimmer extends StatelessWidget {
  const ReceiveTraysShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.grey),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(width: 180, height: 22),
            const SizedBox(height: 6),
            _shimmerBox(width: 280, height: 12),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _leftPanel(),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _rightPanel(),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _leftPanel(),
                const SizedBox(height: 24),
                _rightPanel(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _leftPanel() {
    return Column(
      children: [
        _card(),
        const SizedBox(height: 16),
        _card(),
        const SizedBox(height: 16),
        _card(),
      ],
    );
  }

  Widget _rightPanel() {
    return Column(
      children: [
        _tableHeader(),
        const SizedBox(height: 12),

        ...List.generate(
          8,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _tableRow(),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _shimmerBox(height: 16)),
          const SizedBox(width: 16),
          Expanded(child: _shimmerBox(height: 16)),
          const SizedBox(width: 16),
          Expanded(child: _shimmerBox(height: 16)),
        ],
      ),
    );
  }

  Widget _tableRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 120, height: 14),
                const SizedBox(height: 8),
                _shimmerBox(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _shimmerBox(height: 14)),
          const SizedBox(width: 16),
          Expanded(child: _shimmerBox(height: 14)),
        ],
      ),
    );
  }

  Widget _card() {
    return Container(
      width: double.infinity,
     
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 150, height: 18),
          const SizedBox(height: 16),
          _shimmerBox(height: 14),
          const SizedBox(height: 10),
          _shimmerBox(height: 14),
          const SizedBox(height: 10),
          _shimmerBox(width: 100, height: 14),
        ],
      ),
    );
  }

  static Widget _shimmerBox({
    required double height,
    double width = double.infinity,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}