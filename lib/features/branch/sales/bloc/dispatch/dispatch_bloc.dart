import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/sales/data/repository/sales_repository.dart';

import 'dispatch_event.dart';
import 'dispatch_state.dart';

class DispatchBloc
    extends Bloc<DispatchEvent, DispatchState> {

  final SalesRepository repository;

  DispatchBloc(this.repository)
      : super(DispatchInitial()) {

    on<FetchDispatchEvent>(_fetchDispatches);

    on<RefreshDispatchEvent>(_fetchDispatches);
  }

  Future<void> _fetchDispatches(
    DispatchEvent event,
    Emitter<DispatchState> emit,
  ) async {

    emit(DispatchLoading());

    try {

      final data =
          await repository.fetchSalesDashboard();

      final dispatches =
          data["recent_orders"] ?? [];

      emit(
        DispatchLoaded(dispatches),
      );

    } catch (e) {

      emit(
        DispatchError(e.toString()),
      );
    }
  }
}