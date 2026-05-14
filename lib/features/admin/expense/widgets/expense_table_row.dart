import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';

import '../models/expense_model.dart';

class ExpenseTableRow extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseTableRow({super.key, required this.expense});

  Widget item(
    String text, {
    int flex = 1,
    TextAlign align = TextAlign.left,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return Expanded(
      flex: flex,

      child: Text(
        text,

        textAlign: align,

        maxLines: 2,

        overflow: TextOverflow.ellipsis,

        style: TextStyle(
          fontSize: 13,
          fontWeight: fontWeight,
          color: const Color(0xff374151),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(context, 14),
        vertical: getHeight(context, 14),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// DATE
          item(expense.expenseDate, flex: 2),

          /// CATEGORY
          item(expense.category, flex: 2),

          /// DESCRIPTION
          item(expense.description, flex: 3, align: TextAlign.center),

          /// AMOUNT
          item(
            expense.amount,
            flex: 2,
            align: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),

          /// STATUS
          item(
            expense.status,
            flex: 2,
            align: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
