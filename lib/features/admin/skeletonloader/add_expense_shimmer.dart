import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AddExpenseShimmer extends StatelessWidget {
  const AddExpenseShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xffF8F9FE),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.transparent),
        title: _shimmerBox(height: 20, width: 140),
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldShimmer(),
                  const SizedBox(height: 20),

                  _fieldShimmer(),
                  const SizedBox(height: 20),

                  _fieldShimmer(),
                  const SizedBox(height: 20),

                  _fieldShimmer(),
                  const SizedBox(height: 20),

                  _label(),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(child: _optionButton()),
                      const SizedBox(width: 10),
                      Expanded(child: _optionButton()),
                      const SizedBox(width: 10),
                      Expanded(child: _optionButton()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _label(),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(child: _optionButton()),
                      const SizedBox(width: 10),
                      Expanded(child: _optionButton()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _label(),
                  const SizedBox(height: 8),

                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }

  Widget _label() {
    return _shimmerBox(
      height: 14,
      width: 120,
    );
  }

  Widget _optionButton() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    required double width,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}