import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LedgerShimmer extends StatelessWidget {
  const LedgerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 24),

            /// Summary Cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(
                5,
                (index) => SizedBox(
                  width: MediaQuery.of(context).size.width > 700
                      ? (MediaQuery.of(context).size.width - 56) / 2
                      : double.infinity,
                  child: _summaryCard(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Filter Card
            _filterCard(),

            const SizedBox(height: 24),

            /// Table
            _tableCard(),
          ],
        ),
      ),
    );
  }

 Widget _header(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 768;

  if (isMobile) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(width: double.infinity, height: 28),
              const SizedBox(height: 10),
              _box(width: 180, height: 16),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _box(width: 110, height: 48),
      ],
    );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 250, height: 28),
          const SizedBox(height: 10),
          _box(width: 320, height: 16),
        ],
      ),
      _box(width: 120, height: 48),
    ],
  );
}
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _box(width: 48, height: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 100, height: 12),
                const SizedBox(height: 12),
                _box(width: 80, height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _filterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _box(height: 52),
          const SizedBox(height: 16),
          _box(height: 52),
          const SizedBox(height: 16),
          _box(height: 52),
          const SizedBox(height: 16),
          _box(height: 50),
        ],
      ),
    );
  }

  Widget _tableCard() {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _box(width: 220, height: 22),
            ),
            const SizedBox(height: 20),

            /// Header
            Row(
              children: List.generate(
                7,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _box(height: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, __) {
                  return Row(
                    children: List.generate(
                      7,
                      (_) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _box(height: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({
    double width = double.infinity,
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
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}