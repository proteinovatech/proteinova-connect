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
import 'package:proteinova_connect/features/admin/purchase/data/models/purchase_model.dart';
import 'package:proteinova_connect/features/purchase/orders/presentation/checkout.dart';

import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchase_dashboard_shimmer.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchasecard.dart';

class PurchaseDashboard extends StatefulWidget {
  const PurchaseDashboard({super.key});

  @override
  State<PurchaseDashboard> createState() => _PurchaseDashboardState();
}

class _PurchaseDashboardState extends State<PurchaseDashboard> {
  // ignore: unused_field
  static bool _hasLoadedOnce = false;
  String searchQuery = "";
  String? filterSupplier = "All Suppliers";
  String? loadingPurchaseId;

  void _showPurchaseDetailsBottomSheet(BuildContext context, Map<String, dynamic> purchase) {
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
    final paymentAmt = double.tryParse(purchase["payment_amount"]?.toString() ?? "0") ?? 0.0;
    final debtAmt = double.tryParse(purchase["debt_amount"]?.toString() ?? "0") ?? 0.0;
    // ignore: unused_local_variable
    final movementStatus = purchase["movement_status"] ?? "PENDING";
    final purchaseStatus = purchase["purchase_status"] ?? "PENDING";

    final double itemsCost = items.fold(
      0.0,
      (sum, e) => sum + ((e["trays"] ?? 0) * (e["capacity"] ?? 30) * (double.tryParse(e["per_egg_price"]?.toString() ?? "0") ?? 0.0)),
    );
    
    final double load = double.tryParse(purchase["loading_charge"]?.toString() ?? "0") ?? 0.0;
    final double unload = double.tryParse(purchase["unloading_charge"]?.toString() ?? "0") ?? 0.0;
    final double trans = double.tryParse(purchase["transport_charge"]?.toString() ?? "0") ?? 0.0;
    final double misc = double.tryParse(purchase["misc_expense"]?.toString() ?? "0") ?? 0.0;
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
                      Text("PO-${purchase["id"]}", style: AppTextStyles.headingText22),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: purchaseStatus == "PURCHASED" ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          purchaseStatus,
                          style: TextStyle(
                            color: purchaseStatus == "PURCHASED" ? Colors.green : Colors.amber.shade800,
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
                  _buildDetailRow("Supplier Name", purchase['supplier_company_name'] ?? '--'),
                  _buildDetailRow("Origin Location", purchase['location'] ?? '--'),
                  _buildDetailRow("Warehouse", purchase['warehouse_location'] ?? '--'),
                  _buildDetailRow("Expected Arrival", purchase['expected_arrival'] ?? '--'),
                  
                  const SizedBox(height: 16),
                  const Text("Products Listing", style: AppTextStyles.formInputs15dark),
                  const SizedBox(height: 8),
                  
                  // Products Table/List
                  ...items.map((item) {
                    final qty = item["trays"] ?? 0;
                    final price = double.tryParse(item["per_egg_price"]?.toString() ?? "0") ?? 0.0;
                    final deduction = double.tryParse(item["market_price_minus"]?.toString() ?? "0") ?? 0.0;
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
                          _buildDetailRow("Category", item["egg_category_grade"] ?? ""),
                          _buildDetailRow("Trays / Eggs", "$qty Trays (${qty * 30} eggs)"),
                          _buildDetailRow("Rate / Minus", "₹${price.toStringAsFixed(2)} / -₹${deduction.toStringAsFixed(2)}"),
                          _buildDetailRow("Tray Type", item["tray_type"] ?? "--"),
                          _buildDetailRow("Final Cost", "₹${cost.toStringAsFixed(2)}", isBold: true),
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(),
                  _buildDetailRow("Items Total Cost", "₹${itemsCost.toStringAsFixed(2)}"),
                  _buildDetailRow("Additional Costs", "₹${additionalTotal.toStringAsFixed(2)}"),
                  _buildDetailRow("Grand Total", "₹${grandTotal.toStringAsFixed(2)}", isBold: true),
                  
                  const SizedBox(height: 16),
                  const Text("Broker & Driver Details", style: AppTextStyles.formInputs15dark),
                  const SizedBox(height: 8),
                  _buildDetailRow("Broker Name / Num", "$brokerName / $brokerNum"),
                  _buildDetailRow("Driver Name / Num", "$driverName / $driverNum"),
                  _buildDetailRow("Vehicle No / Type", "$vehicleNum / $vehicleType"),

                  const SizedBox(height: 16),
                  const Text("Payment Details", style: AppTextStyles.formInputs15dark),
                  const SizedBox(height: 8),
                  _buildDetailRow("Method", paymentMethod),
                  if (upiApp.isNotEmpty) _buildDetailRow("UPI App", upiApp),
                  if (otherUpi.isNotEmpty) _buildDetailRow("Reference", otherUpi),
                  _buildDetailRow("Amount Paid", "₹${paymentAmt.toStringAsFixed(2)}"),
                  _buildDetailRow("Debt Remaining", "₹${debtAmt.toStringAsFixed(2)}"),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mock Invoice Download Started..."), backgroundColor: Colors.green),
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
                                supplierName: purchase["supplier_company_name"] ?? "",
                                location: purchase["location"] ?? "",
                                warehouseLocation: purchase["warehouse_location"] ?? "",
                                expectedArrival: purchase["expected_arrival"] ?? "",
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
                                    eggCategoryGrade: e["egg_category_grade"] ?? "",
                                    trays: e["trays"] ?? 0,
                                    capacity: e["capacity"] ?? 30,
                                    perEggPrice: double.tryParse(e["per_egg_price"]?.toString() ?? "0") ?? 0.0,
                                    marketPriceMinus: double.tryParse(e["market_price_minus"]?.toString() ?? "0") ?? 0.0,
                                    neccRate: double.tryParse(e["necc_rate"]?.toString() ?? "0") ?? 0.0,
                                    trayType: e["tray_type"] ?? "",
                                  );
                                }).toList(),
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Checkout(purchase: request),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber600, foregroundColor: Colors.black),
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
          Text(title, style: AppTextStyles.bodyText14.copyWith(color: Colors.black54)),
          Text(value, style: AppTextStyles.bodyText14.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black)),
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
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Column(
                children: [
                  SizedBox(height: getHeight(context, 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/erplogo.png",
                          height: getHeight(context, 37), width: getWidth(context, 130)),
                    ],
                  ),
                  const Divider(),
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
                    final uniqueSuppliers = ["All Suppliers"] + state.purchases
                        .map((p) => (p['supplier_company_name'] ?? '').toString())
                        .where((name) => name.isNotEmpty)
                        .toSet()
                        .toList();

                    // Apply local filtering
                    final filteredPurchases = state.purchases.where((p) {
                      final supplierName = (p['supplier_company_name'] ?? '').toString().toLowerCase();
                      final orderId = "PO-${p['id']}".toLowerCase();
                      final driverName = (p['driver_name'] ?? '').toString().toLowerCase();
                      
                      final query = searchQuery.toLowerCase();
                      final matchesSearch = supplierName.contains(query) ||
                          orderId.contains(query) ||
                          driverName.contains(query);

                      final matchesSupplier = filterSupplier == "All Suppliers" ||
                          (p['supplier_company_name'] ?? '') == filterSupplier;

                      return matchesSearch && matchesSupplier;
                    }).toList();

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<PurchaseBloc>().add(FetchPurchaseInitData());
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                        children: [
                          Text("Purchase", style: AppTextStyles.headingText25),
                          Text(
                            "Manage Purchase orders and Incoming stocks.",
                            style: AppTextStyles.bodyText16,
                          ),
                          const SizedBox(height: 15),

                          // Dynamic Search Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.containerColor,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  searchQuery = val;
                                });
                              },
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search, color: Colors.grey),
                                hintText: "Search PO, supplier, driver...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Dynamic Supplier Filter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.containerColor,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: filterSupplier,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: uniqueSuppliers.map((sup) {
                                return DropdownMenuItem(value: sup, child: Text(sup));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  filterSupplier = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          /// NEW PURCHASE BUTTON
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (_) => SupplierBloc(
                                          SupplierRepository(DioClient().dio),
                                        )..add(FetchSuppliers()),
                                      ),
                                      BlocProvider(
                                        create: (_) => PurchaseBloc(
                                          SupplierRepository(DioClient().dio),
                                          PurchaseRepository(DioClient().dio, cache),
                                          PurchaseCacheService(),
                                        )..add(FetchPurchaseInitData()),
                                      ),
                                    ],
                                    child: const Newpurchase(isEdit: false, purchaseData: null),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.amber600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: AppColors.dark),
                                  const SizedBox(width: 8),
                                  Text("New Purchase Entry", style: AppTextStyles.headingText20),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: getHeight(context, 15)),

                          /// PURCHASE LIST
                          if (filteredPurchases.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Text("No purchases found match your criteria.", style: AppTextStyles.bodyText14),
                              ),
                            )
                          else
                            ...filteredPurchases.map((p) {
                              final items = p["items"] ?? [];
                              final expenses = p["expenses"] ?? [];
                              final itemsCost = items.fold(
                                0.0,
                                (sum, e) => sum + ((e["trays"] ?? 0) * (e["capacity"] ?? 30) * (double.tryParse(e["per_egg_price"]?.toString() ?? "0") ?? 0.0)),
                              );
                              
                              final expenseCost = expenses.fold(
                                0.0,
                                (sum, e) => sum + (double.tryParse(e["amount"]?.toString() ?? "0") ?? 0.0),
                              );
                              
                              final totalCost = itemsCost + expenseCost;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _showPurchaseDetailsBottomSheet(context, p),
                                  child: PurchaseCard(
                                    isLoading: loadingPurchaseId == p['id'].toString(),
                                    movementStatus: p['movement_status'] ?? 'PENDING',
                                    onArrivalTap: () async {
                                      setState(() {
                                        loadingPurchaseId = p['id'].toString();
                                      });
                                      context.read<PurchaseBloc>().add(
                                        UpdateArrivalEvent(
                                          purchaseId: p['id'].toString(),
                                          data: {"movement_status": "RECEIVED"},
                                        ),
                                      );
                                    },
                                    supplier: p['supplier_company_name'] ?? '',
                                    orderId: "PO-${p["id"]}",
                                    dateTime: p['created_at'] ?? '',
                                    bottomId: "₹ ${totalCost.toStringAsFixed(2)}",
                                    items: items.isNotEmpty
                                        ? items.map((e) => e["egg_category_grade"]).join(", ")
                                        : "",
                                    itemboxes: "${items.fold(0, (sum, e) => sum + (e["trays"] as int))} Trays",
                                  ),
                                ),
                              );
                            }).toList(),
                          SizedBox(height: getHeight(context, 20)),
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
