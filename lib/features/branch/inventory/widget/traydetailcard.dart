import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class TrayDetailsCard extends StatelessWidget {
  final String productGrade;
  final String trayType;
  final String expectedEggs;
  final String damagedEggs;
  final String goodEggs;
  final ValueChanged<String>? onChanged;

  const TrayDetailsCard({
    super.key,
    required this.productGrade,
    required this.trayType,
    required this.expectedEggs,
    required this.damagedEggs,
    required this.goodEggs,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tray Details (Inspection)",
            style: AppTextStyles.bodyText14dark.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  "Product Grade",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Tray Type",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  "Expected",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  "Damaged",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  "Good",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(productGrade, style: const TextStyle(fontSize: 12)),
              ),
              Expanded(
                flex: 2,
                child: Text(trayType, style: const TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: Center(
                  child: Text(expectedEggs, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: Center(
                  child: TextFormField(
                    initialValue: damagedEggs,
                    onChanged: onChanged,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(goodEggs, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 15, color: Colors.orange),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Damaged trays will be excluded from usable stock and logged for audit.",
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}