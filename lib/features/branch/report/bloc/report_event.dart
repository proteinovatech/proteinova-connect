abstract class ReportEvent {}

class FetchBranchReportEvent extends ReportEvent {
  final int branchId;
  final String? startDate;
  final String? endDate;

  FetchBranchReportEvent({
    required this.branchId,
    this.startDate,
    this.endDate,
  });
}
