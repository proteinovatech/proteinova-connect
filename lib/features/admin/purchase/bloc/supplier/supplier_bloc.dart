import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_model.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';


class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepository repository;
  List<SupplierModel> _allSuppliers = [];
  SupplierBloc(this.repository) : super(SupplierInitial()) {
   
    on<FetchSuppliers>((event, emit) async {
      emit(SupplierLoading());

      try {
        final suppliers = await repository.fetchSuppliers();
        _allSuppliers = suppliers;

        emit(SupplierLoaded(suppliers));
      } catch (e) {
        emit(SupplierError(e.toString()));
      }
    });
    on<SearchSupplierEvent>((event, emit) {

  final query = event.query.toLowerCase();

  if (query.isEmpty) {
    emit(SupplierLoaded(_allSuppliers));
    return;
  }

  final filtered = _allSuppliers.where((supplier) {

    return supplier.companyName
            .toLowerCase()
            .contains(query) ||

        supplier.supplierName
            .toLowerCase()
            .contains(query) ||

        supplier.phoneNumber
            .toLowerCase()
            .contains(query);

  }).toList();

  emit(SupplierLoaded(filtered));
});

     on<AddSupplierEvent>(_onAddSupplier);
  }
  
  Future<void> _onAddSupplier(
  AddSupplierEvent event,
  Emitter<SupplierState> emit,
) async {

  try {

    emit(SupplierSubmitting());

    await repository.postSupplier(
      event.supplier,
    );

    emit(SupplierSubmitSuccess());

    add(FetchSuppliers());

  } catch (e) {

    emit(
      SupplierSubmitFailure(
        "Failed to add supplier",
      ),
    );

  }
}
}