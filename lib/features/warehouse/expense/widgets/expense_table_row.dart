import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/expense_model.dart';

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

  String _formatCategory(String category) {
    final upper = category.toUpperCase().replaceAll(' ', '_');
    switch (upper) {
      case 'RENT':
        return 'Rent';
      case 'SALARY':
        return 'Salary';
      case 'ELECTRICITY':
        return 'Electricity';
      case 'MISCELLANEOUS':
        return 'Miscellaneous';
      case 'TRANSPORT':
        return 'Transport';
      case 'PACKING':
        return 'Packing';
      case 'MAINTENANCE':
        return 'Maintenance';
      case 'OTHER_EXPENSES':
        return 'Other Expenses';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountVal = double.tryParse(expense.amount);
    final formattedAmount = amountVal != null ? "₹${amountVal.toStringAsFixed(2)}" : expense.amount;

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
          item(_formatCategory(expense.category), flex: 2),

          /// DESCRIPTION
          item(expense.description.isNotEmpty ? expense.description : '—', flex: 3, align: TextAlign.center),

          /// AMOUNT
          item(
            formattedAmount,
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
