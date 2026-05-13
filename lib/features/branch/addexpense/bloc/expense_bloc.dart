import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/addexpense/data/model/expense_model.dart';
import 'package:proteinova_connect/features/branch/addexpense/data/repository/expense_repository.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;

  ExpenseBloc({required this.repository}) : super(ExpenseInitial()) {
    on<FetchExpenses>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenses = await repository.fetchExpenses(event.branchId);
        emit(ExpenseLoaded(expenses));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<SubmitExpense>((event, emit) async {
      emit(ExpenseSubmitting());
      try {
        final result = await repository.submitExpense(event.data);
        emit(ExpenseSubmitSuccess(result['message'] ?? "Expense saved successfully"));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }
}
