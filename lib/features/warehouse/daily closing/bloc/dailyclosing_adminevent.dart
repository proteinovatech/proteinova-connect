abstract class DailyClosingAdminEvent {}

class LoadBranchesEvent extends DailyClosingAdminEvent {}

class SelectBranchEvent extends DailyClosingAdminEvent {
  final int branchId;
  SelectBranchEvent(this.branchId);
}

class SubmitDayClosingEvent extends DailyClosingAdminEvent {
  final int branchId;
  final String status;
  final String notes;
  final double countedCash;

  SubmitDayClosingEvent({
    required this.branchId,
    required this.status,
    required this.notes,
    required this.countedCash,
  });
}
