import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/admin/presentation/receive_stockscreen.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_incoming_stock_queue_skeleton_loader.dart';
import 'package:proteinova_connect/features/admin/widget/incoming_widget.dart';
import '../inventory/data/inventory_repository.dart';
import '../inventory/models/inventory_model.dart';

class IncomingStock extends StatefulWidget {
  const IncomingStock({super.key});

  @override
  State<IncomingStock> createState() => _IncomingStockState();
}

class _IncomingStockState extends State<IncomingStock> {
  final InventoryRepository _repository = InventoryRepository();
  List<PurchaseModel> purchases = [];
  String searchQuery = "";
  String selectedStatus = "All Status";
  String selectedSupplier = "All Suppliers";
  AdminInventoryModel? inventoryModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      // Fetch admin metrics and purchases
      final data = await _repository.fetchInventoryData();
      final purchasesList = await _repository.fetchPurchases();

      setState(() {
        inventoryModel = data;
        purchases = purchasesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Connection Error: $e")));
      }
    }
  }

  Future<void> _receiveStock(int dispatchId) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReceiveStockScreen(id: dispatchId)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // Future<void> _markArrival(int dispatchId) async {
  //   try {
  //     // Using branchId 1 as default
  //     await _repository.markArrival(1, dispatchId);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Arrival marked successfully")),
  //       );
  //     }
  //     _fetchData();
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Error: $e")));
  //     }
  //   }
  // }

  List<PurchaseModel> get _filteredPurchases {
    List<PurchaseModel> list = purchases;

    // Filter by Search Query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      list = list.where((p) {
        return p.poNumber.toLowerCase().contains(query) ||
            p.supplierName.toLowerCase().contains(query) ||
            p.productName.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by Status
    if (selectedStatus != "All Status") {
      final todayStr = DateTime.now()
          .toLocal()
          .toIso8601String()
          .split('T')
          .first;

      if (selectedStatus == "Expected Today") {
        list = list
            .where((p) => p.arrivalDate.split('T').first == todayStr)
            .toList();
      } else if (selectedStatus == "Ready for Unloading") {
        list = list
            .where(
              (p) =>
                  p.status.toUpperCase() == "ARRIVAL" ||
                  p.status.toUpperCase() == "PURCHASED",
            )
            .toList();
      } else if (selectedStatus == "In Transit") {
        list = list.where((p) {
          if (p.arrivalDate.isEmpty) return false;
          return p.arrivalDate.split('T').first.compareTo(todayStr) > 0 &&
              p.status.toUpperCase() != "RECEIVED";
        }).toList();
      } else if (selectedStatus == "Delayed") {
        list = list.where((p) {
          if (p.arrivalDate.isEmpty) return false;
          return p.arrivalDate.split('T').first.compareTo(todayStr) < 0 &&
              p.status.toUpperCase() != "RECEIVED";
        }).toList();
      } else {
        final filterStatus = selectedStatus.toUpperCase().replaceAll(' ', '_');
        list = list
            .where((p) => p.status.toUpperCase() == filterStatus)
            .toList();
      }
    }

    // Filter by Supplier
    if (selectedSupplier != "All Suppliers") {
      list = list
          .where(
            (p) =>
                p.supplierName.toUpperCase() == selectedSupplier.toUpperCase(),
          )
          .toList();
    }

    return list;
  }

  int get _expectedTodayShipments {
    final today = DateTime.now().toLocal();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return purchases
        .where((p) => p.arrivalDate.split('T').first == todayStr)
        .length;
  }

  int get _expectedTodayEggs {
    final today = DateTime.now().toLocal();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return purchases
        .where((p) => p.arrivalDate.split('T').first == todayStr)
        .fold(0, (sum, p) => sum + p.totalQuantity);
  }

  int get _readyForUnloadingShipments {
    return purchases
        .where(
          (p) =>
              p.status.toUpperCase() == "ARRIVAL" ||
              p.status.toUpperCase() == "READY_FOR_UNLOADING",
        )
        .length;
  }

  int get _upcomingShipments {
    final today = DateTime.now().toLocal();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return purchases.where((p) {
      if (p.arrivalDate.isEmpty) return false;
      final arrivalStr = p.arrivalDate.split('T').first;
      return arrivalStr.compareTo(todayStr) > 0;
    }).length;
  }

  void _showShipmentModal(String title, List<PurchaseModel> filteredPurchases) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$title Details",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredPurchases.isEmpty
                      ? const Center(child: Text("No shipments found"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 650,
                            child: ListView.builder(
                              itemCount: filteredPurchases.length,
                              itemBuilder: (context, index) {
                                final p = filteredPurchases[index];
                                return buildTableRow(
                                  po: p.poNumber,
                                  date: _formatDate(p.createdAt),
                                  supplier: p.supplierName,
                                  location: p.location,
                                  quantity: "${p.totalQuantity} Eggs",
                                  type: p.productName,
                                  status: p.status,
                                  isReceive:
                                      p.status.toUpperCase() != "RECEIVED",
                                  onReceive: () {
                                    Navigator.pop(context);
                                    _receiveStock(p.id);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterMenu(
    BuildContext context,
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Filter",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    return ListTile(
                      title: Text(
                        opt,
                        style: TextStyle(
                          color: opt == selected ? Colors.blue : Colors.black,
                          fontWeight: opt == selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: opt == selected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        onSelect(opt);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(isoDate).toLocal();
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
      final day = date.day;
      final month = months[date.month - 1];
      final year = date.year;
      int hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'pm' : 'am';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      final hourStr = hour.toString().padLeft(2, '0');
      return "$day $month $year - $hourStr:$minute $ampm";
    } catch (e) {
      return isoDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: AdminIncomingStockQueueSkeletonLoader()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      body: RefreshIndicator(
        onRefresh: _fetchData,

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// TOP BAR
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: Color(0xff111827),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      "Incoming Stock Queue",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  "Manage and receive incoming shipments from suppliers to update inventory.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                /// CARDS
                GestureDetector(
                  onTap: () {
                    final today = DateTime.now().toLocal();
                    final todayStr =
                        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
                    _showShipmentModal(
                      "Expected Today",
                      purchases
                          .where(
                            (p) => p.arrivalDate.split('T').first == todayStr,
                          )
                          .toList(),
                    );
                  },
                  child: buildOverviewCard(
                    title: "Expected Today",
                    value: "$_expectedTodayShipments Shipments",
                    subtitle: "Totaling $_expectedTodayEggs eggs",
                    icon: Icons.event_available_outlined,
                    iconBg: const Color(0xFFF2F2F2),
                  ),
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () {
                    _showShipmentModal(
                      "Ready for Unloading",
                      purchases.where((p) {
                        final status = p.status.toUpperCase();
                        return status == "ARRIVAL" || status == "PURCHASED";
                      }).toList(),
                    );
                  },
                  child: buildOverviewCard(
                    title: "Ready for Unloading",
                    value: "$_readyForUnloadingShipments Shipments",
                    subtitle: "Requires immediate actions",
                    icon: Icons.local_shipping_outlined,
                    iconBg: Colors.green,
                    iconColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () {
                    final today = DateTime.now().toLocal();
                    final todayStr =
                        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
                    _showShipmentModal(
                      "Upcoming Shipments",
                      purchases.where((p) {
                        if (p.arrivalDate.isEmpty) return false;
                        final arrivalStr = p.arrivalDate.split('T').first;
                        return arrivalStr.compareTo(todayStr) > 0;
                      }).toList(),
                    );
                  },
                  child: buildOverviewCard(
                    title: "Upcoming Shipments",
                    value: "$_upcomingShipments Shipments",
                    subtitle: "Next scheduled deliveries",
                    icon: Icons.send_outlined,
                    iconBg: Colors.blue,
                    iconColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                /// SEARCH BAR
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(color: Colors.grey.shade300),
                //   ),
                //   child: TextField(
                //     style: const TextStyle(fontSize: 13),
                //     onChanged: (value) {
                //       setState(() {
                //         searchQuery = value;
                //       });
                //     },
                //     decoration: const InputDecoration(
                //       border: InputBorder.none,
                //       icon: Icon(Icons.search, size: 18),
                //       hintText: "Search PO, Supplier, or Product...",
                //       hintStyle: TextStyle(fontSize: 12),
                //     ),
                //   ),
                // ),

                /// FILTERS
                Row(
                  children: [
                    Expanded(
                      child: buildFilterBox(
                        icon: Icons.calendar_month_outlined,
                        text: selectedStatus == "All Status"
                            ? "Status: All"
                            : "Status: $selectedStatus",
                        onTap: () {
                          final statuses = [
                            "All Status",
                            "Expected Today",
                            "Ready for Unloading",
                            "Purchased",
                            "In Transit",
                            "Received",
                            "Delayed",
                          ];
                          _showFilterMenu(context, statuses, selectedStatus, (
                            val,
                          ) {
                            setState(() => selectedStatus = val);
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: buildFilterBox(
                        icon: Icons.home_outlined,
                        text: selectedSupplier,
                        onTap: () {
                          final suppliers = [
                            "All Suppliers",
                            ...purchases
                                .map((p) => p.supplierName)
                                .toSet()
                                .toList(),
                          ];
                          _showFilterMenu(
                            context,
                            suppliers,
                            selectedSupplier,
                            (val) {
                              setState(() => selectedSupplier = val);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 6),

                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedStatus = "All Status";
                          selectedSupplier = "All Suppliers";
                          searchQuery = "";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.tune, size: 18),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// TABLE HEADER
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 650,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        /// HEADER
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "PURCHASE RECORD",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Text(
                                "SUPPLIER DETAILS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Text(
                                "PRODUCT & QUANTITY",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                "STATUS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: Text(
                                "ACTION",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// ROWS
                        ..._filteredPurchases.map(
                          (purchase) => buildTableRow(
                            po: purchase.poNumber,
                            date: _formatDate(purchase.createdAt),
                            supplier: purchase.supplierName,
                            location: purchase.location,
                            quantity: "${purchase.totalQuantity} Eggs",
                            type: purchase.productName,
                            status: purchase.status,
                            isReceive:
                                purchase.status.toUpperCase() == "PURCHASED" ||
                                purchase.status.toUpperCase() == "ARRIVAL",
                            onReceive: () => _receiveStock(purchase.id),
                          ),
                        ),

                        if (_filteredPurchases.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "No records found matching your search",
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
