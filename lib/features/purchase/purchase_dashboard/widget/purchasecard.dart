import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/editbutton.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/statusbadge.dart';

class PurchaseCard extends StatelessWidget {
  final String movementStatus;
  final VoidCallback? onArrivalTap;
  final VoidCallback? onEditTap;
  final bool isLoading;
  final String supplier;
  final String orderId;
  final String dateTime;
  final String bottomId;
  final String items;
  final String itemboxes;

  const PurchaseCard({
    super.key,
    required this.movementStatus,
    this.onArrivalTap,
    this.onEditTap,
    this.isLoading = false,
    required this.supplier,
    required this.orderId,
    required this.dateTime,
    required this.bottomId,
    required this.items,
    required this.itemboxes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 HEADER ROW (EDIT BUTTON)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
             
            ],
          ),

          Text(orderId, style: AppTextStyles.headingText22),
          Text(dateTime, style: AppTextStyles.bodyText16),

          const SizedBox(height: 30),
          Divider(color: Colors.grey.shade300),

          /// 🔹 SUPPLIER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.store_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Text(supplier, style: AppTextStyles.bodyText16),
            ],
          ),

          const SizedBox(height: 10),
          Text(items, style: AppTextStyles.headingText22),
          Text(itemboxes, style: AppTextStyles.bodyText16),

          const SizedBox(height: 50),
          Divider(color: Colors.grey.shade300),

          /// 🔹 FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bottomId, style: AppTextStyles.headingText22),

             GestureDetector(
  onTap: isLoading
      ? null
      : movementStatus == "RECEIVED"
          ? null
          : onArrivalTap,

  child: isLoading
      ? Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        )
      : StatusBadge(
          text: movementStatus == "RECEIVED"
              ? "Received"
              : "Mark as Arrival",

          icon: movementStatus == "RECEIVED"
              ? Icons.check_circle
              : Icons.local_shipping_outlined,

          bgColor: movementStatus == "RECEIVED"
              ? Colors.green
              : Colors.blue,

          textColor: Colors.white,
        ),
)
            ],
          ),
        ],
      ),
    );
  }
}