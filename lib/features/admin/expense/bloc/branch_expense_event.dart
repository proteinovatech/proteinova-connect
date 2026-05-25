abstract class BranchExpenseEvent {}

class LoadLocationsEvent extends BranchExpenseEvent {}

class LoadDashboardEvent extends BranchExpenseEvent {
  final int locationId;
  final String locationType; // 'branch' or 'warehouse'
  final String month;

  LoadDashboardEvent({
    required this.locationId,
    required this.locationType,
    required this.month,
  });
}

class SaveExpenseEvent extends BranchExpenseEvent {
  final int locationId;
  final String locationType; // 'branch' or 'warehouse'
  final String expenseDate;
  final String category;
  final double amount;
  final String paymentMethod;
  final String description;
  final String status;
  final int? loginUserId;

  SaveExpenseEvent({
    required this.locationId,
    required this.locationType,
    required this.expenseDate,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.description,
    required this.status,
    this.loginUserId,
  });
}