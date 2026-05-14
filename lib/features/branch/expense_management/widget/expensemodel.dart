import 'package:flutter/material.dart';

class ExpenseModel {
  final String date;
  final String category;
  final String description;
  final String amount;
  final String status;
  final IconData icon;

  ExpenseModel({
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.status,
    required this.icon,
  });
}