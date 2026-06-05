import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/admin/skeletonloader/admin_incoming_stock_queue_skeleton_loader.dart';
import 'package:proteinova_connect/features/admin/widget/incoming_widget.dart';
import '../inventory/data/inventory_repository.dart';
import '../inventory/models/inventory_model.dart';

class IncomingStockMain extends StatelessWidget {
  const IncomingStockMain({super.key});

  @override
  Widget build(BuildContext context) {
    return const IncomingStock();
  }
}

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

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
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

  List<PurchaseModel> get _activePurchases {
    return purchases.where((p) {
      final pStatus = p.purchaseStatus.toUpperCase();
      return pStatus != "RECEIVED" && pStatus != "CANCELLED";
    }).toList();
  }

  List<PurchaseModel> get _filteredPurchases {
    List<PurchaseModel> list = _activePurchases;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      list = list.where((p) {
        return p.poNumber.toLowerCase().contains(query) ||
            p.supplierName.toLowerCase().contains(query) ||
            p.productName.toLowerCase().contains(query);
      }).toList();
    }

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
                  p.purchaseStatus.toUpperCase() == "PURCHASED" &&
                  p.movementStatus.toUpperCase() == "RECEIVED",
            )
            .toList();
      } else if (selectedStatus == "In Transit") {
        list = list.where((p) {
          if (p.arrivalDate.isEmpty) return false;
          return p.arrivalDate.split('T').first.compareTo(todayStr) > 0 &&
              p.purchaseStatus.toUpperCase() != "RECEIVED";
        }).toList();
      } else if (selectedStatus == "Delayed") {
        list = list.where((p) {
          if (p.arrivalDate.isEmpty) return false;
          return p.arrivalDate.split('T').first.compareTo(todayStr) < 0 &&
              p.purchaseStatus.toUpperCase() != "RECEIVED";
        }).toList();
      } else {
        final filterStatus = selectedStatus.toUpperCase().replaceAll(' ', '_');
        list = list
            .where((p) => p.purchaseStatus.toUpperCase() == filterStatus)
            .toList();
      }
    }

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
    return _activePurchases
        .where((p) => p.arrivalDate.split('T').first == todayStr)
        .length;
  }

  int get _expectedTodayEggs {
    final today = DateTime.now().toLocal();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return _activePurchases
        .where((p) => p.arrivalDate.split('T').first == todayStr)
        .fold(0, (sum, p) => sum + p.totalQuantity);
  }

  int get _readyForUnloadingShipments {
    return _activePurchases
        .where(
          (p) =>
              p.purchaseStatus.toUpperCase() == "PURCHASED" &&
              p.movementStatus.toUpperCase() == "RECEIVED",
        )
        .length;
  }

  int get _upcomingShipments {
    final today = DateTime.now().toLocal();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return _activePurchases.where((p) {
      if (p.arrivalDate.isEmpty) return false;
      final arrivalStr = p.arrivalDate.split('T').first;
      return arrivalStr.compareTo(todayStr) > 0;
    }).length;
  }

  List<PurchaseModel> get _vehicleTransactionsList {
    return purchases.where((p) {
      return p.vehicleNumber.isNotEmpty ||
          p.driverName.isNotEmpty ||
          p.driverPhone.isNotEmpty;
    }).toList();
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
                                  color: Colors.grey),
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
                                      horizontal: 10, vertical: 6),
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

  void _showVehicleModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int page = 1;
        const int recordsPerPage = 10;
        String search = "";
        String statusFilter = "";

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _vehicleTransactionsList.where((p) {
              final searchMatch = p.vehicleNumber
                      .toLowerCase()
                      .contains(search.toLowerCase()) ||
                  p.driverName.toLowerCase().contains(search.toLowerCase()) ||
                  p.supplierName.toLowerCase().contains(search.toLowerCase());

              final statusMatch = statusFilter.isEmpty ||
                  p.movementStatus.toUpperCase() ==
                      statusFilter.toUpperCase() ||
                  p.purchaseStatus.toUpperCase() == statusFilter.toUpperCase();

              return searchMatch && statusMatch;
            }).toList();

            final totalPages = (filtered.length / recordsPerPage).ceil();
            final startIndex = (page - 1) * recordsPerPage;
            final endIndex = startIndex + recordsPerPage;
            final currentRecords = filtered.sublist(
              startIndex,
              endIndex > filtered.length ? filtered.length : endIndex,
            );

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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vehicle Transaction Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0F172A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "All incoming vehicle movements and logistics information",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:
                              const Icon(Icons.close, color: Color(0xff64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xffF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setModalState(() {
                                  search = value;
                                  page = 1;
                                });
                              },
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    "Search Vehicle No, Driver, or Supplier...",
                                hintStyle: TextStyle(fontSize: 12),
                                icon: Icon(Icons.search, size: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: statusFilter.isEmpty ? null : statusFilter,
                              hint: const Text("All Statuses",
                                  style: TextStyle(fontSize: 12)),
                              items: const [
                                DropdownMenuItem(
                                    value: "",
                                    child: Text("All Statuses",
                                        style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(
                                    value: "ARRIVAL",
                                    child: Text("Arrived",
                                        style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(
                                    value: "RECEIVED",
                                    child: Text("Ready for Unloading",
                                        style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(
                                    value: "UNLOADED",
                                    child: Text("Unloaded",
                                        style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(
                                    value: "IN_TRANSIT",
                                    child: Text("In Transit",
                                        style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(
                                    value: "PENDING",
                                    child: Text("Pending",
                                        style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (value) {
                                setModalState(() {
                                  statusFilter = value ?? "";
                                  page = 1;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: currentRecords.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: 48,
                                  color: Color(0xffCBD5E1),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "No vehicle transactions found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff64748B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Try adjusting your search or filter.",
                                  style: TextStyle(
                                      color: Color(0xff94A3B8), fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            itemCount: currentRecords.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, idx) {
                              final p = currentRecords[idx];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.vehicleNumber.isEmpty
                                              ? "N/A"
                                              : p.vehicleNumber,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xff0F172A)),
                                        ),
                                        Text(
                                          p.vehicleType.isEmpty
                                              ? "Unknown Type"
                                              : p.vehicleType,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xff64748B)),
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
                                          p.driverName.isEmpty
                                              ? "N/A"
                                              : p.driverName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Color(0xff334155)),
                                        ),
                                        Text(
                                          p.driverPhone.isEmpty
                                              ? "No Contact"
                                              : p.driverPhone,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xff94A3B8)),
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
                                          p.supplierName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xff0F172A)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "PO-${p.id}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xff3B82F6),
                                              fontWeight: FontWeight.w500),
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
                                          "${p.totalQuantity} Eggs",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xff0F172A)),
                                        ),
                                        Text(
                                          p.warehouseLocation.isEmpty
                                              ? "No Location"
                                              : p.warehouseLocation,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xff64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatDate(p.createdAt)
                                              .split(' - ')
                                              .first,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Color(0xff475569)),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF3F4F6),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            (p.movementStatus.isNotEmpty
                                                    ? p.movementStatus
                                                    : (p.purchaseStatus
                                                            .isNotEmpty
                                                        ? p.purchaseStatus
                                                        : "PENDING"))
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff374151)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Showing ${filtered.isEmpty ? 0 : startIndex + 1} to ${endIndex > filtered.length ? filtered.length : endIndex} of ${filtered.length} records",
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xff64748B)),
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: page == 1
                                  ? null
                                  : () {
                                      setModalState(() {
                                        page--;
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Previous",
                                  style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: page >= totalPages
                                  ? null
                                  : () {
                                      setModalState(() {
                                        page++;
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Next",
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
                    _showShipmentModal(
                      "Expected Today",
                      _expectedTodayList,
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
                      _readyForUnloadingList,
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
                    _showShipmentModal(
                      "Upcoming Shipments",
                      _upcomingList,
                    );
                  },
                ),

                const SizedBox(height: 14),

                buildOverviewCard(
                  title: "Vehicle Transactions",
                  value: "${_vehicleTransactionsList.length} Transactions",
                  subtitle: "All incoming vehicle movements",
                  icon: Icons.local_shipping,
                  iconBg: const Color(0xffF59E0B),
                  iconColor: Colors.white,
                  onTap: () {
                    _showVehicleModal();
                  },
                ),

                const SizedBox(height: 16),

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
                          _showFilterMenu(context, statuses, selectedStatus,
                              (val) {
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
                            return InkWell(
                              onTap: () => _receiveStock(p.id),
                              child: buildTableRow(
                                po: "PO-${p.poNumber}",
                                date: _formatDate(p.createdAt),
                                supplier: p.supplierName,
                                location:
                                    p.location.isEmpty ? "N/A" : p.location,
                                quantity: "${p.totalQuantity} Eggs",
                                type: p.productName,
                                purchaseStatus: p.purchaseStatus,
                                movementStatus: p.movementStatus,
                                onReceive: () => _receiveStock(p.id),
                                onMarkArrival: () => _markArrival(p.id),
                              ),
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

  List<PurchaseModel> get _expectedTodayList {
    final today = DateTime.now().toLocal();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return _activePurchases
        .where((p) => p.arrivalDate.split('T').first == todayStr)
        .toList();
  }

  List<PurchaseModel> get _readyForUnloadingList {
    return _activePurchases
        .where(
          (p) =>
              p.purchaseStatus.toUpperCase() == "PURCHASED" &&
              p.movementStatus.toUpperCase() == "RECEIVED",
        )
        .toList();
  }

  List<PurchaseModel> get _upcomingList {
    final today = DateTime.now().toLocal();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return _activePurchases.where((p) {
      if (p.arrivalDate.isEmpty) return false;
      final arrivalStr = p.arrivalDate.split('T').first;
      return arrivalStr.compareTo(todayStr) > 0;
    }).toList();
  }
}

class ReceiveStockScreen extends StatefulWidget {
  final int id;

  const ReceiveStockScreen({super.key, required this.id});

  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  final InventoryRepository _repository = InventoryRepository();

  Map<String, dynamic>? purchase;
  bool isLoading = true;
  bool isSubmitting = false;

  List<Map<String, dynamic>> trayDetails = [];

  List<TextEditingController> _receivedControllers = [];
  List<TextEditingController> _damagedControllers = [];
  List<TextEditingController> _notesControllers = [];
  final TextEditingController _mainNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPurchase();
  }

  @override
  void dispose() {
    for (var controller in _receivedControllers) {
      controller.dispose();
    }
    for (var controller in _damagedControllers) {
      controller.dispose();
    }
    for (var controller in _notesControllers) {
      controller.dispose();
    }
    _mainNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchPurchase() async {
    try {
      final data = await _repository.fetchPurchaseById(widget.id);

      final items = data['items'] ?? [];

      trayDetails = items.map<Map<String, dynamic>>((item) {
        final trays = int.tryParse(item['trays'].toString()) ?? 0;
        final capacity = int.tryParse(item['capacity'].toString()) ?? 30;

        final eggs = trays * capacity;

        return {
          "product": item['egg_category_grade'] ?? "",
          "trayType": item['tray_type'] ?? "",
          "received": eggs,
          "damaged": 0,
          "good": eggs,
          "notes": "",
        };
      }).toList();

      // Initialize Text Editing Controllers
      _receivedControllers = trayDetails
          .map((detail) =>
              TextEditingController(text: detail['received'].toString()))
          .toList();
      _damagedControllers = trayDetails
          .map((detail) =>
              TextEditingController(text: detail['damaged'].toString()))
          .toList();
      _notesControllers = trayDetails
          .map((detail) => TextEditingController(text: detail['notes']))
          .toList();

      setState(() {
        purchase = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching purchase: $e")),
        );
      }
    }
  }

  void _updateTrayReceived(int index, String value) {
    final intValue = int.tryParse(value) ?? 0;
    setState(() {
      trayDetails[index]['received'] = intValue;
      final damaged = trayDetails[index]['damaged'] as int;
      trayDetails[index]['good'] = intValue - damaged;
    });
  }

  void _updateTrayDamaged(int index, String value) {
    final intValue = int.tryParse(value) ?? 0;
    setState(() {
      trayDetails[index]['damaged'] = intValue;
      final received = trayDetails[index]['received'] as int;
      trayDetails[index]['good'] = received - intValue;
    });
  }

  void _updateTrayNotes(int index, String value) {
    trayDetails[index]['notes'] = value;
  }

  Future<void> _confirmReceive() async {
    setState(() => isSubmitting = true);

    try {
      final itemsToPost = trayDetails.map((detail) {
        return {
          "egg_category_grade": detail['product'],
          "damaged_eggs": int.tryParse(detail['damaged'].toString()) ?? 0,
          "received_eggs": int.tryParse(detail['received'].toString()) ?? 0,
        };
      }).toList();

      await _repository.receiveStock(widget.id, itemsToPost);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock received successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error confirming receive: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final items = purchase?['items'] ?? [];
    final totalTrays = (items as List).fold<int>(
        0, (sum, item) => sum + (int.tryParse(item['trays'].toString()) ?? 0));
    final totalEggs = items.fold<int>(
        0,
        (sum, item) =>
            sum +
            ((int.tryParse(item['trays'].toString()) ?? 0) *
                (int.tryParse(item['capacity'].toString()) ?? 30)));

    final double itemsTotal = items.fold<double>(0, (sum, item) {
      final trays = double.tryParse(item['trays'].toString()) ?? 0;
      final capacity = double.tryParse(item['capacity'].toString()) ?? 30;
      final price = double.tryParse(item['per_egg_price'].toString()) ?? 0;
      return sum + (trays * capacity * price);
    });

    final List expenses = purchase?['expenses'] ?? [];

    final double otherCharge = expenses
        .where(
            (e) => e['expense_type']?.toString().toUpperCase() != "TRANSPORT")
        .fold<double>(
            0,
            (sum, e) =>
                sum + (double.tryParse(e['amount'].toString()) ?? 0.0));

    final double totalAmount = itemsTotal + otherCharge;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(),
                    const SizedBox(height: 30),

                    /// INFO GRID
                    LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: isWide ? 1 : 1,
                                  child: _buildInfoCard()),
                              if (isWide) const SizedBox(width: 20),
                              if (isWide)
                                Expanded(
                                    flex: 2,
                                    child: _buildItemsCard(
                                        items, itemsTotal, totalTrays, totalEggs)),
                              if (isWide) const SizedBox(width: 20),
                              if (isWide)
                                Expanded(
                                    flex: 1,
                                    child: _buildSummaryCard(
                                        totalTrays, totalEggs, items)),
                            ],
                          ),
                          if (!isWide) ...[
                            const SizedBox(height: 20),
                            _buildItemsCard(
                                items, itemsTotal, totalTrays, totalEggs),
                            const SizedBox(height: 20),
                            _buildSummaryCard(totalTrays, totalEggs, items),
                          ]
                        ],
                      );
                    }),

                    const SizedBox(height: 30),

                    /// TRAY DETAILS & BILL SUMMARY
                    LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildTrayDetailsCard()),
                          if (isWide) const SizedBox(width: 20),
                          if (isWide)
                            Expanded(
                                flex: 1,
                                child: _buildBillSummaryCard(items.length,
                                    itemsTotal, otherCharge, totalAmount)),
                        ],
                      );
                    }),

                    if (MediaQuery.of(context).size.width <= 900) ...[
                      const SizedBox(height: 20),
                      _buildBillSummaryCard(items.length, itemsTotal,
                          otherCharge, totalAmount),
                    ],

                    const SizedBox(height: 30),
                    _buildNotesAndActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "Incoming Stock Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xffFEF3C7),
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.amber),
                SizedBox(width: 6),
                Text("Role: Admin",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: getWidth(context, 12),
          runSpacing: getHeight(context, 8),
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Receive Stock: ",
                    style: TextStyle(
                      fontSize: getWidth(context, 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: "PO-${purchase?['id']}",
                    style: TextStyle(
                      fontSize: getWidth(context, 24),
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(context, 12),
                vertical: getHeight(context, 4),
              ),
              decoration: BoxDecoration(
                color: const Color(0xff16A34A),
                borderRadius: BorderRadius.circular(
                  getWidth(context, 8),
                ),
              ),
              child: Text(
                "Ready for Unload",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getWidth(context, 12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
            "Manage and receive incoming shipments from suppliers to update inventory",
            style: TextStyle(color: Color(0xff6B7280), fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Received Info",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 40),
          _infoRow("Receive No.", "${purchase?['id']}"),
          _infoRow("Purchase Date",
              purchase?['created_at']?.split('T').first ?? "N/A"),
          _infoRow("Vehicle No.", purchase?['vehicle_number'] ?? "N/A"),
          _infoRow("Driver Name", purchase?['driver_name'] ?? "N/A"),
          _infoRow("Broker Name", purchase?['broker_name'] ?? "N/A"),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xffF9FAFB),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("From Supplier",
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(purchase?['supplier_company_name'] ?? "N/A",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff6B7280),
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildItemsCard(
      List items, double itemsTotal, int totalTrays, int totalEggs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Received Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 40),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final trays = int.tryParse(item['trays'].toString()) ?? 0;
            final capacity = int.tryParse(item['capacity'].toString()) ?? 30;
            final eggs = trays * capacity;
            final price =
                double.tryParse(item['per_egg_price'].toString()) ?? 0;
            final totalPrice = eggs * price;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['egg_category_grade'] ?? "N/A",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xffE0E7FF),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(item['tray_type'] ?? "N/A",
                            style: const TextStyle(
                                color: Color(0xff4338CA),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Trays",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("$trays",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Eggs",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("$eggs",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Price/Egg",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("₹${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Price",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹${totalPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff16A34A),
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xffFEF9C3),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Grand Total",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("$totalTrays Trays / $totalEggs Eggs",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54)),
                    Text("₹${itemsTotal.toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalTrays, int totalEggs, List items) {
    final trayTypeSummary = <String, int>{};
    for (var item in items) {
      final type = item['tray_type'] ?? "Other";
      final count = int.tryParse(item['trays'].toString()) ?? 0;
      trayTypeSummary[type] = (trayTypeSummary[type] ?? 0) + count;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.description_outlined, color: Color(0xff6B7280)),
            ],
          ),
          const Divider(height: 40),
          _summaryRow("Total Trays", "$totalTrays"),
          _summaryRow("Total Eggs", "$totalEggs"),
          ...trayTypeSummary.entries
              .map((e) => _summaryRow(e.key, "${e.value}"))
              .toList(),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xff6B7280))),
          Text(value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrayDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tray Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...trayDetails.asMap().entries.map((entry) {
            final idx = entry.key;
            final detail = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(detail['product'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xffE0E7FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(detail['trayType'],
                            style: const TextStyle(
                                color: Color(0xff4338CA),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Received",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _receivedControllers[idx],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (v) => _updateTrayReceived(idx, v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Damaged",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _damagedControllers[idx],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (v) => _updateTrayDamaged(idx, v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Good",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                  color: const Color(0xffDCFCE7),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text("${detail['good']}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Color(0xff166534),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesControllers[idx],
                    decoration: InputDecoration(
                      hintText: "Add notes...",
                      hintStyle:
                          const TextStyle(fontSize: 13, color: Colors.grey),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (v) => _updateTrayNotes(idx, v),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    "Damage trays will not be added to your usable stock.",
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(int itemCount, double itemsTotal,
      double otherCharge, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bill Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 40),
          _summaryRow(
              "Items ($itemCount)", "₹${itemsTotal.toStringAsFixed(0)}"),
          _summaryRow("Other Charge", "₹${otherCharge.toStringAsFixed(0)}"),
          const Divider(height: 40, color: Colors.black),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("₹${totalAmount.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesAndActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Notes",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _mainNotesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Enter any additional notes...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffE5E7EB))),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Cancel",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _confirmReceive,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFEF3C7),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 20),
                          SizedBox(width: 8),
                          Text("Confirm Receive",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
