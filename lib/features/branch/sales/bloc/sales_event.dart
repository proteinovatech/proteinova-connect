abstract class SalesEvent {}

class FetchSalesDashboard extends SalesEvent {
  final int branchId;

  FetchSalesDashboard({required this.branchId});
}

class CreateNewSaleEvent extends SalesEvent {
  final Map<String, dynamic> saleData;
  CreateNewSaleEvent(this.saleData);
}
