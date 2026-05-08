import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class Salesorders extends StatefulWidget {
  final String id;
  final String status;
  final String branch;
  final String vehicle;
  
  final String items;
  final IconData icon;
  

  const Salesorders({
    super.key,
    required this.id,
    required this.status,
    required this.branch,
    required this.vehicle,
   
    required this.items, required this.icon, 
  });

  @override
  State<Salesorders> createState() => _SalesordersState();
}

class _SalesordersState extends State<Salesorders> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.id, style: AppTextStyles.headingText20),

            Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  ),
  decoration: BoxDecoration(
    color: getStatusColor(widget.status), 
    borderRadius: BorderRadius.circular(18),
  ),
  child: Text(
    widget.status,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
    ),
  ),
),
            ],
          ),

          const SizedBox(height: 5),

          Text(widget.branch, style: AppTextStyles.bodyText14),

          const SizedBox(height: 5),

          /// 🔹 Inner container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [

                /// Vehicle Row
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text("Date and Time", style: AppTextStyles.bodyText12),
                    const Spacer(),
                    Text(
                      widget.vehicle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 4, 110, 197),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                               const SizedBox(height: 6),

                /// Items Row
                Row(
                  children: [
                    const Icon(Icons.attach_money_outlined, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text("Total Amount", style: AppTextStyles.bodyText12),
                    const Spacer(),
                    Text(
                      widget.items,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 🔹 Bottom Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
             Row(
  children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(widget.icon, size: 18, color: Colors.grey),
    ),
   
  ],
)
            ],
          ),
        ],
      ),
    );
  }
  Color getStatusColor(String status) {
  switch (status) {
    case "Paid":
      return Colors.green;

    case "Net 30":
      return Colors.orange;

       default:
      return Colors.green;
  }
}
}