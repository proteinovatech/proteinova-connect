part of 'expense_bloc.dart';

abstract class ExpenseEvent {}

class FetchExpenses extends ExpenseEvent {
  final int branchId;
  FetchExpenses({required this.branchId});
}

class SubmitExpense extends ExpenseEvent {
  final Map<String, dynamic> data;
  SubmitExpense({required this.data});
}
