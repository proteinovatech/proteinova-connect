import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

Widget dispatchCard({
  required String id,
  required String date,
  required String branch,
  required String vehicle,
  required String driver,
  required String qty,
  required String status,
  required Color statusColor,
  required BuildContext context,
}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: getHeight(context, 14)),
    padding: EdgeInsets.all(getWidth(context, 16)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TOP HEADER
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.blue,
                size: 22,
              ),
            ),

            SizedBox(width: getWidth(context, 12)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: TextStyle(
                      fontSize: getWidth(context, 15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: getHeight(context, 4)),

                  Text(
                    "Dispatch ID",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: getWidth(context, 11),
                    ),
                  ),
                ],
              ),
            ),

            /// STATUS
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(context, 14),
                vertical: getHeight(context, 7),
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: statusColor,
                  ),
                  SizedBox(width: getWidth(context, 6)),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: getWidth(context, 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: getHeight(context, 18)),

        /// INFO CARDS
        Row(
          children: [
            Expanded(
              child: buildMiniCard(
                context: context,
                icon: Icons.calendar_today_outlined,
                title: "Date",
                value: date,
              ),
            ),

            SizedBox(width: getWidth(context, 10)),

            Expanded(
              child: buildMiniCard(
                context: context,
                icon: Icons.inventory_2_outlined,
                title: "Quantity",
                value: qty,
              ),
            ),
          ],
        ),

        SizedBox(height: getHeight(context, 12)),

        /// BRANCH
        buildFullInfoTile(
          context: context,
          icon: Icons.location_on_outlined,
          title: "Destination Branch",
          value: branch,
        ),

        SizedBox(height: getHeight(context, 12)),

        /// VEHICLE & DRIVER
        buildFullInfoTile(
          context: context,
          icon: Icons.local_shipping_outlined,
          title: "Vehicle",
          value: vehicle,
          subtitle: "Driver : $driver",
        ),
      ],
    ),
  );
}

Widget buildMiniCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: getWidth(context, 12),
      vertical: getHeight(context, 12),
    ),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),

    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.black87,
          ),
        ),

        SizedBox(width: getWidth(context, 10)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: getWidth(context, 10),
                ),
              ),

              SizedBox(height: getHeight(context, 3)),

              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: getWidth(context, 12),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildFullInfoTile({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String value,
  String? subtitle,
}) {
  return Container(
    padding: EdgeInsets.all(getWidth(context, 12)),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),

    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.black87,
          ),
        ),

        SizedBox(width: getWidth(context, 12)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: getWidth(context, 11),
                ),
              ),

              SizedBox(height: getHeight(context, 4)),

              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: getWidth(context, 13),
                ),
              ),

              if (subtitle != null) ...[
                SizedBox(height: getHeight(context, 4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: getWidth(context, 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}