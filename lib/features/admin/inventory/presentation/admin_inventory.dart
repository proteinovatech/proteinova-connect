import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_inventory_overview_skeleton_loader.dart';
import 'package:proteinova_connect/features/admin/widget/inventory_card.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import '../data/inventory_repository.dart';
import '../models/inventory_model.dart';

// Newly added imports for React compatibility
import 'package:proteinova_connect/features/admin/supplier/data/services/supplier_service.dart';
import 'package:proteinova_connect/features/admin/supplier/data/models/supplier_model.dart';
import 'package:proteinova_connect/features/admin/presentation/receive_stockscreen.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_entry_page.dart';
import 'package:proteinova_connect/features/admin/Distribution/presentation/dispatch_planning_page.dart';
class AdminInventory extends StatefulWidget {
  final String role;
  const AdminInventory({super.key, required this.role});

  @override
  State<AdminInventory> createState() => _AdminInventoryState();
}

class _AdminInventoryState extends State<AdminInventory> {
  final InventoryRepository _repository = InventoryRepository();
  final SupplierService _supplierService = SupplierService();

  // State matching React
  // bool isFetching = true;
  bool _isLoading = true;
  String searchTerm = "";
  String selectedLocation = "all";
  List<Supplier> suppliers = [];
  String selectedSupplier = "All";
  int currentPage = 1;
  final int recordsPerPage = 10;
  List<PurchaseModel> purchaseData = [];
  Map<String, dynamic> rawInventoryData = {};
  List<Map<String, dynamic>> branches = [];
 
bool _suppliersLoaded = false;
bool _purchasesLoaded = false;
bool _rawInventoryLoaded = false;
 
  Map<String, dynamic> inventoryStats = {
    "opening_stock": 0,
    "closing_stock": 0,
    "incoming_stock": 0,
    "current_stock": 0,
    "damaged_trays": 0,
    "stock_value": 0.0,
    "category_stock": [],
    "breakdowns": {},
  };
  String role = ""; // or "WAREHOUSE"
  String? selectedCategoryName;

 
  @override
  void initState() {
    super.initState();
  selectedLocation = "All";
  loadBranches();
  _loadData();
  loadAllBranches();

  }

  Future<void> _loadData() async {
  
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
       if (selectedLocation == null || selectedLocation == "All") {
      await loadAllBranches();
      return;
    }

    final branchId = int.parse(selectedLocation!);
      final results = await Future.wait([
        _repository.fetchBranchDashboard(branchId),
        _repository.fetchRawInventoryData(),
        _supplierService.getSuppliers(),
        _repository.fetchPurchases(),
      ]);
   
final rawInventory = results[1] as Map<String, dynamic>;

final inventoryByBranch = List<Map<String, dynamic>>.from(
  rawInventory["inventory_by_branch"] ?? [],
);

final openingByBranch = List<Map<String, dynamic>>.from(
  rawInventory["opening_stock_by_branch"] ?? [],
);

final categoryLevels = List<Map<String, dynamic>>.from(
  rawInventory["inventory_levels_by_category"] ?? [],
);
final filteredInventoryByBranch = inventoryByBranch.where((item) {
  
  return item["branch_id"].toString() == branchId.toString();
}).toList();

final filteredOpeningByBranch = openingByBranch.where((item) {
  return item["branch_id"].toString() == branchId.toString();
}).toList();


final supplierList = results[2] as List<Supplier>;
final purchasesList = results[3] as List<PurchaseModel>;


      if (!mounted) return;

      final selectedInventory =  filteredInventoryByBranch;

final selectedOpening = filteredOpeningByBranch;

final openingStock = selectedOpening.fold<int>(
  0,
  (sum, e) => sum + ((e["total_eggs"] ?? 0) as int),
);

final currentStock = selectedInventory.fold<int>(
  0,
  (sum, e) => sum + ((e["total_eggs"] ?? 0) as int),
);


final incomingStock = categoryLevels.fold<int>(
  0,
  (sum, e) => sum + ((e["incoming"] ?? 0) as int),
);

final damagedStock = categoryLevels.fold<int>(
  0,
  (sum, e) => sum + ((e["damaged"] ?? 0) as int),
);
   
      setState(() {
        rawInventoryData = rawInventory;
        suppliers = supplierList;
        purchaseData = purchasesList;
 
        // Inventory stats parsing
  inventoryStats = {
  "opening_stock": openingStock,
  "closing_stock": currentStock,
  "current_stock": currentStock,
  "incoming_stock": incomingStock,
  "damaged_stock": damagedStock,

  "inventory_levels_by_category": categoryLevels,
  "inventory_by_branch": filteredInventoryByBranch,
  "opening_stock_by_branch": filteredOpeningByBranch,
  "active_branches": rawInventory["active_branches"] ?? [],
  "purchase_records": rawInventory["purchase_records"] ?? [],
};    
// Auto-select first category if none selected

        if (selectedCategoryName == null) {
         final catStock =
    (inventoryStats["inventory_levels_by_category"] as List<dynamic>?) ?? [];
          if (catStock.isNotEmpty) {
            selectedCategoryName =
                (catStock[0] as Map<String, dynamic>)["category"]?.toString() ??
                "Unknown";
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading admin inventory: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching inventory data: $e")),
        );
      }
    }
  }

  Future<void> loadBranches() async {
  try {
    final result = await _repository.fetchBranches();

    setState(() {
      branches = result;
    });
  } catch (e) {
    print(e);
  }
}

Future<void> loadAllBranches() async {
  try {
    setState(() => _isLoading = true);

     final branchesFuture = _repository.fetchBranches();

    final rawInventoryFuture = _rawInventoryLoaded
        ? Future.value(rawInventoryData)
        : _repository.fetchRawInventoryData();

    final suppliersFuture = _suppliersLoaded
        ? Future.value(suppliers)
        : _supplierService.getSuppliers();

    final purchasesFuture = _purchasesLoaded
        ? Future.value(purchaseData)
        : _repository.fetchPurchases();

         // Wait only for branches
    final branches = await branchesFuture;
   
    // Now start all dashboard requests together
    final dashboardFuture = Future.wait(
      branches.map(
        (branch) => _repository.fetchBranchDashboard(branch["id"]),
      ),
    ); 

     // Wait for everything together
    final results = await Future.wait([
      dashboardFuture,
      rawInventoryFuture,
      suppliersFuture,
      purchasesFuture,
    ]);


    rawInventoryData =
        Map<String, dynamic>.from(results[1] as Map);
    suppliers = results[2] as List<Supplier>;
    purchaseData = results[3] as List<PurchaseModel>;

    _rawInventoryLoaded = true;
    _suppliersLoaded = true;
    _purchasesLoaded = true;


    List<dynamic> combinedCategoryStock = [];

    combinedCategoryStock =
        rawInventoryData["inventory_levels_by_category"] ?? [];

         final inventoryByBranch =
    List<Map<String, dynamic>>.from(
        rawInventoryData["inventory_by_branch"] ?? []);

final openingByBranch =
    List<Map<String, dynamic>>.from(
        rawInventoryData["opening_stock_by_branch"] ?? []);

final incomingByBranch =
    List<Map<String, dynamic>>.from(
      rawInventoryData["incoming_stock_by_branch"] ?? [],
    );

final salesTodayByBranch =
    List<Map<String, dynamic>>.from(
      rawInventoryData["sales_today_by_branch"] ?? [],
    );

final categoryLevels =
    List<Map<String, dynamic>>.from(
        rawInventoryData["inventory_levels_by_category"] ?? []); 
  
      final openingStock = openingByBranch.fold<int>(
  0,
  (sum, item) => sum + ((item["total_eggs"] ?? 0) as int),
);

final incomingStock = incomingByBranch.fold<int>(
  0,
  (sum, item) => sum + ((item["total_eggs"] ?? 0) as int),
);

final salesToday = salesTodayByBranch.fold<int>(
  0,
  (sum, item) => sum + ((item["total_eggs"] ?? 0) as int),
);

final currentStock = inventoryByBranch.fold<int>(
  0,
  (sum, item) => sum + ((item["total_eggs"] ?? 0) as int),
);



final damagedStock = categoryLevels.fold<int>(
  0,
  (sum, item) => sum + ((item["damaged"] ?? 0) as int),
);  

    
    setState(() {

     inventoryStats = {
  "opening_stock": openingStock,
  "closing_stock": currentStock,
  "current_stock": currentStock,
  "incoming_stock": incomingStock,
   "sales_today": salesToday,
  "damaged_stock": damagedStock,

  "inventory_levels_by_category": categoryLevels,
  "inventory_by_branch": inventoryByBranch,
  "opening_stock_by_branch": openingByBranch,
   "incoming_stock_by_branch": incomingByBranch,
  "sales_today_by_branch": salesTodayByBranch,

  "active_branches": rawInventoryData["active_branches"] ?? [],
  "purchase_records": rawInventoryData["purchase_records"] ?? [],
};

      if (selectedCategoryName == null &&
          combinedCategoryStock.isNotEmpty) {
        selectedCategoryName =
            combinedCategoryStock.first["category"]?.toString();
      }

      _isLoading = false;
    });

  
  } catch (e) {
    print("All Branch Load Error: $e");

    setState(() {
      _isLoading = false;
    });
  }
}
  // Filter logic matching React
  List<PurchaseModel> get filteredData {
    final search = searchTerm.toLowerCase();

    Supplier? selectedSupplierObj;
    if (selectedSupplier != "All") {
      try {
        selectedSupplierObj = suppliers.firstWhere(
          (s) => s.id == selectedSupplier,
        );
      } catch (_) {}
    }

    return purchaseData.where((row) {
      final poMatch =
          "po-${row.id}".toLowerCase().contains(search) ||
          row.poNumber.toLowerCase().contains(search);

      final supplierName = row.supplierName.toLowerCase();
      final driverName = row.driverName.toLowerCase();

      final supplierMatch =
          supplierName.contains(search) ||
          row.location.toLowerCase().contains(search);
      final driverMatch = driverName.contains(search);

      final bool searchFilter = poMatch || supplierMatch || driverMatch;

      bool supplierFilter = true;
      if (selectedSupplier != "All" && selectedSupplierObj != null) {
        final supplierLocation = selectedSupplierObj.location.toLowerCase();
        supplierFilter = row.location.toLowerCase().contains(supplierLocation);
      }

      return searchFilter && supplierFilter;
    }).toList();
  }

  // Pagination logic matching React
  int get indexOfLast => currentPage * recordsPerPage;
  int get indexOfFirst => indexOfLast - recordsPerPage;

  List<PurchaseModel> get currentData {
    final list = filteredData;
    if (list.isEmpty) return [];

    final start = indexOfFirst;
    final end = indexOfLast;

    if (start >= list.length) return [];
    return list.sublist(start, end.clamp(0, list.length));
  }

  int get totalPages => (filteredData.length / recordsPerPage).ceil();

  void handleNext() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  void handlePrev() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

 double getPercent(
    Map<String, dynamic> item,
    List<dynamic> categoryStock,
) {
  final available = (item["available"] ?? 0) as num;

  final maxAvailable = categoryStock
      .map((e) => (e["available"] ?? 0) as num)
      .reduce((a, b) => a > b ? a : b);

  return maxAvailable == 0 ? 0 : available / maxAvailable;
}

  String formatDate(String dateStr) {
    if (dateStr.isEmpty) return "No Date";
    try {
      final d = DateTime.parse(dateStr).toLocal();
      final day = d.day.toString().padLeft(2, '0');
      final months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      final month = months[d.month - 1];
      final year = d.year;

      int hour = d.hour;
      final minute = d.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? "PM" : "AM";
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      final hourStr = hour.toString().padLeft(2, '0');

      return "$day $month $year • $hourStr:$minute $ampm";
    } catch (e) {
      return "Invalid Date";
    }
  }

  List<Map<String, dynamic>> _buildAlerts(List<PurchaseModel> purchases) {
    final now = DateTime.now();
    return purchases.take(4).map((row) {
      String type = "shopping";
      IconData icon = Icons.shopping_bag_outlined;
      String title = "PO-${row.id}";
      String description = row.location.isEmpty ? "Local" : row.location;
      Color color = Colors.blue;

      if (row.purchaseStatus.toUpperCase() == "RECEIVED") {
        type = "warning";
        icon = Icons.download_outlined;
        title = "Received PO-${row.id}";
        description = row.location.isEmpty ? "Warehouse" : row.location;
        color = Colors.green;
      } else if (row.movementStatus.toUpperCase() == "IN_TRANSIT") {
        type = "critical";
        icon = Icons.local_shipping_outlined;
        title = "In Transit PO-${row.id}";
        description = "Arriving: ${row.arrivalDate.split('T').first}";
        color = Colors.red;
      } else {
        type = "shopping";
        icon = Icons.shopping_bag_outlined;
        title = "Ordered PO-${row.id}";
        color = Colors.blue;
      }

      String timeStr = "Just now";
      if (row.createdAt.isNotEmpty) {
        try {
          final createdAtDate = DateTime.parse(row.createdAt);
          final diff = now.difference(createdAtDate);
          if (diff.inMinutes < 60) {
            timeStr = "${diff.inMinutes} mins ago";
          } else if (diff.inHours < 24) {
            timeStr = "${diff.inHours} hours ago";
          } else {
            timeStr = "${diff.inDays} days ago";
          }
        } catch (_) {}
      }

      return {
        "type": type,
        "title": title,
        "description": description,
        "time": timeStr,
        "icon": icon,
        "color": color,
      };
    }).toList();
  }

 void _openDetailsModal(String title, dynamic rawData, String type) {
  List<dynamic> data = [];

  if (rawData is List) {
    data = rawData
        .map((e) => e is Map ? Map<String, dynamic>.from(e) : e)
        .toList();
  } else if (rawData is Map) {
    data = rawData.entries
        .map(
          (e) => {
            "category": e.key.toString(),
            "total_eggs": int.tryParse(e.value.toString()) ?? 0,
            "revenue": double.tryParse(e.value.toString()) ?? 0.0,
            "total_value": double.tryParse(e.value.toString()) ?? 0.0,
          },
        )
        .toList();
  }

  // Scale opening/incoming stock to match card total
  if ((title.toLowerCase().contains("opening stock") ||
          title.toLowerCase().contains("incoming stock")) &&
      data.isNotEmpty) {
    final expectedKey = title.toLowerCase().contains("opening stock")
        ? "opening_stock"
        : "incoming_stock";

    final expectedTotal =
        int.tryParse(inventoryStats[expectedKey]?.toString() ?? "0") ?? 0;

    if (expectedTotal > 0) {
      final currentTotal = data.fold<int>(0, (sum, item) {
        final value = item is Map
            ? (item["total_eggs"] ??
                item["total_eggs_expected"] ??
                item["total_eggs_unloading"] ??
                item["count"] ??
                0)
            : 0;

        return sum + (int.tryParse(value.toString()) ?? 0);
      });

      if (currentTotal > 0 && currentTotal != expectedTotal) {
        final factor = expectedTotal / currentTotal;

        int running = 0;

        for (int i = 0; i < data.length; i++) {
          final item = Map<String, dynamic>.from(data[i]);

          final original =
              int.tryParse(item["total_eggs"]?.toString() ?? "0") ?? 0;

          int scaled = (original * factor).round();

          if (i == data.length - 1) {
            scaled = expectedTotal - running;
          } else {
            running += scaled;
          }

          item["total_eggs"] = scaled;
          data[i] = item;
        }
      }
    }
  }
   showDialog(
  context: context,
  builder: (BuildContext context) {
    final isCurrency = type == "currency";

   final isBranchInventory =
    title.toLowerCase().contains("opening stock") ||
    title.toLowerCase().contains("closing stock") ||
    title.toLowerCase().contains("current stock") ||
    title.toLowerCase().contains("incoming stock") ||
    title.toLowerCase().contains("sales today");

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints( maxWidth: 700,minWidth: 700,),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),

            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text("No detailed data available."),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                   child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 460),
                  child: Table(
                    border: TableBorder.symmetric(
                      inside: const BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    columnWidths: isBranchInventory
                        ? const {
                            0: FixedColumnWidth(120),
                            1: FixedColumnWidth(170),
                            2: FixedColumnWidth(70),
                            3: FixedColumnWidth(90),
                          }
                        : const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                          },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                        ),
                        children: isBranchInventory
                            ? const [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      "Branch",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      "Category",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      "Trays",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      "Eggs",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            : const [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "Category",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "Value",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],

                      ),

                       ...data.map((item) {
                        if (isBranchInventory) {
                          final branchName =
                              item is Map ? item["branch_name"] ?? "-" : "-";

                          final categoryName =
                              item is Map ? item["category"] ?? "-" : "-";

                          final trays =
                              item is Map ? item["trays"] ?? 0 : 0;

                          final eggs =
                              item is Map ? item["total_eggs"] ?? 0 : 0;

                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF1F5F9),
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                branchName.toString(),
                                maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                               softWrap: false,
                                 ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                               categoryName.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                 ),
                              ),
                              Padding(
                                 padding: const EdgeInsets.all(10),
                                 child: Align(
                                alignment: Alignment.center,
                               child: Text(
                              trays.toString(),
                               style: const TextStyle(fontSize: 14),
                               ),
                                ),
                               ),
                             Padding(
                         padding: const EdgeInsets.all(10),
                        child: Align(
                        alignment: Alignment.center,
                        child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                        NumberFormat('#,##,###').format(eggs),
                        style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        ),
                       ),
                     ),
                      ),
                      ),
                            ],
                          );
                        }

                        // Existing two-column layout for other dialogs
                        final categoryName = item is Map
                            ? (item["category"] ?? "Unknown")
                            : "Unknown";

                        dynamic displayValue;

                        if (isCurrency) {
                          final value = item is Map
                              ? (item["revenue"] ??
                                  item["total_value"] ??
                                  item["value"] ??
                                  0)
                              : 0;

                          displayValue =
                              "₹${double.tryParse(value.toString())?.toStringAsFixed(2) ?? value}";
                        } else {
                          final value = item is Map
                              ? (item["total_eggs"] ??
                                  item["total_eggs_expected"] ??
                                  item["total_eggs_unloading"] ??
                                  item["count"] ??
                                  0)
                              : 0;

                          displayValue =
                              "${NumberFormat('#,##,###').format(int.tryParse(value.toString()) ?? 0)} Eggs";
                        }

                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFF1F5F9),
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(categoryName.toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                displayValue.toString(),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),)
                ),
              ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
}


  @override
  Widget build(BuildContext context) {
  
    if (_isLoading ) {
      return const AdminInventoryOverviewSkeletonLoader();
      
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: Column(
            children: [
              // if (_isLoading)
              //   const LinearProgressIndicator(
              //     minHeight: 3,
              //     backgroundColor: Colors.transparent,
              //     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              //   ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER & SUBHEADER (No Container Backgrounds)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Show back arrow only for Admin
                                if (widget.role.toLowerCase() == "admin") ...[
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: getWidth(context, 12)),
                                ],
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Inventory Overview",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: getHeight(context, 8)),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getWidth(context, 10),
                                        vertical: getHeight(context, 5),
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffFFF3B0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.verified_user_outlined,
                                            size: 14,
                                          ),
                                          SizedBox(width: getWidth(context, 5)),
                                          Text(
                                            'Admin & Warehouse',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: getHeight(context, 24)),

                            /// INCOMING QUEUE & ADD SALE
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Incoming Stock Queue",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: getHeight(context, 4)),
                                      const Text(
                                        "Manage and receive incoming shipments from suppliers to update inventory.",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedLocation,
                                    decoration: InputDecoration(
                                      labelText: "Select Location",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                    ),
                                    items: [
                                     const DropdownMenuItem<String>(
                                      value: "All",
                                      child: Text("All Branches"),
                                      ),
                                  ...branches.map((branch) {
                                    return DropdownMenuItem<String>(
                                    value: branch["id"].toString(),
                                    child: Text(branch["branch_name"]),
                                     );
                                      }).toList(),
                                        ],
                               onChanged: (value) async {
                                 if (value == null) return;
                                 setState(() {
                                  selectedLocation = value;
                                       });
                                     await _loadData();
                                      }
                                  ),
                                ),
                         ],
                            ),
                                                            ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DispatchPlanningPage(),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Add Sale",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffFFD400),
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getWidth(context, 12),
                                      vertical: getHeight(context, 10),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
     
                          ],
                        ),
                      ),

                      SizedBox(height: getHeight(context, 16)),
                      
                      /// GRID CARDS
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.45,
                        children: [
                          GestureDetector(
                            onTap: () => _openDetailsModal(
                              "Opening Stock Breakdown",
                              inventoryStats["opening_stock_by_branch"] ?? [],
                              "count",
                            ),
                            child: InventoryCard(
                              title: "Opening Stock",
                              value:
    "${NumberFormat('#,##,###').format(inventoryStats['opening_stock'] ?? 0)} Eggs",
                              subtitle: "Stock at start of day",
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.lightBlue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal(
                              "Closing Stock Breakdown",
                               inventoryStats["inventory_by_branch"] ?? [],
                              "count",
                            ),
                            child: InventoryCard(
                              title: "Closing Stock",
                           value:
    "${NumberFormat('#,##,###').format(inventoryStats['closing_stock'] ?? 0)} Eggs",
                              subtitle: "Current available stock",
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.green,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal(
                              "Incoming Stock Breakdown",
                              inventoryStats["incoming_stock_by_branch"] ?? [],
                              "count",
                            ),
                            child: InventoryCard(
                              title: "Total Incoming Stock",
                              value:"${NumberFormat('#,##,###').
                              format(inventoryStats['incoming_stock'] ?? 0)} Eggs",
                              subtitle: "Stock in transit",
                              icon: Icons.local_shipping_outlined,
                              iconColor: Colors.blue,
                            ),
                          ),
                          GestureDetector(
                           onTap: () => _openDetailsModal(
                          "Sales Today Breakdown",
                          inventoryStats["sales_today_by_branch"] ?? [],
                          "count",
                          ),
                            child: InventoryCard(
                              title: "Sales Today",
                             value:"${NumberFormat('#,##,###').
                             format(inventoryStats['sales_today'] ?? 0)} Eggs",
                              subtitle: "Total eggs sold today",
                              icon: Icons.send_outlined,
                              iconColor: Colors.deepPurpleAccent,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal(
                              "Current Stock Breakdown",
                               inventoryStats["inventory_by_branch"] ?? [],
                              "count",
                            ),
                            child: InventoryCard(
                              title: "Current Stock",
                 value:
    "${NumberFormat('#,##,###').format(inventoryStats['current_stock'] ?? 0)} Eggs",
                              subtitle: "View detailed breakdown",
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.orange,
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () => _openDetailsModal(
                          //     "Stock Value Breakdown",
                          //     inventoryStats["breakdowns"]["stock_value"],
                          //     "currency",
                          //   ),
                          //   child: InventoryCard(
                          //     title: "Stock Value",
                          //     value:
                          //         "₹ ${(inventoryStats['stock_value'] ?? 0).toString()}",
                          //     subtitle: "Today's inventory valuation",
                          //     icon: Icons.currency_rupee,
                          //     iconColor: Colors.green,
                          //   ),
                          // ),
                        ],
                      ),

                      SizedBox(height: getHeight(context, 16)),

                      /// CATEGORY PROGRESS & RECENT ACTIVITY
                      _buildCategoryAndActivitySection(context),

                      SizedBox(height: getHeight(context, 16)),

                      /// TABLE CARD
                      _buildPurchaseOrdersCard(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryAndActivitySection(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 750;

    final categoryPanel = _buildCategoryPanel(context);
    final graphPanel = _buildCategoryGraphPanel(context);
    // final activityPanel = _buildActivityPanel(context);

    if (isWide) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: categoryPanel),
              const SizedBox(width: 16),
              //  Expanded(child: activityPanel),
            ],
          ),
          const SizedBox(height: 16),
          //  Expanded(child: activityPanel),
          graphPanel,
        ],
      );
    } else {
      return Column(
        children: [
          categoryPanel,
          const SizedBox(height: 16),
          //  activityPanel,
          graphPanel,
        ],
      );
    }
  }

  Widget _buildCategoryPanel(BuildContext context) {
    debugPrint("inventoryStats = $inventoryStats");
    final categoryStock =
    inventoryStats["inventory_levels_by_category"] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Inventory Levels by Category",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              // TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(
              //     padding: EdgeInsets.zero,
              //     minimumSize: const Size(50, 30),
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   ),
              //   child: const Text(
              //     "View Details",
              //     style: TextStyle(color: Color(0xFF1E73FF), fontWeight: FontWeight.bold, fontSize: 12),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          if (categoryStock.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No categories available",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryStock.length,
              itemBuilder: (context, index) {
                final item = categoryStock[index] as Map<String, dynamic>;
                final categoryName = (item["category"] ?? "Unknown").toString();
                final available =
    int.tryParse(item["available"]?.toString() ?? "0") ?? 0;
                final percent = getPercent(item,categoryStock);
                final isSelected = selectedCategoryName == categoryName;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryName = categoryName;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 1.5,
                            )
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.radio_button_checked,
                                        size: 16,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ),
                                  Flexible(
                                    child: Text(
                                      categoryName,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.bold,
                                        color: isSelected
                                            ? const Color(0xFF1D4ED8)
                                            : const Color(0xFF334155),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              available.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF0F172A),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF94A3B8),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // HELPER: Get value for a specific category from breakdown data
  // ═══════════════════════════════════════════════
  int _getValueForCategory(dynamic breakdownData, String categoryName) {
    if (breakdownData == null) return 0;

    if (breakdownData is List) {
      for (var item in breakdownData) {
        if (item is Map) {
          final cat = (item["category"] ?? "").toString().toLowerCase();
          if (cat == categoryName.toLowerCase()) {
            return int.tryParse(
                  (item["total_eggs"] ??
                          item["count"] ??
                          item["total_eggs_expected"] ??
                          item["total_eggs_unloading"] ??
                          0)
                      .toString(),
                ) ??
                0;
          }
        }
      }
    } else if (breakdownData is Map) {
      for (var entry in breakdownData.entries) {
        if (entry.key.toString().toLowerCase() == categoryName.toLowerCase()) {
          return int.tryParse(entry.value.toString()) ?? 0;
        }
      }
    }
    return 0;
  }

  // ═══════════════════════════════════════════════
  // CATEGORY STOCK GRAPH PANEL
  // ═══════════════════════════════════════════════
  Widget _buildCategoryGraphPanel(BuildContext context) {
    if (selectedCategoryName == null) {
      return const SizedBox.shrink();
    }

  final inventoryLevels =
    List<Map<String, dynamic>>.from(
      inventoryStats["inventory_levels_by_category"] ?? [],
    );

    final category = inventoryLevels.firstWhere(
  (e) => e["category"] == selectedCategoryName,
  orElse: () => <String, dynamic>{},
);

final availableStock =
    (category["available"] ?? 0) as int;

final incomingStock =
    (category["incoming"] ?? 0) as int;

final damagedStock =
    (category["damaged"] ?? 0) as int;

    final values = [
     availableStock,
     incomingStock,
     damagedStock
    ];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 100.0 : (maxVal * 1.3);

    final barColors = [
    const Color.fromARGB(255, 30, 170, 2), // Available
    const Color(0xFF3B82F6), // Incoming
    const Color(0xFFEF4444),
  ];
    final barLabels = ["Available",
  "Incoming",
  "Damaged",];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Stock Analysis",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedCategoryName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        String label;
                        if (value >= 1000) {
                          label = '${(value / 1000).toStringAsFixed(1)}k';
                        } else {
                          label = value.toInt().toString();
                        }
                        return Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= barLabels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            barLabels[index],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${barLabels[group.x]}: ${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        color: barColors[i],
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: const Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(barLabels.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: barColors[i],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${barLabels[i]}: ${values[i].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget _buildActivityPanel(BuildContext context) {
  //   final alertItems = _buildAlerts(purchaseData);

  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 6,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Padding(
  //           padding: EdgeInsets.symmetric(vertical: 8),
  //           child: Text(
  //             "Recent Activity",
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF1E293B),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         if (alertItems.isEmpty)
  //           const Padding(
  //             padding: EdgeInsets.symmetric(vertical: 24),
  //             child: Center(
  //               child: Text(
  //                 "No recent activity",
  //                 style: TextStyle(color: Colors.grey, fontSize: 13),
  //               ),
  //             ),
  //           )
  //         else
  //           ListView.separated(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: alertItems.length,
  //             separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
  //             itemBuilder: (context, index) {
  //               final alert = alertItems[index];
  //               return Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.all(8),
  //                     decoration: BoxDecoration(
  //                       color: (alert["color"] as Color).withOpacity(0.12),
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: Icon(
  //                       alert["icon"] as IconData,
  //                       color: alert["color"] as Color,
  //                       size: 16,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           alert["title"].toString(),
  //                           style: const TextStyle(
  //                             fontSize: 13,
  //                             fontWeight: FontWeight.bold,
  //                             color: Color(0xFF1E293B),
  //                           ),
  //                         ),
  //                         const SizedBox(height: 4),
  //                         Row(
  //                           children: [
  //                             Expanded(
  //                               child: Text(
  //                                 alert["description"].toString(),
  //                                 style: const TextStyle(
  //                                   fontSize: 11,
  //                                   color: Color(0xFF64748B),
  //                                 ),
  //                                 maxLines: 1,
  //                                 overflow: TextOverflow.ellipsis,
  //                               ),
  //                             ),
  //                             const Text(" • ", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
  //                             Text(
  //                               alert["time"].toString(),
  //                               style: const TextStyle(
  //                                 fontSize: 11,
  //                                 color: Color(0xFF94A3B8),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPurchaseOrdersCard(BuildContext context) {
   final List<Map<String, dynamic>> displayedData =
    List<Map<String, dynamic>>.from(
      inventoryStats["purchase_records"] ?? [],
    );

final totalRecords = displayedData.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Incoming Stock Queue",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          _buildTableControls(context),
          const SizedBox(height: 16),
          if (_isLoading && purchaseData.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (displayedData.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  "No records found",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 56,
                ),
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(130),
                    1: FixedColumnWidth(160),
                    2: FixedColumnWidth(180),
                    3: FixedColumnWidth(120),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                      ),
                      children: [
                        _buildTableHeaderCell("Purchase Record"),
                        _buildTableHeaderCell("Supplier Details"),
                        _buildTableHeaderCell("Product & Quantity"),
                        _buildTableHeaderCell("Status"),
                      ],
                    ),
                    ...displayedData.map((row) {
                     final status =
    (row["purchase_status"] ?? "").toString().toUpperCase();

final isReceiveEnabled = status == "PURCHASED";

final isInTransit = status == "IN_TRANSIT";

                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PO-${row["po_id"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatDate(row["created_at"]),
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row["supplier_company_name"] ?? "N/A",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  row["supplier_location"] ?? "N/A",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Text(
                              (row["items"] as List).isNotEmpty
    ? "${row["items"][0]["category"]} (${row["items"][0]["trays"]} Trays)"
    : "N/A",
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: isReceiveEnabled
                                  ? ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReceiveStockScreen(id: row["po_id"],),
                                          ),
                                        ).then((_) => _loadData());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF3B82F6,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Receive Stock",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : isInTransit
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFFFEDD5),
                                        ),
                                      ),
                                      child: const Text(
                                        "In Transit",
                                        style: TextStyle(
                                          color: Color(0xFFEA580C),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        row["purchase_status"] ?? "",
                                        style: const TextStyle(
                                          color: Color(0xFF475569),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildPaginationControls(totalRecords),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTableControls(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final searchField = Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: (val) {
          setState(() {
            searchTerm = val;
            currentPage = 1;
          });
        },
        decoration: const InputDecoration(
          hintText: "Search PO, Supplier, or Driver...",
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          prefixIcon: Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );

    final supplierDropdown = Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSupplier,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Color(0xFF64748B),
          ),
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedSupplier = val;
                currentPage = 1;
              });
            }
          },
          items: [
            const DropdownMenuItem(value: "All", child: Text("All Suppliers")),
            ...suppliers.map(
              (sup) => DropdownMenuItem(value: sup.id, child: Text(sup.name)),
            ),
          ],
        ),
      ),
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: searchField),
          const SizedBox(width: 12),
          supplierDropdown,
        ],
      );
    } else {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: supplierDropdown),
        ],
      );
    }
  }

  Widget _buildPaginationControls(int totalRecords) {
    final startRecord = totalRecords == 0 ? 0 : indexOfFirst + 1;
    final endRecord = indexOfLast.clamp(0, totalRecords);

    final textInfo =
        "Showing $startRecord - $endRecord of $totalRecords records";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          textInfo,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: currentPage == 1 ? null : handlePrev,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                foregroundColor: const Color(0xFF334155),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: const Color(0xFFE2E8F0),
                    width: currentPage == 1 ? 0 : 1,
                  ),
                ),
              ),
              child: const Text(
                "Previous",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: currentPage >= totalPages ? null : handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                foregroundColor: const Color(0xFF334155),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: const Color(0xFFE2E8F0),
                    width: currentPage >= totalPages ? 0 : 1,
                  ),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
