part of 'receiving_branch_bloc.dart';

abstract class ReceivingBranchState {}

class ReceivingBranchInitial extends ReceivingBranchState {}

class ReceivingBranchLoading extends ReceivingBranchState {}

class ReceivingBranchDashboardLoaded extends ReceivingBranchState {
  final List<BranchModel> branches;
  final int selectedBranchId;
  final ReceivingDashboardData dashboardData;

  ReceivingBranchDashboardLoaded({
    required this.branches,
    required this.selectedBranchId,
    required this.dashboardData,
  });
}

class MarkArrivalInProgress extends ReceivingBranchState {
  final List<BranchModel> branches;
  final int selectedBranchId;
  final ReceivingDashboardData dashboardData;
  final int actionDispatchId;

  MarkArrivalInProgress({
    required this.branches,
    required this.selectedBranchId,
    required this.dashboardData,
    required this.actionDispatchId,
  });
}

class DispatchDetailsLoading extends ReceivingBranchState {
  final List<BranchModel> branches;
  final int selectedBranchId;
  final ReceivingDashboardData dashboardData;

  DispatchDetailsLoading({
    required this.branches,
    required this.selectedBranchId,
    required this.dashboardData,
  });
}

class DispatchDetailsLoaded extends ReceivingBranchState {
  final List<BranchModel> branches;
  final int selectedBranchId;
  final ReceivingDashboardData dashboardData;
  final DispatchDetails dispatchDetails;

  DispatchDetailsLoaded({
    required this.branches,
    required this.selectedBranchId,
    required this.dashboardData,
    required this.dispatchDetails,
  });
}

class ConfirmReceiveInProgress extends ReceivingBranchState {
  final List<BranchModel> branches;
  final int selectedBranchId;
  final ReceivingDashboardData dashboardData;
  final DispatchDetails dispatchDetails;

  ConfirmReceiveInProgress({
    required this.branches,
    required this.selectedBranchId,
    required this.dashboardData,
    required this.dispatchDetails,
  });
}

class ConfirmReceiveSuccess extends ReceivingBranchState {
  final String message;

  ConfirmReceiveSuccess(this.message);
}

class ReceivingBranchError extends ReceivingBranchState {
  final String message;
  final List<BranchModel> branches;
  final int? selectedBranchId;
  final ReceivingDashboardData? dashboardData;

  ReceivingBranchError({
    required this.message,
    this.branches = const [],
    this.selectedBranchId,
    this.dashboardData,
  });
}
