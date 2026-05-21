abstract class DispatchState {}

class DispatchInitial extends DispatchState {}

class DispatchLoading extends DispatchState {}

class DispatchLoaded extends DispatchState {

  final List<dynamic> dispatches;

  DispatchLoaded(this.dispatches);
}

class DispatchError extends DispatchState {

  final String message;

  DispatchError(this.message);
}