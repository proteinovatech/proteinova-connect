import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_event.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_state.dart';
import 'package:proteinova_connect/features/admin/expense/data/repository/expense_repository.dart';

class BranchExpenseBloc
    extends Bloc<BranchExpenseEvent, BranchExpenseState> {

  final ExpenseRepository repository;

  BranchExpenseBloc(this.repository)
      : super(const BranchExpenseState()) {

    on<LoadLocationsEvent>(_onLoadLocations);
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<SaveExpenseEvent>(_onSaveExpense);
  }

  Future<void> _onLoadLocations(
    LoadLocationsEvent event,
    Emitter<BranchExpenseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, saveSuccess: false));
    try {
      final locations = await repository.fetchBranches();
      emit(
        state.copyWith(
          isLoading: false,
          branches: locations,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<BranchExpenseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, saveSuccess: false));
    try {
      final data = await repository.fetchBranchExpenses(
  branchId: event.locationId,
  month: event.month,
);

      data.recentExpenses.sort(
        (a, b) => b.expenseDate.compareTo(a.expenseDate),
      );

      emit(
        state.copyWith(
          isLoading: false,
          dashboardData: data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSaveExpense(
    SaveExpenseEvent event,
    Emitter<BranchExpenseState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveSuccess: false));
    try {
      await repository.createBranchExpense(
  branchId: event.locationId,
  expenseDate: event.expenseDate,
  category: event.category,
  amount: event.amount,
  paymentMethod: event.paymentMethod,
  description: event.description,
  status: event.status,
  loginUserId: event.loginUserId,
);

      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          error: e.toString(),
        ),
      );
    }
  }
}