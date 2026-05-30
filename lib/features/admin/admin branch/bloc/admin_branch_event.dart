abstract class AdminBranchEvent {}

class LoadAdminBranchDashboardEvent extends AdminBranchEvent {
  final int? branchId;
  LoadAdminBranchDashboardEvent({this.branchId});
}

class SelectBranchEvent extends AdminBranchEvent {
  final int branchId;
  SelectBranchEvent(this.branchId);
}

class RefreshAdminBranchDashboardEvent extends AdminBranchEvent {
  final int? branchId;
  RefreshAdminBranchDashboardEvent({this.branchId});
}
