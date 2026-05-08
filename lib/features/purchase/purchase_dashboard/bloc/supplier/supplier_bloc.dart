import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';


class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepository repository;

  SupplierBloc(this.repository) : super(SupplierInitial()) {
    on<FetchSuppliers>((event, emit) async {
      emit(SupplierLoading());

      try {
        final suppliers = await repository.fetchSuppliers();
        emit(SupplierLoaded(suppliers));
      } catch (e) {
        emit(SupplierError(e.toString()));
      }
    });
  }
}