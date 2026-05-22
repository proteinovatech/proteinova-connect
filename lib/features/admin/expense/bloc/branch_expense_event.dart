abstract class BranchExpenseEvent {}

class LoadBranchesEvent
    extends BranchExpenseEvent {}

class LoadDashboardEvent
    extends BranchExpenseEvent {

  final int branchId;
  final String month;

  LoadDashboardEvent({
    required this.branchId,
    required this.month,
  });
}

class SaveExpenseEvent
    extends BranchExpenseEvent {

  final int branchId;
  final String expenseDate;
  final String category;
  final double amount;
  final String paymentMethod;
  final String description;
  final String status;

  SaveExpenseEvent({
    required this.branchId,
    required this.expenseDate,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.description,
    required this.status,
  });
}