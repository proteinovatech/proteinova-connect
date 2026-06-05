import '../data/model/customer_tray_model.dart';

abstract class CustomerTrayState {}

class CustomerTrayInitial extends CustomerTrayState {}

class CustomerTrayLoading extends CustomerTrayState {}

class CustomerTrayLoaded extends CustomerTrayState {
  final List<CustomerTray> trays;

  CustomerTrayLoaded(this.trays);
}

class CustomerTrayError extends CustomerTrayState {
  final String message;

  CustomerTrayError(this.message);
}