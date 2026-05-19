import 'package:flutter/material.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import '../data/purchase_expense_repository.dart';
import '../models/purchase_list_item.dart';
import '../models/purchase_detail_response.dart';
import '../models/supplier_item.dart';

class PurchaseExpenseScreen extends StatefulWidget {
  const PurchaseExpenseScreen({super.key});

  @override
  State<PurchaseExpenseScreen> createState() => _PurchaseExpenseScreenState();
}

class _PurchaseExpenseScreenState extends State<PurchaseExpenseScreen> {
  final PurchaseExpenseRepository _repository = PurchaseExpenseRepository();

  List<PurchaseListItem> _purchases = [];
  final Map<int, PurchaseDetailResponse> _purchaseDetails = {};
  List<SupplierItem> _suppliers = [];

  String _searchTerm = "";
  String _selectedSupplierId = "All";
  int _currentPage = 1;
  final int _recordsPerPage = 10;

  bool _isFetching = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isFetching = true;
    });

    try {
      // 1. Fetch purchases
      final purchasesData = await _repository.fetchPurchases();
      // 2. Fetch suppliers
      final suppliersData = await _repository.fetchSuppliers();

      if (mounted) {
        setState(() {
          _purchases = purchasesData;
          _suppliers = suppliersData;
          _isFetching = false;
        });
        // Start background loading of visible purchases details
        _loadVisibleDetails();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading data: $e"),
            backgroundColor: AppColors.redAccent,
          ),
        );
      }
    }
  }

  // Slice list of purchases based on search and supplier filters
  List<PurchaseListItem> _getFilteredPurchases() {
    return _purchases.where((item) {
      final searchLower = _searchTerm.toLowerCase();
      final poMatch = "po-${item.id}".toLowerCase().contains(searchLower);

      final supplierName = (item.supplierCompanyName ?? "").toLowerCase();
      final driverName = (item.driverName ?? "").toLowerCase();
      final location = (item.purchasedLocation ?? "").toLowerCase();

      final textMatch = poMatch ||
          supplierName.contains(searchLower) ||
          driverName.contains(searchLower) ||
          location.contains(searchLower);

      final supplierMatch = _selectedSupplierId == "All" ||
          item.supplierId?.toString() == _selectedSupplierId;

      return textMatch && supplierMatch;
    }).toList();
  }

  // Get current page purchases
  List<PurchaseListItem> _getCurrentPageData(List<PurchaseListItem> filtered) {
    final startIndex = (_currentPage - 1) * _recordsPerPage;
    if (startIndex >= filtered.length) return [];
    final endIndex = startIndex + _recordsPerPage;
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  // Background fetch details for visible items to populate Products, Trays, and Eggs
  void _loadVisibleDetails() {
    final filtered = _getFilteredPurchases();
    final visible = _getCurrentPageData(filtered);

    for (var item in visible) {
      if (!_purchaseDetails.containsKey(item.id)) {
        _repository.fetchPurchaseDetail(item.id).then((details) {
          if (mounted) {
            setState(() {
              _purchaseDetails[item.id] = details;
            });
          }
        }).catchError((err) {
          debugPrint("Failed to load details for PO-${item.id}: $err");
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "No Date";
    try {
      final parsed = DateTime.parse(dateStr);
      // Format like: 19 May 2026 • 10:15 AM
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      final day = parsed.day.toString().padLeft(2, '0');
      final month = months[parsed.month - 1];
      final year = parsed.year;
      
      final hourInt = parsed.hour > 12 ? parsed.hour - 12 : (parsed.hour == 0 ? 12 : parsed.hour);
      final amPm = parsed.hour >= 12 ? "PM" : "AM";
      final minute = parsed.minute.toString().padLeft(2, '0');
      
      return "$day $month $year • $hourInt:$minute $amPm";
    } catch (_) {
      return dateStr;
    }
  }

  String _getFormattedProducts(int id) {
    final details = _purchaseDetails[id];
    if (details == null) return "Loading...";
    final items = details.items ?? [];
    if (items.isEmpty) return "N/A";
    return items
        .map((i) => i.eggCategoryGrade)
        .where((name) => name != null && name.isNotEmpty)
        .join(", ");
  }

  int _getTotalTrays(int id) {
    final details = _purchaseDetails[id];
    if (details == null) return 0;
    final items = details.items ?? [];
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + (item.trays ?? 0));
  }

  int _getTotalEggs(int id) {
    final details = _purchaseDetails[id];
    if (details == null) return 0;
    final items = details.items ?? [];
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) {
      final trays = item.trays ?? 0;
      final capacity = item.capacity ?? 30;
      return sum + (trays * capacity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPurchases = _getFilteredPurchases();
    final currentPageData = _getCurrentPageData(filteredPurchases);
    final totalPages = (filteredPurchases.length / _recordsPerPage).ceil();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purchase Expenses",
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amber100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_user_outlined, size: 16, color: AppColors.amber800),
                SizedBox(width: 4),
                Text(
                  "Warehouse & Admin",
                  style: TextStyle(
                    color: AppColors.amber800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              color: AppColors.amber600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    const Text(
                      "Manage purchase expenses",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filters & Search section
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Search bar
                            TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchTerm = val;
                                  _currentPage = 1;
                                });
                                _loadVisibleDetails();
                              },
                              decoration: InputDecoration(
                                hintText: "Search PO, supplier, location, driver...",
                                hintStyle: const TextStyle(fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.amber600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Supplier select dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.store, color: AppColors.textSecondary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedSupplierId,
                                        isExpanded: true,
                                        style: const TextStyle(
                                          color: AppColors.dark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                            value: "All",
                                            child: Text("All Suppliers"),
                                          ),
                                          ..._suppliers.map((sup) {
                                            return DropdownMenuItem(
                                              value: sup.id.toString(),
                                              child: Text(sup.supplierCompanyName ?? "Supplier ${sup.id}"),
                                            );
                                          })
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedSupplierId = val;
                                              _currentPage = 1;
                                            });
                                            _loadVisibleDetails();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Purchase List Section
                    if (currentPageData.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            "No purchase records found",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentPageData.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final row = currentPageData[index];
                          final hasExpense = row.expenses != null && row.expenses!.isNotEmpty;
                          final totalTrays = _getTotalTrays(row.id);
                          final totalEggs = _getTotalEggs(row.id);
                          final products = _getFormattedProducts(row.id);

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // PO Number & Status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "PO-${row.id}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.containerColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          row.purchaseStatus ?? "N/A",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(row.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Divider(height: 24),

                                  // Supplier & Location info
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.business, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              row.supplierCompanyName ?? "N/A",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.dark,
                                              ),
                                            ),
                                            Text(
                                              row.supplierLocation ?? "N/A",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Product details
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.egg_outlined, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Product",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              products,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.dark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Quantity (Trays & Eggs)
                                  Row(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Quantity",
                                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                                Text(
                                                  "$totalTrays Trays",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: AppColors.dark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  "Total Eggs",
                                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                                Text(
                                                  "$totalEggs Eggs",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: AppColors.dark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),

                                  // Action Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // View button
                                      OutlinedButton(
                                        onPressed: () => _showViewPurchasePopup(row.id),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          side: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        child: const Text(
                                          "View Details",
                                          style: TextStyle(color: AppColors.dark, fontSize: 13),
                                        ),
                                      ),

                                      // Expense Add/Status
                                      hasExpense
                                          ? Row(
                                              children: const [
                                                Icon(Icons.check_circle, color: Colors.green, size: 18),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Expense Added",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : ElevatedButton(
                                              onPressed: () => _openAddExpenseModal(row, totalEggs),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.blueAccent,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "Add Expense",
                                                style: TextStyle(color: Colors.white, fontSize: 13),
                                              ),
                                            ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    // Pagination controls
                    if (filteredPurchases.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Showing ${((_currentPage - 1) * _recordsPerPage) + 1} - ${((_currentPage - 1) * _recordsPerPage) + currentPageData.length} of ${filteredPurchases.length}",
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                        _loadVisibleDetails();
                                      }
                                    : null,
                              ),
                              Text(
                                "$_currentPage / $totalPages",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < totalPages
                                    ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                        _loadVisibleDetails();
                                      }
                                    : null,
                              ),
                            ],
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- POPUP: VIEW DETAILS ---
  void _showViewPurchasePopup(int purchaseId) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return FutureBuilder<PurchaseDetailResponse>(
              future: _repository.fetchPurchaseDetail(purchaseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AlertDialog(
                    content: SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber600),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return AlertDialog(
                    title: const Text("Error"),
                    content: Text(snapshot.error?.toString() ?? "Failed to load purchase details"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  );
                }

                final details = snapshot.data!;

                // Calculations
                final totalEggs = details.items?.fold(0, (sum, i) => sum + ((i.trays ?? 0) * (i.capacity ?? 30))) ?? 0;
                final totalExpenses = details.expenses?.fold(0.0, (sum, e) => sum + (e.amount ?? 0.0)) ?? 0.0;
                final expensePerEgg = totalEggs > 0 ? (totalExpenses / totalEggs) : 0.0;

                final itemsAmount = details.items?.fold(0.0, (sum, i) {
                      final trays = i.trays ?? 0;
                      final capacity = i.capacity ?? 30;
                      final price = i.perEggPrice ?? 0.0;
                      return sum + (trays * capacity * price);
                    }) ??
                    0.0;

                final loading = details.loadingCharge ?? 0.0;
                final unloading = details.unloadingCharge ?? 0.0;
                final transport = details.transportCharge ?? 0.0;
                final misc = details.miscExpense ?? 0.0;
                final payableTotal = itemsAmount + loading + unloading + transport + misc;

                return Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Purchase Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.blueAccent,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          ),
                          const Divider(),

                          // Purchase invoice information
                          _buildDetailRow("PO Number", "PO-${details.id}"),
                          _buildDetailRow("Supplier", details.supplierCompanyName ?? "N/A"),
                          _buildDetailRow("Location", details.warehouseLocation ?? "N/A"),
                          _buildDetailRow("Date", _formatDate(details.createdAt)),

                          const SizedBox(height: 12),
                          const Text(
                            "Items",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueAccent),
                          ),
                          const SizedBox(height: 6),
                          Table(
                            border: TableBorder.all(color: Colors.grey.shade200, width: 1, borderRadius: BorderRadius.circular(4)),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: const [
                                  Padding(padding: EdgeInsets.all(8), child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8), child: Text("Trays", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                                  Padding(padding: EdgeInsets.all(8), child: Text("Price/Egg", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                                ],
                              ),
                              ...((details.items ?? []).map((item) {
                                return TableRow(
                                  children: [
                                    Padding(padding: const EdgeInsets.all(8), child: Text(item.eggCategoryGrade ?? "N/A", style: const TextStyle(fontSize: 12))),
                                    Padding(padding: const EdgeInsets.all(8), child: Text("${item.trays}", style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
                                    Padding(padding: const EdgeInsets.all(8), child: Text("₹${item.perEggPrice?.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
                                  ],
                                );
                              })),
                              if ((details.items ?? []).isEmpty)
                                const TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.all(8), child: Text("No items", style: TextStyle(fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(8), child: Text("-", textAlign: TextAlign.center)),
                                    Padding(padding: EdgeInsets.all(8), child: Text("-", textAlign: TextAlign.center)),
                                  ],
                                )
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Text(
                            "Expenses",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueAccent),
                          ),
                          const SizedBox(height: 6),
                          Table(
                            border: TableBorder.all(color: Colors.grey.shade200, width: 1, borderRadius: BorderRadius.circular(4)),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: const [
                                  Padding(padding: EdgeInsets.all(8), child: Text("Expense Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Padding(padding: EdgeInsets.all(8), child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                                ],
                              ),
                              ...((details.expenses ?? []).map((exp) {
                                return TableRow(
                                  children: [
                                    Padding(padding: const EdgeInsets.all(8), child: Text(exp.expenseType ?? "N/A", style: const TextStyle(fontSize: 12))),
                                    Padding(padding: const EdgeInsets.all(8), child: Text("₹${exp.amount?.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
                                  ],
                                );
                              })),
                              if ((details.expenses ?? []).isEmpty)
                                const TableRow(
                                  children: [
                                    Padding(padding: EdgeInsets.all(8), child: Text("No expenses added", style: TextStyle(fontSize: 12))),
                                    Padding(padding: EdgeInsets.all(8), child: Text("-", textAlign: TextAlign.center)),
                                  ],
                                )
                            ],
                          ),

                          const Divider(height: 24),
                          _buildDetailRow("Total Eggs", "$totalEggs"),
                          _buildDetailRow("Expense per Egg", "₹${expensePerEgg.toStringAsFixed(2)}"),
                          _buildDetailRow("Payment Method", details.paymentMethod ?? "N/A"),
                          _buildDetailRow("Paid Amount", "₹${(details.paymentAmount ?? 0.0).toStringAsFixed(2)}"),
                          _buildDetailRow("Debt Amount", "₹${(details.debtAmount ?? 0.0).toStringAsFixed(2)}"),
                          _buildDetailRow("Total Payable (Incl. Expense)", "₹${payableTotal.toStringAsFixed(2)}", isBold: true),

                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close", style: TextStyle(color: AppColors.textSecondary)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("PO-${details.id} Invoice download started successfully!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download, size: 16, color: Colors.black),
                                label: const Text("Download Bill", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  elevation: 0,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: AppColors.dark, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  // --- FORM MODAL: ADD EXPENSE ---
  void _openAddExpenseModal(PurchaseListItem row, int totalEggs) {
    double loadingExp = 0;
    double unloadingExp = 0;
    double transportExp = 0;

    final loadingController = TextEditingController();
    final unloadingController = TextEditingController();
    final transportController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Recalculate totals dynamically
            final totalExp = loadingExp + unloadingExp + transportExp;
            final expensePerEgg = totalEggs > 0 ? (totalExp / totalEggs) : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Purchase Expense",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blueAccent),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    Text("Purchase Bill No: PO-${row.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Total Eggs: $totalEggs", style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),

                    // Loading Expenses
                    const Text("Loading Expenses (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: loadingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "0.00",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          loadingExp = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Unloading Expenses
                    const Text("Unloading Expenses (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: unloadingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "0.00",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          unloadingExp = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Transport Expenses
                    const Text("Transport Expenses (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: transportController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Click to calculate transport charge",
                        suffixIcon: const Icon(Icons.calculate, color: AppColors.blueAccent),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onTap: () {
                        _showTransportCalculator(
                          onApplied: (calculatedCharge) {
                            setModalState(() {
                              transportExp = calculatedCharge;
                              transportController.text = calculatedCharge.toStringAsFixed(2);
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Summary Panel
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Expense:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text("₹${totalExp.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueAccent)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Expense per Egg:", style: TextStyle(fontSize: 13)),
                              Text("₹${expensePerEgg.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  setModalState(() {
                                    _isSubmitting = true;
                                  });
                                  try {
                                    final success = await _repository.saveExpenses(
                                      purchaseId: row.id,
                                      loading: loadingExp,
                                      unloading: unloadingExp,
                                      transport: transportExp,
                                    );

                                    if (success) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Expenses saved successfully!"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                      Navigator.pop(context); // Close bottom sheet
                                      _loadInitialData(); // Refresh list data
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Failed to save expenses: $e"),
                                          backgroundColor: AppColors.redAccent,
                                        ),
                                      );
                                    }
                                  } finally {
                                    setModalState(() {
                                      _isSubmitting = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueAccent,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text("Save Expenses", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- POPUP: TRANSPORT CALCULATOR ---
  void _showTransportCalculator({required Function(double) onApplied}) {
    double ratePerKm = 0.0;
    double totalKm = 0.0;
    double toll = 0.0;
    double rto = 0.0;
    double petrol = 0.0;
    double other = 0.0;
    double advance = 0.0;
    String actualBalanceText = "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: StatefulBuilder(
            builder: (context, setCalcState) {
              // Dynamic calculations
              final totalKmAmount = ratePerKm * totalKm;
              final totalFreight = totalKmAmount + toll + rto + petrol + other;
              final autoBalance = totalFreight - advance;

              final actualBalance = actualBalanceText.isEmpty 
                  ? autoBalance 
                  : (double.tryParse(actualBalanceText) ?? autoBalance);
              final finalTransportCharge = advance + actualBalance;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Transport Calculator",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.blueAccent),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                      const Divider(),

                      // Rate per KM & Total KM
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Rate per KM (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      ratePerKm = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Total KM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      totalKm = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total KM Amount: ₹${totalKmAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Divider(height: 20),

                      // Toll & RTO
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Toll Exp (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      toll = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("RTO Exp (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      rto = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Petrol & Other
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Petrol Exp (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      petrol = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Other Exp (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      other = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      Text(
                        "Total Freight: ₹${totalFreight.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.dark),
                      ),
                      const SizedBox(height: 12),

                      // Advance & Balance Paid
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Advance Paid (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      advance = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Balance Paid (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: autoBalance.toStringAsFixed(2),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    setCalcState(() {
                                      actualBalanceText = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        "Final Transport Charge: ₹${finalTransportCharge.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.blueAccent),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              onApplied(finalTransportCharge);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueAccent),
                            child: const Text("Apply Charge", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
