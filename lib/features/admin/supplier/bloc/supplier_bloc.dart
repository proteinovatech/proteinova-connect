import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/supplier/data/services/supplier_service.dart';

part 'supplier_event.dart';
part 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {

  final SupplierService supplierService;

  SupplierBloc(this.supplierService)
      : super(SupplierInitial()) {

    on<FetchSuppliersEvent>((event, emit) async {

      emit(SupplierLoading());

      try {

        final fetchedSuppliers =
            await supplierService.getSuppliers();

        emit(
          SupplierLoaded(
            suppliers: fetchedSuppliers,
            filteredSuppliers: fetchedSuppliers,
          ),
        );

      } catch (e) {

        emit(
          SupplierError(
            "Failed to load suppliers: $e",
          ),
        );
      }
    });
    on<SearchSupplierEvent>((event, emit) {

  if (state is SupplierLoaded) {

    final currentState = state as SupplierLoaded;

    final filtered = currentState.suppliers.where((supplier) {

      return supplier.name
              .toLowerCase()
              .contains(event.query.toLowerCase()) ||

          supplier.location
              .toLowerCase()
              .contains(event.query.toLowerCase()) ||

          supplier.owner
              .toLowerCase()
              .contains(event.query.toLowerCase());

    }).toList();

    emit(
      SupplierLoaded(
        suppliers: currentState.suppliers,
        filteredSuppliers: filtered,
      ),
    );
  }
});
  }
}