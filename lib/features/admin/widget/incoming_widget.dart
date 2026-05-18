import 'package:flutter/material.dart';

/// OVERVIEW CARD
Widget buildOverviewCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color iconBg,
  Color iconColor = Colors.black,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ],
      ),
    ),
  );
}

/// FILTER BOX
Widget buildFilterBox({
  required IconData icon,
  required String text,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    ),
  );
}

/// TABLE HEADER
Widget buildTableHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Color(0xffF9FAFB),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: Row(
      children: [
        _headerCell("Purchase Record", 3),
        _headerCell("Supplier Details", 3),
        _headerCell("Product & Quantity", 3),
        _headerCell("Status", 3),
      ],
    ),
  );
}

Widget _headerCell(String text, int flex) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Color(0xff4B5563),
      ),
    ),
  );
}

/// TABLE ROW
Widget buildTableRow({
  required String po,
  required String date,
  required String supplier,
  required String location,
  required String quantity,
  required String type,
  required String status,
  bool isReceive = false,
  VoidCallback? onReceive,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PURCHASE RECORD
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                po,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: Color(0xff6B7280)),
              ),
            ],
          ),
        ),

        /// SUPPLIER DETAILS
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(fontSize: 11, color: Color(0xff6B7280)),
              ),
            ],
          ),
        ),

        /// PRODUCT & QUANTITY
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quantity,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xff111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: const TextStyle(fontSize: 11, color: Color(0xff6B7280)),
              ),
            ],
          ),
        ),

        /// STATUS
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: isReceive
                ? InkWell(
                    onTap: onReceive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Receive Stock",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Color(0xff92400E),
                        ),
                      ),
                    ),
                  )
                : _buildStatusChip(status),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusChip(String status) {
  Color bgColor = const Color(0xffF3F4F6);
  Color textColor = const Color(0xff374151);
  String label = status.toUpperCase();

  if (label == "RECEIVED") {
    bgColor = const Color(0xffDCFCE7);
    textColor = const Color(0xff166534);
  } else if (label == "ARRIVAL" || label == "PURCHASED") {
    bgColor = const Color(0xffDBEAFE);
    textColor = const Color(0xff1E40AF);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label.replaceAll('_', ' '),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 10,
        color: textColor,
      ),
    ),
  );
}
