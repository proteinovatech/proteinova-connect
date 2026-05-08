abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesSuccess extends SalesState {}

class SalesError extends SalesState {
  final String message;

  SalesError(this.message);
}