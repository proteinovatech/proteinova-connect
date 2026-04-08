import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/home/widget/editbutton.dart';
import 'package:proteinova_connect/features/home/widget/statusbadge.dart';

class PurchaseCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final Color textColor;
  final String supplier;

  final String orderId;
  final String dateTime;
  final String bottomId;
final String items;
final String itemboxes;
  const PurchaseCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.textColor,
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
      child: Column(crossAxisAlignment: .start,
        children: [

          /// 🔹 STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StatusBadge(
                text: status,
                bgColor: statusColor,
                textColor: textColor,
              ),
            ],
          ),
 Text(orderId, style: AppTextStyles.heading2),
    Text(dateTime, style: AppTextStyles.body),

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
                child: const Icon(Icons.home, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Text(supplier, style: AppTextStyles.body),
            ],
          ),
          SizedBox(height: 10,),
          Text(items, style: AppTextStyles.heading2),
    Text(itemboxes, style: AppTextStyles.body),


          const SizedBox(height: 50),
          Divider(color: Colors.grey.shade300),

          /// 🔹 EDIT BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(bottomId, style: AppTextStyles.heading2),
              const EditButton(),
            ],
          ),
        ],
      ),
    );
  }
}