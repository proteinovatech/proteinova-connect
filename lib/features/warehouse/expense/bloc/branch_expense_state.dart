import 'package:proteinova_connect/features/admin/expense/data/models/branch_expense_dashboard_model.dart';

class BranchExpenseState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool saveSuccess;

  final Map<int, String> branches;

  final BranchExpenseDashboardModel? dashboardData;

  const BranchExpenseState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.saveSuccess = false,

    this.branches = const {},

    this.dashboardData,
  });

  BranchExpenseState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? saveSuccess,

    Map<int, String>? branches,

    BranchExpenseDashboardModel? dashboardData,
  }) {
    return BranchExpenseState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      saveSuccess: saveSuccess ?? this.saveSuccess,

      branches: branches ?? this.branches,

      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}