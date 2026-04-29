import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_item.dart';
import 'package:proteinova_connect/features/daily_closing/widget/summary_row.dart';

class SummaryBlock extends StatefulWidget {
  final String heading;
  final List<SummaryItem> items;

  const SummaryBlock({
    super.key,
    required this.heading,
    required this.items,
  });

  @override
  State<SummaryBlock> createState() =>
      _ExpandableSummaryBlockState();
}

class _ExpandableSummaryBlockState extends State<SummaryBlock> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
               Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.heading, style: AppTextStyles.buttonText16),
            IconButton(
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ],
        ),

             if (isExpanded) ...[
          const SizedBox(height: 8),
          const Divider(),

          ...widget.items
              .map((item) => summaryRow(item.title, item.amount)),

          const Divider(),
        ],
      ],
    );
  }
}