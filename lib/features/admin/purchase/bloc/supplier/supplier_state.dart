import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_model.dart';


abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<SupplierModel> suppliers;

  SupplierLoaded(this.suppliers);
}

class SupplierError extends SupplierState {
  final String message;

  SupplierError(this.message);
}
class SupplierSubmitting extends SupplierState {}

class SupplierSubmitSuccess extends SupplierState {}

class SupplierSubmitFailure extends SupplierState {
  final String message;

  SupplierSubmitFailure(this.message);
}

