abstract class TrayManagementEvent {}

class FetchInventoryEvent extends TrayManagementEvent {}

class AddTraysEvent extends TrayManagementEvent {
  final int plasticTrays;
  final int paperTrays;

  AddTraysEvent({
    required this.plasticTrays,
    required this.paperTrays,
  });
}
