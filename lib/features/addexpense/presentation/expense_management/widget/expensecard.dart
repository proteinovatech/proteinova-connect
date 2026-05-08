import 'package:flutter/material.dart';
import 'package:proteinova_connect/features/branch/addexpense/presentation/expense_management/widget/expensemodel.dart';
// import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expensemodel.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel item;

  const ExpenseCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Top Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.date, style: const TextStyle(fontSize: 12)),
    
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
    
        const SizedBox(height: 8),
    
        /// Middle Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(item.icon, size: 16),
            ),
            const SizedBox(width: 8),
    
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    
            Text(
              item.amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Divider()
      ],
    );
  }
}