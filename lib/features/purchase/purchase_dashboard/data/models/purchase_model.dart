class PurchaseRequest {
  final int supplierId;
  final String warehouseLocation;
  final String expectedArrival;
   final String supplierName;
  final String driverName;
  final String driverNumber;
  final String vehicleNumber;
  final String vehicleType;
  

  final double loadingCharge;
  final double unloadingCharge;
  final double transportCharge;
  final double miscExpense;

  final String purchaseStatus;

  final List<PurchaseItem> items;

  PurchaseRequest({
    required this.supplierId,
    required this.supplierName,
    required this.warehouseLocation,
    required this.expectedArrival,
    required this.driverName,
    required this.driverNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.loadingCharge,
    required this.unloadingCharge,
    required this.transportCharge,
    required this.miscExpense,
    required this.purchaseStatus,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        "supplier_id": supplierId,
        "warehouse_location": warehouseLocation,
        "expected_arrival": expectedArrival,
        "driver_name": driverName,
        "driver_number": driverNumber,
        "vehicle_number": vehicleNumber,
        "vehicle_type": vehicleType,
        "loading_charge": loadingCharge,
        "unloading_charge": unloadingCharge,
        "transport_charge": transportCharge,
        "misc_expense": miscExpense,
        "purchase_status": purchaseStatus,
        "items": items.map((e) => e.toJson()).toList(),
      };
}

class PurchaseItem {
  final String grade;
  final int trays;
  final int capacity;
  final double price;
   final double marketPriceMinus;
  final double neccRate;
  final String trayType;

  PurchaseItem({
    required this.grade,
    required this.trays,
    required this.capacity,
    required this.price,
    required this.marketPriceMinus,
    required this.neccRate,
    required this.trayType,
  });

  Map<String, dynamic> toJson() => {
        "egg_category_grade": grade,
        "trays": trays,
        "capacity": capacity,
        "per_egg_price": price,
         "market_price_minus": marketPriceMinus,
        "necc_rate": neccRate,
        "tray_type": trayType,
      };
}