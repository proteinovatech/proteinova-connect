import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_state.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/models/purchase_model.dart';
import 'package:proteinova_connect/features/purchase/orders/presentation/checkout.dart';

import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchase_dashboard_shimmer.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  // ignore: unused_field
  static bool _hasLoadedOnce = false;
  String searchQuery = "";
  String? filterSupplier = "All Suppliers";
  String? loadingPurchaseId;
  int currentPage = 1;

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "--";
    try {
      final dt = DateTime.parse(dateStr).toLocal();
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
      final day = dt.day;
      final month = months[dt.month - 1];
      final year = dt.year;
      return "$day $month $year";
    } catch (_) {
      return dateStr;
    }
  }

  String formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "--";
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? "pm" : "am";
      return "$hour:$min $amPm";
    } catch (_) {
      return "";
    }
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PurchaseBloc>().add(FetchPurchaseInitData());
      }
    });
  }

  void _showPurchaseDetailsBottomSheet(
    BuildContext context,
    Map<String, dynamic> purchase,
  ) {
    // ignore: unused_local_variable
    final Size size = MediaQuery.of(context).size;
    final items = purchase["items"] as List? ?? [];
    final brokerName = purchase["broker_name"] ?? "--";
    final brokerNum = purchase["broker_number"] ?? "--";
    final driverName = purchase["driver_name"] ?? "--";
    final driverNum = purchase["driver_number"] ?? "--";
    final vehicleNum = purchase["vehicle_number"] ?? "--";
    final vehicleType = purchase["vehicle_type"] ?? "--";

    final paymentMethod = purchase["payment_method"] ?? "Draft (Unpaid)";
    final upiApp = purchase["upi_app"] ?? "";
    final otherUpi = purchase["other_upi_details"] ?? "";
    final paymentAmt =
        double.tryParse(purchase["payment_amount"]?.toString() ?? "0") ?? 0.0;
    final debtAmt =
        double.tryParse(purchase["debt_amount"]?.toString() ?? "0") ?? 0.0;
    final _ = purchase["movement_status"] ?? "PENDING";
    final purchaseStatus = purchase["purchase_status"] ?? "PENDING";

    final double itemsCost = items.fold(
      0.0,
      (sum, e) =>
          sum +
          ((e["trays"] ?? 0) *
              (e["capacity"] ?? 30) *
              (double.tryParse(e["per_egg_price"]?.toString() ?? "0") ?? 0.0)),
    );

    final double load =
        double.tryParse(purchase["loading_charge"]?.toString() ?? "0") ?? 0.0;
    final double unload =
        double.tryParse(purchase["unloading_charge"]?.toString() ?? "0") ?? 0.0;
    final double trans =
        double.tryParse(purchase["transport_charge"]?.toString() ?? "0") ?? 0.0;
    final double misc =
        double.tryParse(purchase["misc_expense"]?.toString() ?? "0") ?? 0.0;
    final double additionalTotal = load + unload + trans + misc;
    final double grandTotal = itemsCost + additionalTotal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PO-${purchase["id"]}",
                        style: AppTextStyles.headingText22,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: purchaseStatus == "PURCHASED"
                              ? Colors.green.withOpacity(0.1)
                              : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          purchaseStatus,
                          style: TextStyle(
                            color: purchaseStatus == "PURCHASED"
                                ? Colors.green
                                : Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Supplier details
                  _buildDetailRow(
                    "Supplier Name",
                    purchase['supplier_company_name'] ?? '--',
                  ),
                  _buildDetailRow(
                    "Origin Location",
                    purchase['location'] ?? '--',
                  ),
                  _buildDetailRow(
                    "Warehouse",
                    purchase['warehouse_location'] ?? '--',
                  ),
                  _buildDetailRow(
                    "Expected Arrival",
                    purchase['expected_arrival'] ?? '--',
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Products Listing",
                    style: AppTextStyles.formInputs15dark,
                  ),
                  const SizedBox(height: 8),

                  // Products Table/List
                  ...items.map((item) {
                    final qty = item["trays"] ?? 0;
                    final price =
                        double.tryParse(
                          item["per_egg_price"]?.toString() ?? "0",
                        ) ??
                        0.0;
                    final deduction =
                        double.tryParse(
                          item["market_price_minus"]?.toString() ?? "0",
                        ) ??
                        0.0;
                    final finalRate = price;
                    final cost = qty * 30 * finalRate;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            "Category",
                            item["egg_category_grade"] ?? "",
                          ),
                          _buildDetailRow(
                            "Trays / Eggs",
                            "$qty Trays (${qty * 30} eggs)",
                          ),
                          _buildDetailRow(
                            "Rate / Minus",
                            "₹${price.toStringAsFixed(2)} / -₹${deduction.toStringAsFixed(2)}",
                          ),
                          _buildDetailRow(
                            "Tray Type",
                            item["tray_type"] ?? "--",
                          ),
                          _buildDetailRow(
                            "Final Cost",
                            "₹${cost.toStringAsFixed(2)}",
                            isBold: true,
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(),
                  _buildDetailRow(
                    "Items Total Cost",
                    "₹${itemsCost.toStringAsFixed(2)}",
                  ),
                  _buildDetailRow(
                    "Additional Costs",
                    "₹${additionalTotal.toStringAsFixed(2)}",
                  ),
                  _buildDetailRow(
                    "Grand Total",
                    "₹${grandTotal.toStringAsFixed(2)}",
                    isBold: true,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Broker & Driver Details",
                    style: AppTextStyles.formInputs15dark,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    "Broker Name / Num",
                    "$brokerName / $brokerNum",
                  ),
                  _buildDetailRow(
                    "Driver Name / Num",
                    "$driverName / $driverNum",
                  ),
                  _buildDetailRow(
                    "Vehicle No / Type",
                    "$vehicleNum / $vehicleType",
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Payment Details",
                    style: AppTextStyles.formInputs15dark,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow("Method", paymentMethod),
                  if (upiApp.isNotEmpty) _buildDetailRow("UPI App", upiApp),
                  if (otherUpi.isNotEmpty)
                    _buildDetailRow("Reference", otherUpi),
                  _buildDetailRow(
                    "Amount Paid",
                    "₹${paymentAmt.toStringAsFixed(2)}",
                  ),
                  _buildDetailRow(
                    "Debt Remaining",
                    "₹${debtAmt.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Mock Invoice Download Started...",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: const Text("Download Invoice"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (purchaseStatus == "PENDING")
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close details modal

                              final request = PurchaseRequest(
                                supplierId: purchase["supplier_id"] ?? 0,
                                supplierName:
                                    purchase["supplier_company_name"] ?? "",
                                location: purchase["location"] ?? "",
                                warehouseLocation:
                                    purchase["warehouse_location"] ?? "",
                                expectedArrival:
                                    purchase["expected_arrival"] ?? "",
                                driverName: driverName,
                                driverNumber: driverNum,
                                vehicleNumber: vehicleNum,
                                vehicleType: vehicleType,
                                loadingCharge: load,
                                unloadingCharge: unload,
                                transportCharge: trans,
                                miscExpense: misc,
                                purchaseStatus: purchaseStatus,
                                brokerFee: 0.0,
                                brokerNumber: brokerNum,
                                brokerName: brokerName,
                                description: purchase["description"] ?? "",
                                items: items.map((e) {
                                  return PurchaseItem(
                                    eggCategoryGrade:
                                        e["egg_category_grade"] ?? "",
                                    trays: e["trays"] ?? 0,
                                    capacity: e["capacity"] ?? 30,
                                    perEggPrice:
                                        double.tryParse(
                                          e["per_egg_price"]?.toString() ?? "0",
                                        ) ??
                                        0.0,
                                    marketPriceMinus:
                                        double.tryParse(
                                          e["market_price_minus"]?.toString() ??
                                              "0",
                                        ) ??
                                        0.0,
                                    neccRate:
                                        double.tryParse(
                                          e["necc_rate"]?.toString() ?? "0",
                                        ) ??
                                        0.0,
                                    trayType: e["tray_type"] ?? "",
                                  );
                                }).toList(),
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Checkout(purchase: request),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.amber600,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Checkout"),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyText14.copyWith(color: Colors.black54),
          ),
          Text(
            value,
            style: AppTextStyles.bodyText14.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cache = PurchaseCacheService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                right: size.width * 0.05,
                top: getHeight(context, 15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Text(
                        "Purchase Overview",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Color(0xFFB45309),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Role: Warehouse & Admin",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocListener<PurchaseBloc, PurchaseState>(
                listener: (context, state) {
                  if (state is PurchaseLoaded && state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message!),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  }
                },
                child: BlocBuilder<PurchaseBloc, PurchaseState>(
                  builder: (context, state) {
                    if (state is PurchaseLoading) {
                      return const PurchaseDashboardShimmer();
                    }

                    if (state is PurchaseLoaded) {
                      _hasLoadedOnce = true;
                    }

                    if (state is PurchaseError) {
                      return Center(child: Text(state.message));
                    }

                    if (state is! PurchaseLoaded) {
                      return const SizedBox();
                    }

                    // Extract unique suppliers for filter dropdown
                    final uniqueSuppliers =
                        ["All Suppliers"] +
                        state.purchases
                            .map(
                              (p) =>
                                  (p['supplier_company_name'] ?? '').toString(),
                            )
                            .where((name) => name.isNotEmpty)
                            .toSet()
                            .toList();

                    // Apply local filtering
                    final filteredPurchases = state.purchases.where((p) {
                      final supplierName = (p['supplier_company_name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final orderId = "PO-${p['id']}".toLowerCase();
                      final driverName = (p['driver_name'] ?? '')
                          .toString()
                          .toLowerCase();

                      final query = searchQuery.toLowerCase();
                      final matchesSearch =
                          supplierName.contains(query) ||
                          orderId.contains(query) ||
                          driverName.contains(query);

                      final matchesSupplier =
                          filterSupplier == "All Suppliers" ||
                          (p['supplier_company_name'] ?? '') == filterSupplier;

                      return matchesSearch && matchesSupplier;
                    }).toList();

                    // Safely adjust currentPage if it's out of range after filtering
                    final int itemsPerPage = 5;
                    final totalRecords = filteredPurchases.length;
                    final maxPage = (totalRecords / itemsPerPage).ceil();
                    if (currentPage > maxPage) {
                      currentPage = maxPage > 0 ? maxPage : 1;
                    }
                    if (currentPage < 1) {
                      currentPage = 1;
                    }

                    final startRecord = totalRecords == 0
                        ? 0
                        : (currentPage - 1) * itemsPerPage + 1;
                    final endRecord = currentPage * itemsPerPage < totalRecords
                        ? currentPage * itemsPerPage
                        : totalRecords;
                    final paginatedPurchases = totalRecords == 0
                        ? []
                        : filteredPurchases.sublist(startRecord - 1, endRecord);
                    final totalPages = maxPage > 0 ? maxPage : 1;

                    // Ensure selected supplier is in uniqueSuppliers to avoid dropdown crashes
                    if (!uniqueSuppliers.contains(filterSupplier)) {
                      filterSupplier = "All Suppliers";
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<PurchaseBloc>().add(
                          FetchPurchaseInitData(),
                        );
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Purchase",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Manage and receive incoming shipments from suppliers to update inventory",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (_) => SupplierBloc(
                                              SupplierRepository(
                                                DioClient().dio,
                                              ),
                                            )..add(FetchSuppliers()),
                                          ),
                                          BlocProvider(
                                            create: (_) => PurchaseBloc(
                                              SupplierRepository(
                                                DioClient().dio,
                                              ),
                                              PurchaseRepository(
                                                DioClient().dio,
                                                cache,
                                              ),
                                              PurchaseCacheService(),
                                            )..add(FetchPurchaseInitData()),
                                          ),
                                        ],
                                        child: const Newpurchase(
                                          isEdit: false,
                                          purchaseData: null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD100),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "New Purchase",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Supplier dropdown
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    width: 220,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: filterSupplier,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey,
                                        ),
                                        isExpanded: true,
                                        onChanged: (val) {
                                          setState(() {
                                            filterSupplier = val;
                                            currentPage = 1;
                                          });
                                        },
                                        items: uniqueSuppliers.map((sup) {
                                          return DropdownMenuItem<String>(
                                            value: sup,
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.home_outlined,
                                                  color: Colors.grey,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    sup,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF334155),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),

                                // Table scroll view
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 650,
                                    ),
                                    child: Table(
                                      columnWidths: const {
                                        0: FixedColumnWidth(110),
                                        1: FixedColumnWidth(130),
                                        2: FixedColumnWidth(100),
                                        3: FixedColumnWidth(125),
                                        4: FixedColumnWidth(100),
                                        5: FixedColumnWidth(85),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      border: const TableBorder(
                                        horizontalInside: BorderSide(
                                          color: Color(0xFFF1F5F9),
                                          width: 1,
                                        ),
                                      ),
                                      children: [
                                        TableRow(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF8FAFC),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color(0xFFE2E8F0),
                                                width: 1,
                                              ),
                                              top: BorderSide(
                                                color: Color(0xFFE2E8F0),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          children: [
                                            _buildTableHeaderCell(
                                              "PURCHASE\nRECORD",
                                            ),
                                            _buildTableHeaderCell(
                                              "SUPPLIER\nDETAILS",
                                            ),
                                            _buildTableHeaderCell("PRODUCT"),
                                            _buildTableHeaderCell(
                                              "QUANTITY\nTOTAL EGGS",
                                            ),
                                            _buildTableHeaderCell("STATUS"),
                                            _buildTableHeaderCell("ACTION"),
                                          ],
                                        ),
                                        if (paginatedPurchases.isEmpty)
                                          TableRow(
                                            children: [
                                              TableCell(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 24,
                                                      ),
                                                  child: Center(
                                                    child: Text(
                                                      "No purchases found.",
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const TableCell(
                                                child: SizedBox(),
                                              ),
                                              const TableCell(
                                                child: SizedBox(),
                                              ),
                                              const TableCell(
                                                child: SizedBox(),
                                              ),
                                              const TableCell(
                                                child: SizedBox(),
                                              ),
                                              const TableCell(
                                                child: SizedBox(),
                                              ),
                                            ],
                                          )
                                        else
                                          ...paginatedPurchases.map((p) {
                                            // Extract data
                                            final purchaseId = p["id"] ?? "--";
                                            final dateStr = formatDate(
                                              p["created_at"],
                                            );
                                            final timeStr = formatTime(
                                              p["created_at"],
                                            );
                                            final supplierName =
                                                p["supplier_company_name"] ??
                                                "--";
                                            final location =
                                                p["location"] ?? "";
                                            final movementStatus =
                                                p["movement_status"] ??
                                                "PENDING";

                                            final items =
                                                p["items"] as List? ?? [];
                                            List<String> productNames = [];
                                            int totalTrays = 0;
                                            int totalEggs = 0;
                                            for (var item in items) {
                                              final trays =
                                                  int.tryParse(
                                                    item["trays"]?.toString() ??
                                                        "0",
                                                  ) ??
                                                  0;
                                              final cap =
                                                  int.tryParse(
                                                    item["capacity"]
                                                            ?.toString() ??
                                                        "30",
                                                  ) ??
                                                  30;
                                              totalTrays += trays;
                                              totalEggs += (trays * cap);
                                              if (item["egg_category_grade"] !=
                                                  null) {
                                                productNames.add(
                                                  item["egg_category_grade"]
                                                      .toString(),
                                                );
                                              }
                                            }
                                            final productText =
                                                productNames.isNotEmpty
                                                ? productNames.join(", ")
                                                : "--";

                                            return TableRow(
                                              children: [
                                                // PO, date, time
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 12,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "PO-$purchaseId",
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "$dateStr •",
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                      ),
                                                      Text(
                                                        timeStr,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Supplier Details
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 12,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        supplierName,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      if (location
                                                          .isNotEmpty) ...[
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          location,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                // Product
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 12,
                                                      ),
                                                  child: Text(
                                                    productText,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                // Quantity Total Eggs
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 12,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "$totalTrays Trays",
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "$totalEggs Eggs",
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey
                                                              .shade500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Status
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 12,
                                                      ),
                                                  child: Text(
                                                    movementStatus
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          movementStatus ==
                                                              "RECEIVED"
                                                          ? Colors.grey.shade800
                                                          : Colors
                                                                .amber
                                                                .shade800,
                                                    ),
                                                  ),
                                                ),
                                                // Action View button
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 12,
                                                      ),
                                                  child: SizedBox(
                                                    height: 30,
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        _showPurchaseDetailsBottomSheet(
                                                          context,
                                                          p,
                                                        );
                                                      },
                                                      style: OutlinedButton.styleFrom(
                                                        side: BorderSide(
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFF8FAFC,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        "View",
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
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

                                // Pagination footer
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Showing $startRecord - $endRecord of $totalRecords records",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          OutlinedButton(
                                            onPressed: currentPage > 1
                                                ? () {
                                                    setState(() {
                                                      currentPage--;
                                                    });
                                                  }
                                                : null,
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: currentPage > 1
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade100,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: Text(
                                              "Previous",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: currentPage > 1
                                                    ? Colors.black
                                                    : Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton(
                                            onPressed: currentPage < totalPages
                                                ? () {
                                                    setState(() {
                                                      currentPage++;
                                                    });
                                                  }
                                                : null,
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: currentPage < totalPages
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade100,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: Text(
                                              "Next",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: currentPage < totalPages
                                                    ? Colors.black
                                                    : Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
