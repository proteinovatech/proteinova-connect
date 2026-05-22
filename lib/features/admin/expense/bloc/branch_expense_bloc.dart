import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_event.dart';
import 'package:proteinova_connect/features/admin/expense/bloc/branch_expense_state.dart';
import 'package:proteinova_connect/features/admin/expense/data/repository/expense_repository.dart';

class BranchExpenseBloc
    extends Bloc<
        BranchExpenseEvent,
        BranchExpenseState> {

  final ExpenseRepository
      repository;

  BranchExpenseBloc(this.repository)
      : super(
          const BranchExpenseState(),
        ) {

    on<LoadBranchesEvent>(
      _onLoadBranches,
    );

    on<LoadDashboardEvent>(
      _onLoadDashboard,
    );

    on<SaveExpenseEvent>(
      _onSaveExpense,
    );
  }

  /// LOAD BRANCHES
  Future<void> _onLoadBranches(

    LoadBranchesEvent event,

    Emitter<BranchExpenseState>
        emit,

  ) async {

    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    try {

      final branches =
          await repository
              .fetchBranches();

      emit(
        state.copyWith(
          isLoading: false,
          branches: branches,
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

  /// LOAD DASHBOARD
  Future<void> _onLoadDashboard(

    LoadDashboardEvent event,

    Emitter<BranchExpenseState>
        emit,

  ) async {

    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    try {

      final data =
          await repository
              .fetchBranchExpenses(

        branchId: event.branchId,

        month: event.month,
      );

      data.recentExpenses.sort(
        (a, b) =>
            b.expenseDate.compareTo(
              a.expenseDate,
            ),
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

  /// SAVE EXPENSE
  Future<void> _onSaveExpense(

    SaveExpenseEvent event,

    Emitter<BranchExpenseState>
        emit,

  ) async {

    emit(
      state.copyWith(
        isSaving: true,
        saveSuccess: false,
      ),
    );

    try {

      await repository
          .createBranchExpense(

        branchId: event.branchId,

        expenseDate:
            event.expenseDate,

        category: event.category,

        amount: event.amount,

        paymentMethod:
            event.paymentMethod,

        description:
            event.description,

        status: event.status,
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