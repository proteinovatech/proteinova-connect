import 'incoming_dispatch_model.dart';

class ReceivingDashboardData {
  final int expectedToday;
  final int readyForUnloading;
  final int delayedInTransit;
  final int totalShipments;
  final List<IncomingDispatch> shipments;

  ReceivingDashboardData({
    required this.expectedToday,
    required this.readyForUnloading,
    required this.delayedInTransit,
    required this.totalShipments,
    required this.shipments,
  });

  factory ReceivingDashboardData.fromJson(Map<String, dynamic> json) {
    final cards = json['cards'] ?? {};
    final list = json['shipments'] as List? ?? [];
    return ReceivingDashboardData(
      expectedToday: int.tryParse(cards['expected_today']?.toString() ?? '0') ?? 0,
      readyForUnloading: int.tryParse(cards['ready_for_unloading']?.toString() ?? '0') ?? 0,
      delayedInTransit: int.tryParse(cards['delayed_in_transit']?.toString() ?? '0') ?? 0,
      totalShipments: int.tryParse(cards['total_shipments']?.toString() ?? '0') ?? 0,
      shipments: list.map((e) => IncomingDispatch.fromJson(e)).toList(),
    );
  }
}
