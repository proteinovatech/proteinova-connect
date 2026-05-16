import 'package:flutter/material.dart';

import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'dispatch_bottomsheet.dart';

Widget statCard({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String count,
  required String subtitle,
  List<dynamic>? data,
}) {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,

        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.45,
            maxChildSize: 0.95,

            builder: (context, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),

                child: SingleChildScrollView(
                  controller: controller,

                  child: dispatchBottomSheet(context, title: title, data: data),
                ),
              );
            },
          );
        },
      );
    },

    child: Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.10),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),

          SizedBox(height: getHeight(context, 12)),

          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: getHeight(context, 10)),

          Text(
            count,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: getHeight(context, 6)),

          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

/// PAGE BUTTON
Widget pageButton(IconData icon) {
  return Container(
    height: 38,
    width: 38,

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(10),

      border: Border.all(color: Colors.grey.shade300),
    ),

    child: Icon(icon, color: Colors.grey),
  );
}
