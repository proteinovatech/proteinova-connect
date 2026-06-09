import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/statusbadge.dart';

class PurchaseCard extends StatelessWidget {
  final String movementStatus;
  final VoidCallback? onArrivalTap;
  final VoidCallback? onEditTap;
  final bool isLoading;
  final String supplier;
  final String orderId;
  final String dateTime;
  final String amount;
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
    required this.amount,
    required this.items,
    required this.itemboxes,
  });

  @override
 Widget build(BuildContext context) {
  return Container(
    margin:  EdgeInsets.only( bottom: getHeight(context, 16)),
    padding:  EdgeInsets.all(getWidth(context, 16)),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular( getWidth(context, 18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Container(
           width: getWidth(context, 52),
           height: getWidth(context, 52),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              orderId, 
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: getWidth(context, 12),
              ),
            ),
          ),
        ),

        SizedBox(width: getWidth(context, 16)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             SizedBox(height: getHeight(context, 12)),    
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Supplier",
                    style: AppTextStyles.bodyText10dark,
                  ),
                  Text(
                    supplier,
                     maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.containerText,
                  ),

                  SizedBox(height: getHeight(context, 12)),

                  Text(
                "Items",
                style: AppTextStyles.bodyText10dark,
              ),
              Text(
               "$items ($itemboxes )",
                style: AppTextStyles.containerText,
              ),

              SizedBox(height: getHeight(context, 12)),

              Text(
            "Amount",
            style: AppTextStyles.bodyText10dark,
          ),
          Text(
            amount,
            style: AppTextStyles.containerText,
          ),
                ],
              ),
    
              SizedBox(height: getHeight(context, 12)),

          Wrap(
            spacing: getWidth(context, 12),
            runSpacing: getHeight(context, 8),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
             Row(
             mainAxisSize: MainAxisSize.min,
             children: [
                 Icon(
                  Icons.access_time_rounded,
                  size: getWidth(context, 16),
                  color: Colors.grey,
                ),

             SizedBox(width: getWidth(context, 6)),
                 Text(
                  dateTime.split('T')[0],
                  style: TextStyle(
                   color: Colors.grey.shade700,
                   fontSize: getWidth(context, 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      
         SizedBox(height: getHeight(context, 12)),
              
               isLoading
        ? SizedBox(
            height: getWidth(context, 20),
            width: getWidth(context, 20),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
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
                ? Colors.green.shade100
                : Colors.blue.shade100,
            textColor:movementStatus == "RECEIVED"
                ? Colors.green
                : Colors.blue,
            onPressed: movementStatus == "RECEIVED"
                ? () {}
                : onArrivalTap,
          ),
            ],
          ),
        ),
  
       SizedBox(width: getHeight(context, 12)),

        Container(
          width: getWidth(context, 35),
          height: getWidth(context, 35),
          decoration: BoxDecoration(
            color: AppColors.amber600,
            borderRadius: BorderRadius.circular( getWidth(context, 14),),
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: getWidth(context, 22),
          ),
        ),
      ],
    ),
  );
}
}