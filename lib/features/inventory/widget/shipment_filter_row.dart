import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class ShipmentFilterRow extends StatefulWidget {
  const ShipmentFilterRow({super.key});

  @override
  State<ShipmentFilterRow> createState() => _ShipmentFilterRowState();
}

class _ShipmentFilterRowState extends State<ShipmentFilterRow> {
  @override
void initState() {
  super.initState();
  selectedDate = "Today";
}
  String selectedDate = "Today";
  String selectedSupplier = "All Suppliers";

  
  final List<String> supplierOptions = [
    "All Suppliers",
    "Supplier A",
    "Supplier B"
  ];

 final List<String> dateOptions = ["Today", "Tomorrow", "This Week"];

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: dateOptions.map((date) {
            return ListTile(
              title: Text(date),
              onTap: () {
                setState(() {
                  selectedDate = date; // ✅ update value
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// 🏬 Supplier Bottom Sheet
  void _showSupplierPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: supplierOptions.map((supplier) {
            return ListTile(
              title: Text(
                supplier,
                style: TextStyle(
                  color: selectedSupplier == supplier
                      ? Colors.orange
                      : Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  selectedSupplier = supplier;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// ⚙️ Filter Action
  void _onFilterTap() {
    print("Filter clicked");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          /// 1️⃣ Expected Today
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.containerColor2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Expected: $selectedDate",
                        overflow: TextOverflow.ellipsis,style: AppTextStyles.bodyText14dark,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// 2️⃣ All Suppliers
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _showSupplierPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.containerColor2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        selectedSupplier,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyText14dark,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// 3️⃣ Filter Icon
          GestureDetector(
            onTap: _onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.containerColor2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border2),
              ),
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
    );
  }
}