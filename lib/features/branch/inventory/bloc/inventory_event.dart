abstract class InventoryEvent {}

class FetchInventoryEvent extends InventoryEvent {
  final int? branchId;
  FetchInventoryEvent({this.branchId});
}

class RefreshInventoryEvent extends InventoryEvent {
  final int? branchId;
  RefreshInventoryEvent({this.branchId});
}