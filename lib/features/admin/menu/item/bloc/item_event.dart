abstract class ItemEvent {}

class FetchItemsEvent extends ItemEvent {}

class SubmitStockEvent extends ItemEvent {
  final List<Map<String, dynamic>> eggForms;
  final List<Map<String, dynamic>> trayForms;

  SubmitStockEvent({
    required this.eggForms,
    required this.trayForms,
  });
}
