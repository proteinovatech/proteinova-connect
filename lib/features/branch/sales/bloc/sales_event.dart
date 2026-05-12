abstract class SalesEvent {}

class FetchSalesDashboard extends SalesEvent {}

class CreateNewSaleEvent extends SalesEvent {
  final Map<String, dynamic> saleData;
  CreateNewSaleEvent(this.saleData);
}