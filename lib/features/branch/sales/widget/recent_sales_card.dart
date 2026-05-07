import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class RecentSalesCard extends StatelessWidget {
  final List<SaleItem> sales;

  const RecentSalesCard({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Sales Today", style: AppTextStyles.headingText20),
          const SizedBox(height: 10),

          ...sales.map((item) => _saleRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _saleRow(SaleItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // 🔹 Dot
          const CircleAvatar(radius: 3, backgroundColor: Colors.grey),

          const SizedBox(width: 10),

          // 🔹 Time
          SizedBox(
            width: 80,
            child: Text(item.time, style: AppTextStyles.bodyText14),
          ),

          // 🔹 Quantity
          Expanded(
            child: Text(
              "${item.quantity} Trays",
              style: AppTextStyles.buttonText16,
            ),
          ),

          // 🔹 Customer
          Text(item.customer, style: AppTextStyles.bodyText14),
        ],
      ),
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
}