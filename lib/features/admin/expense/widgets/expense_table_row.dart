import 'package:flutter/material.dart';

import '../models/expense_model.dart';

class ExpenseTableRow extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseTableRow({
    super.key,
    required this.expense,
  });

  Widget item(String text) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          item(expense.date),
          item(expense.category),
          item(expense.description),
          item(expense.amount),
          item(expense.status),
        ],
      ),
    );
  }
}