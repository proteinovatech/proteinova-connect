import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AddBranchShimmer extends StatelessWidget {
  const AddBranchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    _box(40, 40, radius: 10),
                    const SizedBox(width: 16),
                    _box(24, 180),
                  ],
                ),
              ),

              Container(
                height: 1,
                color: Colors.white,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _sectionCard(),
                      const SizedBox(height: 16),

                      _sectionCard(),
                      const SizedBox(height: 16),

                      _sectionCard(
                        textArea: true,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _box(54, double.infinity, radius: 12),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _box(54, double.infinity, radius: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({bool textArea = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(20, 180),
          const SizedBox(height: 20),

          _field(),
          const SizedBox(height: 14),

          _field(),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _field()),
              const SizedBox(width: 12),
              Expanded(child: _field()),
            ],
          ),

          if (textArea) ...[
            const SizedBox(height: 14),
            _box(100, double.infinity, radius: 12),
          ],
        ],
      ),
    );
  }

  Widget _field() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(14, 100),
        const SizedBox(height: 8),
        _box(52, double.infinity, radius: 12),
      ],
    );
  }

  Widget _box(
    double height,
    double width, {
    double radius = 8,
  }) {
    return Container(
      height: height,
      width: width == double.infinity ? null : width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}