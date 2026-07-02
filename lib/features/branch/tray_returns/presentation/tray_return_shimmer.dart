import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrayReturnShimmer extends StatelessWidget {
  const TrayReturnShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget shimmerBox({
      required double height,
      double width = double.infinity,
      BorderRadius? borderRadius,
    }) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
        ),
      );
    }

    Widget cardShimmer() {
      return Expanded(
        child: shimmerBox(
          height: 120,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),

              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  shimmerBox(height: 40, width: 180),
                  shimmerBox(height: 40, width: 120),
                ],
              ),

              SizedBox(height: size.height * 0.03),

              /// Cards Row 1
              Row(
                children: [
                  cardShimmer(),
                  const SizedBox(width: 12),
                  cardShimmer(),
                ],
              ),

              const SizedBox(height: 16),

              /// Card Row 2
              Row(
                children: [
                  cardShimmer(),
                ],
              ),

              const SizedBox(height: 24),

              /// Button
              shimmerBox(height: 55),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: shimmerBox(height: 24, width: 180),
              ),

              const SizedBox(height: 16),

              /// Table Header
              shimmerBox(height: 50),

              const SizedBox(height: 8),

              /// Table Rows
              ...List.generate(
                6,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: shimmerBox(height: 55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}