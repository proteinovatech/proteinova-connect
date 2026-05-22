import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PurchaseDashboardShimmer extends StatelessWidget {
  const PurchaseDashboardShimmer({super.key});

  Widget box({double height = 12, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [

          /// 🔹 HEADER SHIMMER
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              box(height: 35, width: 130),
              const CircleAvatar(radius: 16, backgroundColor: Colors.white),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),

          const SizedBox(height: 20),

          /// 🔹 TITLE SHIMMER
          box(height: 20, width: 150),
          const SizedBox(height: 10),
          box(height: 14, width: 250),

          const SizedBox(height: 20),

          /// 🔹 BUTTON SHIMMER
          Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 SEARCH SHIMMER
          Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          const SizedBox(height: 15),

          /// 🔹 FILTER SHIMMER
          Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔹 LIST SHIMMER
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(height: 14, width: 120),
                      const SizedBox(height: 10),
                      box(height: 12, width: 100),
                      const SizedBox(height: 10),
                      box(height: 12, width: 160),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: box(height: 12)),
                          const SizedBox(width: 10),
                          Expanded(child: box(height: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      box(height: 14, width: 140),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}