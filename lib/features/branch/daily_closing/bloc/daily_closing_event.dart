part of 'daily_closing_bloc.dart';

abstract class DailyClosingEvent {}

class FetchDailyClosingData extends DailyClosingEvent {
  final int branchId;
  final String date;

  FetchDailyClosingData({required this.branchId, required this.date});
}

class SubmitDailyClosing extends DailyClosingEvent {
  final int branchId;
  final String date;

  SubmitDailyClosing({required this.branchId, required this.date});
}
