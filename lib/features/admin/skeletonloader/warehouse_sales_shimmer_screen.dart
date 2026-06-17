import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/admin/Distribution/widget/shimmer_widget.dart';


class WarehouseSalesShimmer extends StatelessWidget {
  const WarehouseSalesShimmer({super.key});

  Widget _card(double height) {
    return Column(
      children: [
        ShimmerWidget(
          height: height,
          borderRadius: BorderRadius.circular(16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1000;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: const Icon(Icons.arrow_back),
        title: const Text("Warehouse Sales"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        _card(220), // Dispatch Info
                        _card(400), // Items
                        _card(200), // Empty Trays
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _card(180), // Summary
                        _card(140), // Payment
                        _card(180), // Overall Dispatch
                        _card(120), // Notes
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _card(220), // Dispatch Info
                  _card(400), // Items
                  _card(200), // Empty Trays
                  _card(140), // Payment
                  _card(180), // Summary
                  _card(180), // Overall Dispatch
                  _card(120), // Notes

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ShimmerWidget(
                          height: 52,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShimmerWidget(
                          height: 52,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
  
}