class IncomingDispatch {
  final int dispatchId;
  final String dispatchCode;
  final String expectedArrival;
  final String vehicleDriver;
  final int totalTrays;
  final int totalEggs;
  final String status;

  IncomingDispatch({
    required this.dispatchId,
    required this.dispatchCode,
    required this.expectedArrival,
    required this.vehicleDriver,
    required this.totalTrays,
    required this.totalEggs,
    required this.status,
  });

  factory IncomingDispatch.fromJson(Map<String, dynamic> json) {
    return IncomingDispatch(
      dispatchId: json['dispatch_id'] != null ? int.tryParse(json['dispatch_id'].toString()) ?? 0 : 0,
      dispatchCode: json['dispatch_code'] ?? '',
      expectedArrival: json['expected_arrival'] ?? '',
      vehicleDriver: json['vehicle_driver'] ?? '',
      totalTrays: json['total_trays'] != null ? int.tryParse(json['total_trays'].toString()) ?? 0 : 0,
      totalEggs: json['total_eggs'] != null ? int.tryParse(json['total_eggs'].toString()) ?? 0 : 0,
      status: json['status'] ?? '',
    );
  }
}
