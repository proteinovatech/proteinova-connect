import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/supplier_request_model.dart';

abstract class SupplierEvent {}

class FetchSuppliers extends SupplierEvent {}
class AddSupplierEvent extends SupplierEvent {
  final SupplierRequestModel supplier;

  AddSupplierEvent(this.supplier);
}
class SearchSupplierEvent extends SupplierEvent {
  final String query;

  SearchSupplierEvent(this.query);
}

class UpdateSupplierEvent extends SupplierEvent {
  final SupplierRequestModel supplier;

  UpdateSupplierEvent(this.supplier);
}