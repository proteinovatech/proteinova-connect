part of 'daily_closing_bloc.dart';

abstract class DailyClosingState {}

class DailyClosingInitial extends DailyClosingState {}

class DailyClosingLoading extends DailyClosingState {}

class DailyClosingLoaded extends DailyClosingState {
  final DailyClosingModel model;
  DailyClosingLoaded(this.model);
}

class DailyClosingError extends DailyClosingState {
  final String message;
  DailyClosingError(this.message);
}

class DailyClosingSubmitting extends DailyClosingState {}

class DailyClosingSuccess extends DailyClosingState {
  final String message;
  DailyClosingSuccess(this.message);
}
