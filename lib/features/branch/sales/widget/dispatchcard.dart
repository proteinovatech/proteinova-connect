import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class DispatchCard extends StatefulWidget {
  final String id;
  final String status;
  final String branch;
  final String vehicle;
  final String driver;
  final String items;
  final IconData firstIcon;
  final IconData secondIcon;

  const DispatchCard({
    super.key,
    required this.id,
    required this.status,
    required this.branch,
    required this.vehicle,
    required this.driver,
    required this.items, required this.firstIcon, required this.secondIcon,
  });

  @override
  State<DispatchCard> createState() => _DispatchCardState();
}

class _DispatchCardState extends State<DispatchCard> {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text("Vehicle/Driver", style: AppTextStyles.bodyText12),
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

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(widget.driver, style: AppTextStyles.bodyText12semibold),
                ),

                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text("Items(Qty)", style: AppTextStyles.bodyText12),
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
      child: Icon(widget.firstIcon, size: 18, color: Colors.grey),
    ),
    const SizedBox(width: 5),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(widget.secondIcon, size: 18, color: Colors.grey),
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
    case "In Transit":
      return Colors.blue;

    case "Pending":
      return Colors.orange;

    case "Delivered":
      return Colors.green;

    default:
      return Colors.orange;
  }
}
}