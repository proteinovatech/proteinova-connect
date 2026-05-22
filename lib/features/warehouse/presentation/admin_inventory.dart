import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_inventory_overview_skeleton_loader.dart';
import 'package:proteinova_connect/features/admin/widget/inventory_card.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/warehouse/inventory/data/models/inventory_model.dart';
import 'package:proteinova_connect/features/warehouse/inventory/data/inventory_repository.dart';


// Newly added imports for React compatibility
import 'package:proteinova_connect/features/admin/supplier/services/supplier_service.dart';
import 'package:proteinova_connect/features/admin/supplier/models/supplier_model.dart';
import 'package:proteinova_connect/features/admin/presentation/receive_stockscreen.dart';
import 'package:proteinova_connect/features/admin/menu/SalesDashboard/presentation/sales_entry_page.dart';

class AdminInventory extends StatefulWidget {
  const AdminInventory({super.key});

  @override
  State<AdminInventory> createState() => _AdminInventoryState();
}

class _AdminInventoryState extends State<AdminInventory> {
  final InventoryRepository _repository = InventoryRepository();
  final SupplierService _supplierService = SupplierService();

  // State matching React
  bool isFetching = true;
  String searchTerm = "";
  List<Supplier> suppliers = [];
  String selectedSupplier = "All";
  int currentPage = 1;
  final int recordsPerPage = 10;
  List<PurchaseModel> purchaseData = [];
  Map<String, dynamic> rawInventoryData = {};
  Map<String, dynamic> inventoryStats = {
    "expected_today": 0,
    "ready_for_unloading": 0,
    "delayed_in_transit": 0,
    "current_stock": 0,
    "damaged_trays": 0,
    "stock_value": 0.0,
    "category_stock": [],
    "breakdowns": {}
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isFetching = true);
    try {
      // Parallel fetch as in React: Promise.all
      final results = await Future.wait([
        _repository.fetchRawInventoryData(),
        _supplierService.getSuppliers(),
        _repository.fetchPurchases(),
      ]);

      final rawStats = results[0] as Map<String, dynamic>;
      final supplierList = results[1] as List<Supplier>;
      final purchasesList = results[2] as List<PurchaseModel>;

      setState(() {
        rawInventoryData = rawStats;
        suppliers = supplierList;
        purchaseData = purchasesList;

        // Inventory stats parsing
        inventoryStats = {
          "expected_today": int.tryParse(rawStats["expected_today"]?.toString() ?? "0") ?? 0,
          "ready_for_unloading": int.tryParse(rawStats["ready_for_unloading"]?.toString() ?? "0") ?? 0,
          "delayed_in_transit": int.tryParse(rawStats["delayed_in_transit"]?.toString() ?? "0") ?? 0,
          "current_stock": int.tryParse(rawStats["current_stock"]?.toString() ?? "0") ?? 0,
          "damaged_trays": int.tryParse((rawStats["damaged_trays"] ?? rawStats["damaged_stock"] ?? rawStats["damaged_eggs"])?.toString() ?? "0") ?? 0,
          "stock_value": double.tryParse(rawStats["stock_value"]?.toString() ?? "0") ?? 0.0,
          "category_stock": rawStats["category_stock"] is List ? rawStats["category_stock"] : [],
          "breakdowns": rawStats["breakdowns"] is Map<String, dynamic> ? rawStats["breakdowns"] : {},
        };

        isFetching = false;
      });
    } catch (e) {
      print("Error loading admin inventory: $e");
      setState(() => isFetching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching inventory data: $e")),
        );
      }
    }
  }

  // Filter logic matching React
  List<PurchaseModel> get filteredData {
    final search = searchTerm.toLowerCase();
    
    Supplier? selectedSupplierObj;
    if (selectedSupplier != "All") {
      try {
        selectedSupplierObj = suppliers.firstWhere((s) => s.id == selectedSupplier);
      } catch (_) {}
    }

    return purchaseData.where((row) {
      final poMatch = "po-${row.id}".toLowerCase().contains(search) || row.poNumber.toLowerCase().contains(search);
      
      final supplierName = row.supplierName.toLowerCase();
      final driverName = row.driverName.toLowerCase();
      
      final supplierMatch = supplierName.contains(search) || row.location.toLowerCase().contains(search);
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

  double getPercent(Map<String, dynamic> item) {
    final currentStock = inventoryStats["current_stock"] as int;
    if (currentStock == 0) return 0.0;
    
    final total = int.tryParse(item["total_eggs"]?.toString() ?? "0") ?? 0;
    return (total / currentStock);
  }

  String formatDate(String dateStr) {
    if (dateStr.isEmpty) return "No Date";
    try {
      final d = DateTime.parse(dateStr).toLocal();
      final day = d.day.toString().padLeft(2, '0');
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
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
      data = rawData;
    } else if (rawData is Map) {
      data = rawData.entries.map((e) => {
        "category": e.key.toString(),
        "total_eggs": int.tryParse(e.value.toString()) ?? 0,
        "revenue": double.tryParse(e.value.toString()) ?? 0.0,
        "total_value": double.tryParse(e.value.toString()) ?? 0.0,
      }).toList();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isCurrency = type == "currency";
        final isDamagedOrStock = title.toLowerCase().contains("stock") || title.toLowerCase().contains("damaged");
        final firstColumnHeader = isDamagedOrStock ? "Category" : "Supplier/Location";

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500),
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
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (data.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        "No detailed data available for this metric yet.",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1.2),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  firstColumnHeader,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 13),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Value",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 13),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          ...data.map((item) {
                            final categoryName = item is Map ? (item["category"] ?? "Unknown") : "Unknown";
                            
                            dynamic displayValue = "";
                            if (isCurrency) {
                              final val = item is Map ? (item["revenue"] ?? item["total_value"] ?? item["value"] ?? 0) : 0;
                              displayValue = "₹${double.tryParse(val.toString())?.toStringAsFixed(2) ?? val}";
                            } else {
                              final val = item is Map ? (item["total_eggs"] ?? item["total_eggs_expected"] ?? item["total_eggs_unloading"] ?? item["count"] ?? 0) : 0;
                              displayValue = "${int.tryParse(val.toString())?.toString() ?? val} Eggs";
                            }

                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    categoryName.toString(),
                                    style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    displayValue.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 13),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
    if (isFetching && purchaseData.isEmpty) {
      return const Scaffold(
        body: Center(child: AdminInventoryOverviewSkeletonLoader()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: Column(
            children: [
              if (isFetching)
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER CONTAINER
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(Icons.arrow_back, size: 24),
                                ),
                                SizedBox(width: getWidth(context, 12)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Inventory Overview",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: getHeight(context, 6)),
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
                                          const Icon(Icons.verified_user_outlined, size: 14),
                                          SizedBox(width: getWidth(context, 5)),
                                          Text(
                                            "Role: Warehouse & Admin",
                                            style: TextStyle(
                                              fontSize: getWidth(context, 11),
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
                          ],
                        ),
                      ),
                      
                      SizedBox(height: getHeight(context, 16)),

                      /// SUBHEADER SECTION (INCOMING QUEUE & ADD SALE)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SalesEntryPage(),
                                  ),
                                ).then((_) => _loadData());
                              },
                              icon: const Icon(Icons.add_circle_outline, size: 16),
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
                            onTap: () => _openDetailsModal("Expected Shipments Breakdown", inventoryStats["breakdowns"]["expected_today"], "count"),
                            child: InventoryCard(
                              title: "Expected Today",
                              value: "${inventoryStats['expected_today']} Shipments",
                              subtitle: "View detailed breakdown",
                              icon: Icons.calendar_today_outlined,
                              iconColor: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal("Ready for Unloading Breakdown", inventoryStats["breakdowns"]["ready_for_unloading"], "count"),
                            child: InventoryCard(
                              title: "Ready for Unloading",
                              value: "${inventoryStats['ready_for_unloading']} Shipments",
                              subtitle: "Requires immediate actions",
                              icon: Icons.local_shipping_outlined,
                              iconColor: Colors.green,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal("Delayed Shipments Breakdown", inventoryStats["breakdowns"]["delayed_in_transit"], "count"),
                            child: InventoryCard(
                              title: "Delayed in Transit",
                              value: "${inventoryStats['delayed_in_transit']} Shipments",
                              subtitle: "View delayed shipments",
                              icon: Icons.warning_amber_rounded,
                              iconColor: Colors.red,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal("Current Stock Breakdown", inventoryStats["breakdowns"]["current_stock"], "count"),
                            child: InventoryCard(
                              title: "Current Stock",
                              value: "${(inventoryStats['current_stock'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} units",
                              subtitle: "+2.4% from last week",
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.black87,
                              isPositive: true,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal("Damaged Stock Breakdown", inventoryStats["breakdowns"]["damaged_stock"] ?? inventoryStats["breakdowns"]["damaged_trays"], "count"),
                            child: InventoryCard(
                              title: "Damaged Stock",
                              value: "${(inventoryStats['damaged_trays'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Eggs",
                              subtitle: "0.6% damage rate (Target: < 1%)",
                              icon: Icons.warning_amber_rounded,
                              iconColor: Colors.red,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDetailsModal("Stock Value Breakdown", inventoryStats["breakdowns"]["stock_value"], "currency"),
                            child: InventoryCard(
                              title: "Stock Value",
                              value: "₹ ${(inventoryStats['stock_value'] as double).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                              subtitle: "Today's inventory valuation",
                              icon: Icons.currency_rupee,
                              iconColor: Colors.green,
                            ),
                          ),
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
    final activityPanel = _buildActivityPanel(context);
    
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: categoryPanel),
          const SizedBox(width: 16),
          Expanded(child: activityPanel),
        ],
      );
    } else {
      return Column(
        children: [
          categoryPanel,
          const SizedBox(height: 16),
          activityPanel,
        ],
      );
    }
  }

  Widget _buildCategoryPanel(BuildContext context) {
    final categoryStock = inventoryStats["category_stock"] as List<dynamic>;

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
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(color: Color(0xFF1E73FF), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
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
                final categoryName = item["category"] ?? "Unknown";
                final totalEggs = int.tryParse(item["total_eggs"]?.toString() ?? "0") ?? 0;
                final percent = getPercent(item);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryName.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 13),
                          ),
                          Text(
                            totalEggs.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityPanel(BuildContext context) {
    final alertItems = _buildAlerts(purchaseData);

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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (alertItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No recent activity",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alertItems.length,
              separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final alert = alertItems[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (alert["color"] as Color).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        alert["icon"] as IconData,
                        color: alert["color"] as Color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert["title"].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert["description"].toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text(" • ", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                              Text(
                                alert["time"].toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOrdersCard(BuildContext context) {
    final displayedData = currentData;
    final totalRecords = filteredData.length;

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
          if (isFetching && purchaseData.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (displayedData.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text("No records found", style: TextStyle(color: Colors.grey, fontSize: 13))),
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
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                      ),
                      children: [
                        _buildTableHeaderCell("Purchase Record"),
                        _buildTableHeaderCell("Supplier Details"),
                        _buildTableHeaderCell("Product & Quantity"),
                        _buildTableHeaderCell("Status"),
                      ],
                    ),
                    ...displayedData.map((row) {
                      final isReceiveEnabled = row.purchaseStatus.toUpperCase() == "PURCHASED" && row.movementStatus.toUpperCase() == "RECEIVED";
                      final isInTransit = row.purchaseStatus.toUpperCase() == "PURCHASED" && row.movementStatus.toUpperCase() == "IN_TRANSIT";
                      
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(formatDate(row.createdAt), style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row.supplierName.isNotEmpty ? row.supplierName : "N/A", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(row.location.isNotEmpty ? row.location : "N/A", style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text(row.productName.isNotEmpty ? row.productName : "N/A", style: const TextStyle(color: Color(0xFF334155), fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: isReceiveEnabled
                                  ? ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReceiveStockScreen(id: row.id),
                                          ),
                                        ).then((_) => _loadData());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3B82F6),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      child: const Text("Receive Stock", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    )
                                  : isInTransit
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF7ED),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFFFFEDD5)),
                                          ),
                                          child: const Text(
                                            "In Transit",
                                            style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            row.purchaseStatus.isNotEmpty ? row.purchaseStatus : "N/A",
                                            style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 11),
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
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12),
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
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
          style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w500),
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
            ...suppliers.map((sup) => DropdownMenuItem(
                  value: sup.id,
                  child: Text(sup.name),
                )),
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
    
    final textInfo = "Showing $startRecord - $endRecord of $totalRecords records";

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: const Color(0xFFE2E8F0), width: currentPage == 1 ? 0 : 1),
                ),
              ),
              child: const Text("Previous", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: currentPage >= totalPages ? null : handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                foregroundColor: const Color(0xFF334155),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: const Color(0xFFE2E8F0), width: currentPage >= totalPages ? 0 : 1),
                ),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}
