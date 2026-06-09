import '../data/model/report_model.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final ReportData data;

  ReportLoaded(this.data);
}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);
}
