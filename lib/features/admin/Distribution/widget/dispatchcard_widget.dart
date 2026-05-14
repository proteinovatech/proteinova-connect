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
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
            SizedBox(height: getHeight(context, 8)),
            Text(
              id,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        SizedBox(width: getWidth(context, 10)),

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
                    infoRow(Icons.calendar_today, "Date", date,context,),
                    SizedBox(height: getHeight(context, 8)),
                    infoRow(Icons.location_on, "Destination Branch", branch,context,),
                    SizedBox(height: getHeight(context, 8)),
                    infoRow(
                      Icons.local_shipping,
                      "Vehicle & Driver",
                      vehicle,context,
                      subtitle: driver,
                    ),
                  ],
                ),
              ),

              /// VERTICAL DIVIDER
              Container(
                margin: EdgeInsets.symmetric(horizontal: getWidth(context, 10)),
                width: getWidth(context, 1),
                height: getHeight(context, 120),
                color: Colors.grey.shade200,
              ),

              /// RIGHT STATUS SIDE
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getHeight(context, 6)),
                    infoRow(Icons.inventory_2_outlined, "Total Qty", qty,context,),
                    SizedBox(height: getHeight(context, 10)),
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
                        SizedBox(width: getWidth(context, 6)),
                        const Expanded(
                          child: Text(
                            "Status",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(context, 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(context, 12),
                        vertical: getHeight(context, 7),
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

        //const SizedBox(width: 4),
        /// RIGHT ARROW
        // const Padding(
        //   padding: EdgeInsets.only(top: 45),
        //   child: Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        // ),
      ],
    ),
  );
}

Widget infoRow(IconData icon, String label, String value,BuildContext context, {String? subtitle}) {
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

       SizedBox(width: getWidth(context, 8)),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            SizedBox(height:getHeight(context, 2),),
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
