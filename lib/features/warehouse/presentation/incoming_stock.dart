import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/features/warehouse/presentation/receive_stock_screen.dart';
import 'package:proteinova_connect/features/warehouse/skeletonloader/incoming_stock_skeleton_loader.dart';
import 'package:proteinova_connect/features/warehouse/widget/incoming_widget.dart';
import 'package:proteinova_connect/features/warehouse/inventory/data/models/inventory_model.dart';
import 'package:proteinova_connect/features/warehouse/inventory/data/inventory_repository.dart';


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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReceiveStockScreen(id: dispatchId)),
    ).then((_) => _fetchData());
  }

  Future<void> _markArrival(int dispatchId) async {
    try {
      await _repository.markArrival(dispatchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Purchase marked as ARRIVED successfully!"),
          ),
        );
      }
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

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
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$title Details",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "View comprehensive shipment data for this category",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xff64748B),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xff64748B)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filteredPurchases.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No shipments found",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "There are currently no records for this specific category.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredPurchases.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final p = filteredPurchases[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _receiveStock(p.id);
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "PO-${p.id}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xff475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.supplierName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xff0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.location.isEmpty
                                            ? "Location N/A"
                                            : p.location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xff334155),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Standard quality eggs",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.totalQuantity.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xff0F172A),
                                        ),
                                      ),
                                      const Text(
                                        "Total Eggs",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      p.arrivalDate.split('T').first,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Color(0xff475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Inventory Overview",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Role: Admin",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                buildOverviewCard(
                  title: "Expected Today",
                  value: "$_expectedTodayShipments Shipments",
                  subtitle: "Totaling $_expectedTodayEggs eggs",
                  icon: Icons.calendar_today_outlined,
                  iconBg: const Color(0xFFF1F6FF),
                  iconColor: Colors.black,
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
                ),

                const SizedBox(height: 14),

                buildOverviewCard(
                  title: "Ready for Unloading",
                  value: "$_readyForUnloadingShipments Shipments",
                  subtitle: "Requires immediate actions",
                  icon: Icons.local_shipping_outlined,
                  iconBg: const Color(0xff16A34A),
                  iconColor: Colors.white,
                  onTap: () {
                    _showShipmentModal(
                      "Ready for Unloading",
                      purchases.where((p) {
                        final status = p.status.toUpperCase();
                        return status == "ARRIVAL" || status == "PURCHASED";
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 14),

                buildOverviewCard(
                  title: "Upcoming Shipments",
                  value: "$_upcomingShipments Shipments",
                  subtitle: "Next scheduled deliveries",
                  icon: Icons.send_outlined,
                  iconBg: const Color(0xff0B74FF),
                  iconColor: Colors.white,
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

                /// TABLE
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      buildTableHeader(),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_filteredPurchases.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: Text("No records found")),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredPurchases.length,
                          itemBuilder: (context, index) {
                            final p = _filteredPurchases[index];
                            return buildTableRow(
                              po: "PO-${p.id}",
                              date: _formatDate(p.createdAt),
                              supplier: p.supplierName,
                              location: p.location.isEmpty ? "N/A" : p.location,
                              quantity: "${p.totalQuantity} Eggs",
                              type: p.productName,
                              purchaseStatus: p.purchaseStatus,
                              movementStatus: p.movementStatus,
                              onReceive: () => _receiveStock(p.id),
                              onMarkArrival: () => _markArrival(p.id),
                            );
                          },
                        ),
                    ],
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
