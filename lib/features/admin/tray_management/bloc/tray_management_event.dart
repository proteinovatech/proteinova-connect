abstract class TrayManagementEvent {}

class FetchInventoryEvent extends TrayManagementEvent {}

class AddTraysToLocationEvent extends TrayManagementEvent {
  final String locationName;
  final int plasticTrays;
  final int paperTrays;

  AddTraysToLocationEvent({
    required this.locationName,
    required this.plasticTrays,
    required this.paperTrays,
  });
}

class ReturnTraysToWarehouseEvent extends TrayManagementEvent {
  final String branchName;
  final int plasticTrays;
  final int paperTrays;

  ReturnTraysToWarehouseEvent({
    required this.branchName,
    required this.plasticTrays,
    required this.paperTrays,
  });
}
