part of 'supplier_bloc.dart';

abstract class SupplierEvent {}

class FetchSuppliersEvent extends SupplierEvent {}
class SearchSupplierEvent extends SupplierEvent {
  final String query;

  SearchSupplierEvent(this.query);
}