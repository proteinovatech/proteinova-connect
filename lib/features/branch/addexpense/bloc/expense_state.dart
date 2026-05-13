part of 'expense_bloc.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  
  final List<ExpenseModel> expenses;
  

  ExpenseLoaded(this.expenses);
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}

class ExpenseSubmitting extends ExpenseState {}

class ExpenseSubmitSuccess extends ExpenseState {
  final String message;
  ExpenseSubmitSuccess(this.message);
}
