class DispatchItem {
  final String product;
  final String trayType;
  final int trays;
  final int eggs;

  DispatchItem({
    required this.product,
    required this.trayType,
    required this.trays,
    required this.eggs,
  });

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    return DispatchItem(
      product: json['product'] ?? '',
      trayType: json['tray_type'] ?? '',
      trays: int.tryParse(json['trays']?.toString() ?? '0') ?? 0,
      eggs: int.tryParse(json['eggs']?.toString() ?? '0') ?? 0,
    );
  }
}

class DispatchDetails {
  final int branchId;
  final String branchName;
  final String dispatchCode;
  final String dispatchDate;
  final String vehicleNumber;
  final String driverName;
  final List<DispatchItem> receivedItems;
  final int totalTrays;
  final int totalEggs;
  final int plasticTrays;
  final int paperTrays;

  DispatchDetails({
    required this.branchId,
    required this.branchName,
    required this.dispatchCode,
    required this.dispatchDate,
    required this.vehicleNumber,
    required this.driverName,
    required this.receivedItems,
    required this.totalTrays,
    required this.totalEggs,
    required this.plasticTrays,
    required this.paperTrays,
  });

  factory DispatchDetails.fromJson(Map<String, dynamic> json) {
    final info = json['receive_info'] ?? {};
    final summary = json['summary'] ?? {};
    final itemsList = json['received_items'] as List? ?? [];
    
    return DispatchDetails(
      branchId: int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      branchName: json['branch_name'] ?? '',
      dispatchCode: info['dispatch_code'] ?? '',
      dispatchDate: info['dispatch_date'] ?? '',
      vehicleNumber: info['vehicle_number'] ?? '',
      driverName: info['driver_name'] ?? '',
      receivedItems: itemsList.map((e) => DispatchItem.fromJson(e)).toList(),
      totalTrays: int.tryParse(summary['total_trays']?.toString() ?? '0') ?? 0,
      totalEggs: int.tryParse(summary['total_eggs']?.toString() ?? '0') ?? 0,
      plasticTrays: int.tryParse(summary['plastic_trays']?.toString() ?? '0') ?? 0,
      paperTrays: int.tryParse(summary['paper_trays']?.toString() ?? '0') ?? 0,
    );
  }
}
