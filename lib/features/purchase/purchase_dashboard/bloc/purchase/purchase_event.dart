abstract class PurchaseEvent {}

class FetchPurchaseInitData extends PurchaseEvent {}
class GetPurchasesEvent extends PurchaseEvent {}
class GetCachedPurchasesEvent extends PurchaseEvent {}
class UpdateArrivalEvent extends PurchaseEvent {
  final String purchaseId;
  final Map<String, dynamic> data;

  UpdateArrivalEvent({
    required this.purchaseId,
    required this.data,
  });
}

class SearchPurchaseEvent extends PurchaseEvent {
  final String query;

  SearchPurchaseEvent(this.query);
}