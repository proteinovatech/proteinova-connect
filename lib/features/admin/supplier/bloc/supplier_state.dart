part of 'supplier_bloc.dart';

abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<dynamic> suppliers;
  final List<dynamic> filteredSuppliers;

  SupplierLoaded({
    required this.suppliers,
    required this.filteredSuppliers,
  });
}

class SupplierError extends SupplierState {
  final String message;

  SupplierError(this.message);
}