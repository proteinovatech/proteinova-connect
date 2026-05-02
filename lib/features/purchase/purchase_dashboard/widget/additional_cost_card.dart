import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';

class AdditionalCostCard extends StatefulWidget {
  final TextEditingController loadingController;
  final TextEditingController unloadingController;
  final TextEditingController transportController;
  final TextEditingController miscController;

  const AdditionalCostCard({
    super.key,
    required this.loadingController,
    required this.unloadingController,
    required this.transportController,
    required this.miscController,
  });

  @override
  State<AdditionalCostCard> createState() => _AdditionalCostCardState();
}

class _AdditionalCostCardState extends State<AdditionalCostCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 HEADER (same style as product card)
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    color: AppColors.blueAccent),
                SizedBox(width: size.width * 0.02),
                const Expanded(
                  child: Text(
                    "Additional Costs",
                    style: AppTextStyles.headingText20,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 10),
              buildAdditionalCosts()
           
          ],
        ],
      ),
    );
  }

  Widget buildAdditionalCosts() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Additional Costs",
          style:AppTextStyles.buttonText16,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _costField("Loading Charges",widget.loadingController),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _costField("Unloading", widget.unloadingController),
            ),
            
            ]),
            const SizedBox(width: 10),
            Row(
              children: [
                Expanded(
                  child: _costField("Transport", widget.transportController),
                ),
             
            const SizedBox(width: 10),
            Expanded(
              child: _costField("Misc Expenses", widget.miscController),
            ),
             ],
            ),
         
      ],
    ),
  );
}
Widget _costField(String title, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: AppTextStyles.bodyText14,
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
      color: AppColors.background1,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
        child: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: "Enter amount",
            prefixText: "₹ ",
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ],
  );
}}