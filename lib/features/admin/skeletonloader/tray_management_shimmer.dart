import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrayManagementShimmer extends StatelessWidget {
  const TrayManagementShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: _shimmerBox(width: 140, height: 20),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Buttons
            Row(
              children: [
                Expanded(
                  child: _shimmerBox(
                    height: 55,
                    radius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _shimmerBox(
                    height: 55,
                    radius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Summary Cards
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(
                3,
                (index) => SizedBox(
                  width: isDesktop ? 300 : double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(width: 120, height: 16),
                        const SizedBox(height: 16),
                        _shimmerBox(width: 100, height: 14),
                        const SizedBox(height: 8),
                        _shimmerBox(width: 80, height: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Inventory Details Container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _shimmerBox(
                        width: 150,
                        height: 18,
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  ...List.generate(
                    6,
                    (index) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _shimmerBox(
                                    width: 120,
                                    height: 18,
                                  ),
                                  _shimmerBox(
                                    width: 70,
                                    height: 24,
                                    radius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _inventoryColumn(),
                                  _inventoryColumn(),
                                  _inventoryColumn(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inventoryColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerBox(width: 70, height: 12),
        const SizedBox(height: 6),
        _shimmerBox(width: 50, height: 14),
      ],
    );
  }

  static Widget _shimmerBox({
    required double height,
    double width = double.infinity,
    BorderRadius? radius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}