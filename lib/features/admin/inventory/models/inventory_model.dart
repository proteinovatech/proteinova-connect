class AdminInventoryModel {
  final InventoryMetrics metrics;
  final List<PurchaseModel> purchases;

  AdminInventoryModel({
    required this.metrics,
    required this.purchases,
  });

  factory AdminInventoryModel.fromJson(Map<String, dynamic> json) {
    // Backend uses 'cards' for metrics
    final metricsData = json['cards'] ?? json['metrics'] ?? json;
    
    // Backend uses 'shipments' for the list
    final dynamic listData = json['shipments'] ?? json['purchases'] ?? json['data'];
    List<dynamic> purchasesList = [];
    
    if (listData is List) {
      purchasesList = listData;
    } else if (listData is Map && listData.containsKey('data')) {
      purchasesList = listData['data'] is List ? listData['data'] : [];
    }

    return AdminInventoryModel(
      metrics: InventoryMetrics.fromJson(metricsData is Map<String, dynamic> ? metricsData : {}),
      purchases: purchasesList.map((e) => PurchaseModel.fromJson(e)).toList(),
    );
  }
}

class InventoryMetrics {
  final int expectedToday;
  final int readyForUnloading;
  final int delayedInTransit;
  final int currentStock;
  final int damagedTrays;
  final double stockValue;
  final int openingStock;
  final int closingStock;
  final int incomingStock;
  final int salesToday;
  final double purchaseExpense;

  InventoryMetrics({
    required this.expectedToday,
    required this.readyForUnloading,
    required this.delayedInTransit,
    required this.currentStock,
    required this.damagedTrays,
    required this.stockValue,
    required this.openingStock,
    required this.closingStock,
    required this.incomingStock,
    required this.salesToday,
    required this.purchaseExpense,
  });

  factory InventoryMetrics.fromJson(Map<String, dynamic> json) {
    return InventoryMetrics(
      expectedToday: int.tryParse(json['expected_today']?.toString() ?? '') ?? 0,
      readyForUnloading: int.tryParse(json['ready_for_unloading']?.toString() ?? '') ?? 0,
      delayedInTransit: int.tryParse(json['delayed_in_transit']?.toString() ?? '') ?? 0,
      currentStock: int.tryParse(json['current_stock']?.toString() ?? '') ?? 0,
      damagedTrays: int.tryParse(json['damaged_trays']?.toString() ?? '') ?? 0,
      stockValue: double.tryParse(json['stock_value']?.toString() ?? '') ?? 0.0,
      openingStock: int.tryParse(json['opening_stock']?.toString() ?? '') ?? 0,
      closingStock: int.tryParse(json['closing_stock']?.toString() ?? '') ?? 0,
      incomingStock: int.tryParse(json['incoming_stock']?.toString() ?? '') ?? 0,
      salesToday: int.tryParse(json['sales_today']?.toString() ?? '') ?? 0,
      purchaseExpense: double.tryParse(json['purchase_expense']?.toString() ?? '') ?? 0.0,
    );
  }
}
class PurchaseModel {
  final int id;
  final String poNumber;
  final String supplierName;
  final String productName;
  final int totalQuantity;
  final String arrivalDate;
  final String status;
  final String location;
  final String createdAt;
  final String purchaseStatus;
  final String movementStatus;
  final String driverName;
  final String vehicleNumber;
  final String vehicleType;
  final String driverPhone;
  final String warehouseLocation;

  PurchaseModel({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.productName,
    required this.totalQuantity,
    required this.arrivalDate,
    required this.status,
    required this.location,
    required this.createdAt,
    required this.purchaseStatus,
    required this.movementStatus,
    this.driverName = '',
    this.vehicleNumber = '',
    this.vehicleType = '',
    this.driverPhone = '',
    this.warehouseLocation = '',
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    int parsedId = int.tryParse(json['dispatch_id']?.toString() ?? json['id']?.toString() ?? '') ?? 0;
    
    int calculatedEggs = 0;
    String calculatedProducts = '';
    
    if (json['items'] is List) {
      final items = json['items'] as List;
      calculatedEggs = items.fold<int>(0, (sum, item) {
        final trays = int.tryParse(item['trays']?.toString() ?? '0') ?? 0;
        final capacity = int.tryParse(item['capacity']?.toString() ?? '30') ?? 30;
        return sum + (trays * capacity);
      });
      calculatedProducts = items.map((item) => item['egg_category_grade']?.toString() ?? '').where((e) => e.isNotEmpty).join(', ');
    }

    return PurchaseModel(
      id: parsedId,
      poNumber: json['dispatch_code']?.toString() ?? json['po_number']?.toString() ?? json['poNumber']?.toString() ?? 'PO-$parsedId',
      supplierName: json['supplier_company_name']?.toString() ?? json['supplier_or_from']?.toString() ?? json['supplier_name']?.toString() ?? json['supplierName']?.toString() ?? '',
      productName: calculatedProducts.isNotEmpty ? calculatedProducts : (json['product_summary']?.toString() ?? json['product_name']?.toString() ?? json['productName']?.toString() ?? ''),
      totalQuantity: calculatedEggs > 0 ? calculatedEggs : (int.tryParse(json['total_eggs']?.toString() ?? json['total_quantity']?.toString() ?? json['totalQuantity']?.toString() ?? '') ?? 0),
      arrivalDate: json['expected_arrival']?.toString() ?? json['arrival_date']?.toString() ?? json['arrivalDate']?.toString() ?? '',
      status: json['purchase_status']?.toString() ?? json['movement_status']?.toString() ?? json['status']?.toString() ?? '',
      location: json['purchased_location']?.toString() ?? json['vehicle_driver']?.toString() ?? json['location']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['dispatch_date']?.toString() ?? '',
      purchaseStatus: json['purchase_status']?.toString() ?? '',
      movementStatus: json['movement_status']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      driverPhone: json['driver_phone']?.toString() ?? '',
      warehouseLocation: json['warehouse_location']?.toString() ?? '',
    );
  }
}
