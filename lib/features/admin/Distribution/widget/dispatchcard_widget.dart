import 'package:flutter/material.dart';

Widget dispatchCard({
  required String id,
  required String date,
  required String branch,
  required String vehicle,
  required String driver,
  required String qty,
  required String status,
  required Color statusColor,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT SIDE
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              id,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(width: 14),

        /// CENTER & RIGHT DETAILS
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// DETAILS COLUMN
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow(Icons.calendar_today, "Date", date),
                    const SizedBox(height: 12),
                    infoRow(Icons.location_on, "Destination Branch", branch),
                    const SizedBox(height: 12),
                    infoRow(
                      Icons.local_shipping,
                      "Vehicle & Driver",
                      vehicle,
                      subtitle: driver,
                    ),
                  ],
                ),
              ),

              /// VERTICAL DIVIDER
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 1,
                height: 100,
                color: Colors.grey.shade200,
              ),

              /// RIGHT STATUS SIDE
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow(Icons.inventory_2_outlined, "Total Qty", qty),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.radio_button_checked,
                            size: 14,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Status",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 4),

        /// RIGHT ARROW
        const Padding(
          padding: EdgeInsets.only(top: 45),
          child: Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ),
      ],
    ),
  );
}

Widget infoRow(IconData icon, String label, String value, {String? subtitle}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 14),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
