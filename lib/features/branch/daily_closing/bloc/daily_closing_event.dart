part of 'daily_closing_bloc.dart';

abstract class DailyClosingEvent {}

class FetchDailyClosingData extends DailyClosingEvent {
  final int branchId;
  final String date;

  FetchDailyClosingData({required this.branchId, required this.date});
}

class SubmitDailyClosing extends DailyClosingEvent {
  final int branchId;
  final String status;
  final String notes;
  final double countedCash;

  SubmitDailyClosing({
    required this.branchId,
    required this.status,
    required this.notes,
    required this.countedCash,
  });
}
