import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdminBranchDashboardShimmer extends StatelessWidget {
  const AdminBranchDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                _box(height: 28, width: 220),
                const SizedBox(height: 8),
                _box(height: 14, width: 160),

                const SizedBox(height: 20),

                /// Branch Dropdown + Button
                Row(
                  children: [
                    Expanded(child: _box(height: 50)),
                    const SizedBox(width: 12),
                    _box(height: 50, width: 120),
                  ],
                ),

                const SizedBox(height: 20),

                /// Stats Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width >= 1000
                        ? 3
                        : (width >= 600 ? 2 : 2),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (_, __) => _statCard(),
                ),

                const SizedBox(height: 24),

                /// Stock Summary Title
                _box(height: 24, width: 180),

                const SizedBox(height: 16),

                /// Stock Summary Cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width >= 1000
                        ? 3
                        : (width >= 600 ? 2 : 1),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 180,
                  ),
                  itemBuilder: (_, __) => _summaryCard(),
                ),

                const SizedBox(height: 24),

                /// Offer + Alert Cards
                _largeCard(),
                const SizedBox(height: 16),
                _largeCard(),

                const SizedBox(height: 24),

                /// Charts
                width >= 850
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _chartCard(height: 320),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _chartCard(height: 320),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _chartCard(height: 280),
                          const SizedBox(height: 16),
                          _chartCard(height: 280),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(height: 42, width: 42),
              const Spacer(),
              _box(height: 16, width: 50),
            ],
          ),
          const Spacer(),
          _box(height: 24, width: 90),
          const SizedBox(height: 8),
          _box(height: 14, width: 120),
          const SizedBox(height: 10),
          _box(height: 12, width: 100),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(height: 18, width: 140),
          const SizedBox(height: 16),
          _box(height: 22, width: 90),
          const SizedBox(height: 12),
          _box(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          _box(height: 14, width: 120),
        ],
      ),
    );
  }

  Widget _largeCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _chartCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}