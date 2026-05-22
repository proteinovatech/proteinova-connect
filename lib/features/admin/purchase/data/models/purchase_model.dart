class PurchaseRequest {
  final int supplierId;
  final String warehouseLocation;
  final String location;
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

  final String brokerName;
  final double brokerFee;
  final String brokerNumber;
  final String description;

  final String purchaseStatus;

  final String? paymentMethod;
  final String? upiApp;
  final String? otherUpiDetails;
  final double? paymentAmount;
  final double? debtAmount;

  final List<PurchaseItem> items;

  PurchaseRequest({
    required this.supplierId,
    required this.supplierName,
    required this.location,
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
    required this.brokerFee,
    required this.brokerNumber,
    required this.brokerName,
    required this.description,
    this.paymentMethod,
    this.upiApp,
    this.otherUpiDetails,
    this.paymentAmount,
    this.debtAmount,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        "supplier_id": supplierId,
        "location":location,
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
        'broker_fee': brokerFee,
        'broker_name': brokerName,
        'broker_number': brokerNumber,
        'description': description,
        "payment_method": paymentMethod,
        "upi_app": upiApp,
        "other_upi_details": otherUpiDetails,
        "payment_amount": paymentAmount,
        "debt_amount": debtAmount,
        "items": items.map((e) => e.toJson()).toList(),
      };
}

class PurchaseItem {
  final String eggCategoryGrade;
  final int trays;
  final int capacity;
  final double perEggPrice;
   final double marketPriceMinus;
  final double neccRate;
  final String trayType;

  PurchaseItem({
    required this.eggCategoryGrade,
    required this.trays,
    required this.capacity,
    required this.perEggPrice,
    required this.marketPriceMinus,
    required this.neccRate,
    required this.trayType,
  });

  Map<String, dynamic> toJson() => {
        "egg_category_grade": eggCategoryGrade,
        "trays": trays,
        "capacity": capacity,
        "per_egg_price": perEggPrice,
         "market_price_minus": marketPriceMinus,
        "necc_rate": neccRate,
        "tray_type": trayType,
       
      };
}