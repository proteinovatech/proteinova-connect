part of 'tray_return_bloc.dart';

abstract class TrayReturnState {}

class TrayReturnInitial extends TrayReturnState {}

class TrayReturnLoading extends TrayReturnState {}

class TrayReturnLoaded extends TrayReturnState {
  final TrayReturnModel model;
  final List<dynamic> warehouses;
  TrayReturnLoaded(this.model, {this.warehouses = const []});
}

class TrayReturnError extends TrayReturnState {
  final String message;
  TrayReturnError(this.message);
}

class TrayReturnSubmitting extends TrayReturnState {}

class TrayReturnSuccess extends TrayReturnState {
  final String message;
  TrayReturnSuccess(this.message);
}
