import 'package:flutter/material.dart';

/// NUMBER BOX
Widget numberBox(String value) {
  return Container(
    height: 48,

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),

      border: Border.all(color: Colors.grey.shade300),
    ),

    child: Center(
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

/// TRAY CARD
Widget trayCard({
  required Color iconColor,
  required String title,
  required String subtitle,
  required String desc,
  required String extra,
  required TextEditingController controller,
  VoidCallback? onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: iconColor.withOpacity(0.04),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: iconColor.withOpacity(0.15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: " $subtitle",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        if (extra.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.10),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Non - Returnable",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Trays", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: 70,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (_) => onChanged?.call(),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// SUMMARY ROW
Widget summaryRow(String title, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14),

    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
    ),

    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
