import 'package:flutter/material.dart';
// import 'package:proteinova_connect/features/addexpense/presentation/expense_management/widget/expensemodel.dart';
import 'package:proteinova_connect/features/branch/addexpense/presentation/expense_management/widget/expensemodel.dart';

final List<ExpenseModel> expenses = [
  ExpenseModel(
    date: "11 Apr 2025",
    category: "Transport",
    description: "Transport for stock",
    amount: "500",
    status: "Paid",
    icon: Icons.local_shipping,
  ),
  ExpenseModel(
    date: "11 Apr 2025",
    category: "Electricity",
    description: "Shop EB Bill",
    amount: "1,200",
    status: "Paid",
    icon: Icons.flash_on,
  ),
  ExpenseModel(
    date: "10 Apr 2025",
    category: "Salary",
    description: "Helper Salary",
    amount: "1,500",
    status: "Paid",
    icon: Icons.person,
  ),
  ExpenseModel(
    date: "10 Apr 2025",
    category: "Packing",
    description: "Tray & Box",
    amount: "350",
    status: "Paid",
    icon: Icons.inventory,
  ),
  ExpenseModel(
    date: "09 Apr 2025",
    category: "Rent",
    description: "Shop Rent",
    amount: "5000",
    status: "Paid",
    icon: Icons.home,
  ),

  ExpenseModel(
    date: "09 Apr 2025",
    category: "Maintenance",
    description: "Fan Repair",
    amount: "600",
    status: "Paid",
    icon: Icons.build,
  ),
];
