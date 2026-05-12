import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class RecentSalesCard extends StatelessWidget {
  final List<SaleItem> sales;

  const RecentSalesCard({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Sales Today", style: AppTextStyles.headingText20),
              const Icon(Icons.history, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          if (sales.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No sales recorded today", style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.separated(
              itemCount: sales.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _saleRow(sales[index]),
            ),
        ],
      ),
    );
  }

  Widget _saleRow(SaleItem item) {
    return Row(
      children: [
        // 🔹 Dot
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 12),

        // 🔹 Time
        SizedBox(
          width: 70,
          child: Text(
            item.time,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),

        // 🔹 Quantity
        Expanded(
          child: Text(
            "${item.quantity} Trays",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),

        // 🔹 Customer
        Text(
          item.customer,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}

// 🔹 Model Class
class SaleItem {
  final String time;
  final int quantity;
  final String customer;

  SaleItem({
    required this.time,
    required this.quantity,
    required this.customer,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      time: json['dispatch_date']?.toString().split('T').last.substring(0, 5) ?? "--:--",
      quantity: (json['total_trays'] as num?)?.toInt() ?? 0,
      customer: json['customer_name']?.toString() ?? "Unknown",
    );
  }
}