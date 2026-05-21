abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {

  final Map<String, dynamic> inventoryData;

  InventoryLoaded(this.inventoryData);
}

class InventoryError extends InventoryState {

  final String message;

  InventoryError(this.message);
}