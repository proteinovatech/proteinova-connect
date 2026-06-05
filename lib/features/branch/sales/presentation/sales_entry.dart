// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:proteinova_connect/core/services/sales_receipt_service.dart';
// import 'package:proteinova_connect/core/theme/app_colors.dart';
// import 'package:proteinova_connect/features/branch/sales/data/datasource/branch_sales_remote_datasource.dart';
// import 'package:proteinova_connect/features/branch/sales/data/model/sales_entry_model.dart';
// import 'package:proteinova_connect/features/branch/sales/data/model/sales_item_model.dart';
// import 'package:proteinova_connect/features/branch/sales/widget/sales_entry_skeleton.dart';
// import 'package:proteinova_connect/core/services/notification_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SaleTray {
//   String trayType;
//   int qty;
//   SaleTray({this.trayType = "without tray", this.qty = 0});
// }

// class SalesEntryPage extends StatefulWidget {
//   const SalesEntryPage({super.key});

//   @override
//   State<SalesEntryPage> createState() => _SalesEntryPageState();
// }

// class _SalesEntryPageState extends State<SalesEntryPage> {
//   // --- State Variables ---
//   String salesHappen = "In_warehouse";
//   Map<String, dynamic>? headerData;
//   List<ProductDetail> products = [];
//   List<OfferModel> offers = [];
//   List<SalesItem> salesItems = [SalesItem()];
//   List<SaleTray> saleTrays = [SaleTray()];
//   List<Map<String, dynamic>> payments = [
//     {
//       "id": "1",
//       "method": "Cash",
//       "amount": "",
//       "app": "",
//       "reference": "",
//       "notes": ""
//     }
//   ];

//   bool isLoading = true;
//   bool isSubmitting = false;
//   String? customerStatus; // 'found', 'not_found', null

//   List<dynamic> branches = [];
//   String selectedBranchId = "warehouse";
//   String soldLocation = "Warehouse";
//   String soldTo = "Retail";

//   final TextEditingController customerNumberController =
//       TextEditingController();
//   final TextEditingController customerNameController = TextEditingController();
//   final TextEditingController notesController = TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController searchController = TextEditingController();
//   final TextEditingController cashReceivedByController =
//       TextEditingController();
//   final TextEditingController cashContactNumberController =
//       TextEditingController();
//   final TextEditingController otherUpiDetailsController =
//       TextEditingController();

//   final BranchSalesRemoteDatasource datasource = BranchSalesRemoteDatasource();
//   List<ProductDetail> filteredProducts = [];
//   int? selectedProductIndex;
//   bool showSalesItems = false;

//   int loginUserId = 0;
//   int branchId = 0;
//   double _lastTotalAmount = 0.0;

//   double? selectedDozen;

//   void selectDozen(double dozen) {
//     if (selectedProductIndex == null) return;

//     final product = filteredProducts[selectedProductIndex!];

//     setState(() {
//       selectedDozen = dozen;

//       final existingIndex = salesItems.indexWhere(
//         (e) => e.eggCategoryGrade == product.productName,
//       );

//       if (existingIndex != -1) {
//         final item = salesItems[existingIndex];
//         item.dozen = dozen;
//         item.calculateEggs();
//       } else {
//         salesItems.removeWhere((e) => e.eggCategoryGrade.isEmpty);
//         final newItem = SalesItem(
//           eggCategoryGrade: product.productName,
//           price: product.perTrayPrice / 30,
//           dozen: dozen,
//         );
//         newItem.calculateEggs();
//         salesItems.add(newItem);
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     _loadUserData().then((_) => _fetchInitialData());
//   }

//   @override
//   void dispose() {
//     customerNumberController.dispose();
//     customerNameController.dispose();
//     notesController.dispose();
//     dateController.dispose();
//     searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       branchId = prefs.getInt('branch_id') ?? 1;
//       loginUserId = prefs.getInt('user_id') ?? 1;
//     });
//   }

//   Future<void> _fetchInitialData() async {
//     try {
//       if (mounted) setState(() => isLoading = true);
//       final response = await datasource.getSalesEntry(
//         loginUserId: loginUserId,
//         branchId: selectedBranchId == "warehouse"
//             ? null
//             : int.tryParse(selectedBranchId),
//       );
//       final model = SalesEntryModel.fromJson(response);

//       // Fetch offers from /api/offers exactly like the React flow
//       List<OfferModel> fetchedOffers = [];
//       try {
//         final offersList = await datasource.getOffers();
//         fetchedOffers = offersList
//             .where((o) => o['status'] == 'active')
//             .map((o) => OfferModel.fromJson(o))
//             .toList();
//       } catch (e) {
//         debugPrint("Error fetching offers, falling back to entry response: $e");
//         fetchedOffers = model.offers;
//       }

//       // Fetch branches from /api/branches exactly like the React flow
//       List<dynamic> fetchedBranches = [];
//       try {
//         final branchRes = await datasource.getBranches();
//         fetchedBranches = branchRes['data'] ?? [];
//       } catch (e) {
//         debugPrint("Error fetching branches: $e");
//       }

//       if (mounted) {
//         setState(() {
//           headerData = model.header;
//           salesHappen = model.header['sales_happen'] ?? "In_warehouse";
//           products = model.productDetails;
//           offers = fetchedOffers;
//           branches = fetchedBranches;
//           filteredProducts = products;

//           if (model.header['sales_happen'] == "In_warehouse") {
//             soldLocation = "Warehouse";
//           } else {
//             soldLocation = model.header['branch_name'] ?? "Branch";
//           }
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching sales data: $e");
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   // --- Calculations ---
//   double get subtotal => salesItems.fold(0.0, (sum, item) => sum + item.total);

//   double get totalDiscount {
//     double discount = 0;
//     final double totalEggsInCart = salesItems.fold(
//       0.0,
//       (sum, item) => sum + item.eggs,
//     );

//     for (var offer in offers) {
//       if (!offer.applied) continue;

//       final isAllProducts =
//           offer.category.trim().toLowerCase() == "all products";
//       final matchingItem = isAllProducts
//           ? null
//           : salesItems.firstWhere(
//               (item) =>
//                   item.eggCategoryGrade.trim().toLowerCase() ==
//                   offer.category.trim().toLowerCase(),
//               orElse: () => SalesItem(eggCategoryGrade: ""),
//             );

//       if (!isAllProducts &&
//           (matchingItem == null || matchingItem.eggCategoryGrade.isEmpty)) {
//         continue;
//       }

//       if (offer.offerType == 'buy_x_get_y') {
//         final double relevantEggs = isAllProducts
//             ? totalEggsInCart
//             : (matchingItem?.eggs.toDouble() ?? 0.0);
//         final double pricePerEgg = isAllProducts
//             ? (salesItems.isNotEmpty ? salesItems.first.price : 0.0)
//             : (matchingItem?.price ?? 0.0);

//         final double buyEggs = offer.buyQty;
//         final double freeEggs = offer.freeQty;

//         if (relevantEggs >= buyEggs && buyEggs > 0) {
//           final double freeEggsCount =
//               (relevantEggs / buyEggs).floorToDouble() * freeEggs;
//           discount += double.parse(
//             (freeEggsCount * pricePerEgg).toStringAsFixed(2),
//           );
//         }
//       } else if (offer.offerType == 'percentage') {
//         final double relevantTotal = isAllProducts
//             ? subtotal
//             : (matchingItem?.total ?? 0.0);
//         discount += double.parse(
//           (relevantTotal * offer.discountValue / 100).toStringAsFixed(2),
//         );
//       } else if (offer.offerType == 'fixed' ||
//           offer.offerType == 'fixed_amount') {
//         discount += offer.discountValue;
//       }
//     }
//     return double.parse(discount.toStringAsFixed(2));
//   }

//   double get totalAmount => subtotal - totalDiscount;

//   double get paidAmount {
//     return payments
//         .where((p) => p["method"] != "Credit")
//         .fold(0.0, (sum, p) => sum + (double.tryParse(p["amount"].toString()) ?? 0.0));
//   }

//   double get debtAmount {
//     return payments
//         .where((p) => p["method"] == "Credit")
//         .fold(0.0, (sum, p) => sum + (double.tryParse(p["amount"].toString()) ?? 0.0));
//   }

//   double get balance {
//     return totalAmount - paidAmount;
//   }

//   // --- Actions ---
//   void addItem() {
//     setState(() => salesItems.add(SalesItem()));
//   }

//   void removeItem(int index) {
//     setState(() {
//       salesItems.removeAt(index);
//       if (salesItems.isEmpty) {
//         setState(() {
//           showSalesItems = false;

//           selectedProductIndex = null;

//           selectedDozen = null;
//         });
//       }
//     });
//   }

//   void updateItem(int index, String field, dynamic value) {
//     setState(() {
//       final item = salesItems[index];
//       if (field == 'product') {
//         final product = products.firstWhere((p) => p.productName == value);
//         item.eggCategoryGrade = product.productName;
//         item.price = product.perTrayPrice / 30;
//         item.calculateEggs();
//       } else if (field == 'dozen') {
//         item.dozen = double.tryParse(value.toString()) ?? 0;
//         item.calculateEggs();
//       } else if (field == 'trays') {
//         item.trays = int.tryParse(value.toString()) ?? 0;
//         item.calculateEggs();
//       }
//     });
//   }

//   void addProductFromCard(ProductDetail product) {
//     setState(() {
//       final existingIndex = salesItems.indexWhere(
//         (i) => i.eggCategoryGrade == product.productName,
//       );
//       if (existingIndex != -1) {
//         final item = salesItems[existingIndex];
//         item.trays += 1;
//         item.calculateEggs();
//       } else {
//         salesItems.removeWhere((i) => i.eggCategoryGrade.isEmpty);
//         final newItem = SalesItem(
//           eggCategoryGrade: product.productName,
//           price: product.perTrayPrice / 30,
//           trays: 1,
//         );
//         newItem.calculateEggs();
//         salesItems.add(newItem);
//       }
//     });
//   }

//   Future<void> lookupCustomer(String number) async {
//     if (number.length < 10) {
//       setState(() => customerStatus = null);
//       return;
//     }
//     try {
//       final res = await datasource.getCustomerByNumber(number);
//       // ignore: unnecessary_null_comparison
//       if (res != null && res['customer'] != null) {
//         setState(() {
//           customerNameController.text = res['customer']['name'] ?? "";
//           customerStatus = 'found';
//         });
//       } else {
//         setState(() => customerStatus = 'not_found');
//       }
//     } catch (e) {
//       setState(() => customerStatus = 'not_found');
//     }
//   }

//   void toggleOffer(int offerId) {
//     setState(() {
//       final index = offers.indexWhere((o) => o.id == offerId);
//       if (index != -1) {
//         offers[index].applied = !offers[index].applied;
//       }
//     });
//   }

//   void _addPaymentRow() {
//     setState(() {
//       payments.add({
//         "id": DateTime.now().millisecondsSinceEpoch.toString(),
//         "method": "Cash",
//         "amount": "",
//         "app": "",
//         "reference": "",
//         "notes": ""
//       });
//     });
//   }

//   void _removePaymentRow(String id) {
//     if (payments.length > 1) {
//       setState(() {
//         payments.removeWhere((p) => p["id"] == id);
//       });
//     }
//   }

//   Future<void> handlePayment() async {
//     final cName = customerNameController.text.trim();
//     final cNumber = customerNumberController.text.trim();

//     if (cName.isEmpty && cNumber.isEmpty) {
//       _showError("Please enter Customer Name or Number");
//       return;
//     }

// <<<<<<< HEAD
// =======
//     if (selectedPaymentMethod == "CASH") {
//       final cashReceivedBy = cashReceivedByController.text.trim();
//       final cashContactNumber = cashContactNumberController.text.trim();

//       if (cashReceivedBy.isEmpty) {
//         _showError("Please enter Cash Received By name");
//         return;
//       }

//       if (cashContactNumber.isEmpty) {
//         _showError("Please enter Cash Contact Number");
//         return;
//       }

//       if (cashContactNumber.length != 10 ||
//           double.tryParse(cashContactNumber) == null) {
//         _showError("Cash Contact Number must be a valid 10-digit number");
//         return;
//       }
//     }

// >>>>>>> b66a218e5de472e3c988b6ce113336a0dfd3a9c0
//     final validItems = salesItems
//         .where((i) => i.eggCategoryGrade.isNotEmpty)
//         .toList();
//     if (validItems.isEmpty) {
//       _showError("Please add at least one product");
//       return;
//     }

//     // Validate quantities
//     for (final item in validItems) {
//       if (item.eggs <= 0) {
//         _showError(
//           "Please add quantity (Dozen or Trays) for ${item.eggCategoryGrade}",
//         );
//         return;
//       }
//     }

//     setState(() => isSubmitting = true);
//     try {
//       final isSplit = payments.length > 1;
//       final finalMethod = isSplit ? "SPLIT" : payments[0]["method"].toString().toUpperCase();
//       final String? upiApp = (!isSplit && payments[0]["method"] == "UPI") ? payments[0]["app"] : null;
//       final otherUpi = jsonEncode(payments);

//       final payload = {
//         "login_user_id": loginUserId.toString(),
//         "sales_happen": salesHappen,
//         "sold_location_id": selectedBranchId,
//         "customer_name": cName.isEmpty ? "Unknown Customer" : cName,
//         "customer_number": cNumber.isEmpty ? "N/A" : cNumber,
//         "customer_debit": debtAmount,
//         "dispatch_date": dateController.text,
//         "sales_date": dateController.text,
//         "payment_method": finalMethod,
//         "cash_received": paidAmount,
//         "cash_received_by": null,
//         "cash_contact_number": null,
//         "upi_app": upiApp,
//         "other_upi_details": otherUpi,
//         "total_amount": totalAmount,
//         "offer_discount": totalDiscount,
//         "applied_offers": offers
//             .where((o) => o.applied)
//             .map((o) => o.name)
//             .toList(),
//         "sold_to": soldTo,
//         "sold_location": soldLocation,
//         "notes": notesController.text,
//         "items": validItems
//             .map(
//               (i) => {
//                 "egg_category_grade": i.eggCategoryGrade,
//                 "dozen": i.dozen,
//                 "eggs": i.eggs,
//                 "trays": (i.eggs / 30).ceil(),
//                 "total": i.total,
//               },
//             )
//             .toList(),
//         "sale_trays": saleTrays
//             .where((t) => t.qty > 0)
//             .map((t) => {"tray_type": t.trayType, "qty": t.qty})
//             .toList(),
//         "branch_id": selectedBranchId == "warehouse"
//             ? branchId
//             : (int.tryParse(selectedBranchId) ?? branchId),
//       };

//       if (customerStatus == 'not_found' && cNumber.isNotEmpty) {
//         await datasource.createCustomer(
//           name: cName.isEmpty ? "Unknown Customer" : cName,
//           number: cNumber,
//         );
//       }

//       final res = await datasource.createSale(body: payload);
//       setState(() => isSubmitting = false);

//       final saleId =
//           res['sale']?['id'] ??
//           res['data']?['id'] ??
//           res['id'] ??
//           res['sale_id'] ??
//           res['approval_id'] ??
//           'N/A';
//       final isPending =
//           res['status'] == "PENDING_REVIEW" || res['approval_id'] != null;

//       if (isPending) {
//         final totalEggs = validItems.fold(0, (sum, i) => sum + i.eggs);
//         NotificationService.sendAdminApprovalNotification(
//           saleId: saleId.toString(),
//           branchName: headerData?['title'] ?? 'Branch',
//           totalEggs: totalEggs,
//         );
//       }

//       _showSuccessPopup(saleId, isPending, validItems);
//     } catch (e) {
//       setState(() => isSubmitting = false);
//       _showError(e.toString());
//     }
//   }

//   void _showError(String msg) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(40),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFFEF2F2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.close,
//                   color: Color(0xFFEF4444),
//                   size: 40,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 "Sale Failed",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 msg,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1E293B),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Try Again",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSuccessPopup(
//     dynamic saleId,
//     bool isPending,
//     List<SalesItem> finalItems,
//   ) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => _SuccessDialog(
//         saleId: saleId.toString(),
//         amount: totalAmount,
//         isPending: isPending,
//         customerName: customerNameController.text,
//         customerNumber: customerNumberController.text,
//         date: dateController.text,
//         items: finalItems,
//         discount: totalDiscount,
//         subtotal: subtotal,
//         paymentMethod: payments.length > 1 ? "SPLIT" : payments[0]["method"].toString().toUpperCase(),
//         onNextSale: () {
//           Navigator.pop(context);
//           setState(() {
//             salesItems = [SalesItem()];
//             saleTrays = [SaleTray()];
//             payments = [
//               {
//                 "id": "1",
//                 "method": "Cash",
//                 "amount": "",
//                 "app": "",
//                 "reference": "",
//                 "notes": ""
//               }
//             ];
//             customerNameController.clear();
//             customerNumberController.clear();
//             notesController.clear();
//             customerStatus = null;
//             for (var o in offers) {
//               o.applied = false;
//             }
//           });
//         },
//         onDashboard: () {
//           Navigator.pop(context);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   // --- UI Builders ---
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const Scaffold(body: SalesEntrySkeleton());

//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F5F9),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool isTablet =
//                 constraints.maxWidth >= 700 && constraints.maxWidth < 1200;

//             final bool isDesktop = constraints.maxWidth >= 1200;

//             final bool isWide = isTablet || isDesktop;

//             return Column(
//               children: [
//                 _buildHeader(),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     child: Column(
//                       children: [
//                         _buildTodayStatsRow(),
//                         const SizedBox(height: 16),
//                         if (isWide)
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 flex: 1,
//                                 child: Column(
//                                   children: [
//                                     _buildTransactionDetailsCard(),

//                                     const SizedBox(height: 16),

//                                     _buildProductSelectionCard(),

//                                     const SizedBox(height: 16),

//                                     if (showSalesItems)
//                                       _buildSalesItemsCard(isWide),

//                                     const SizedBox(height: 16),

//                                     _buildTrayTypesCard(),

//                                     const SizedBox(height: 16),
//                                     _buildOffersCard(),
//                                     const SizedBox(height: 16),
//                                     // ROW START
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,

//                                       children: [
//                                         Expanded(
//                                           child: _buildPaymentAndSummaryGrid(),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Expanded(
//                                           child: _buildBillSummaryCard(),
//                                         ),
//                                       ],
//                                     ),
//                                     // ROW END
//                                   ],
//                                 ),
//                               ),
//                               // const SizedBox(width: 16),
//                               // Expanded(
//                               //   flex: 1,
//                               //   child: Column(
//                               //     children: [
//                               //       _buildSalesItemsCard(isWide),
//                               //       const SizedBox(height: 16),
//                               //       _buildTrayTypesCard(),
//                               //       const SizedBox(height: 16),
//                               //       _buildOffersCard(),
//                               //       const SizedBox(height: 16),
//                               //       _buildPaymentAndSummaryGrid(),
//                               //     ],
//                               //   ),
//                               // ),
//                             ],
//                           )
//                         else
//                           Column(
//                             children: [
//                               _buildTransactionDetailsCard(),
//                               const SizedBox(height: 16),
//                               _buildProductSelectionCard(),
//                               const SizedBox(height: 16),
//                               _buildSalesItemsCard(isWide),
//                               const SizedBox(height: 16),
//                               _buildTrayTypesCard(),
//                               const SizedBox(height: 16),
//                               _buildOffersCard(),
//                               const SizedBox(height: 16),
//                               _buildPaymentAndSummaryGrid(),
//                               const SizedBox(height: 16),
//                               _buildBillSummaryCard(),
//                             ],
//                           ),
//                         const SizedBox(height: 40),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       color: Colors.white,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back_ios, size: 20),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Flexible(
//                       child: Text(
//                         "$soldLocation / ",
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const Text(
//                       "Sales Entry",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // const SizedBox(width: 10),
//               // Container(
//               //   padding: const EdgeInsets.symmetric(
//               //     horizontal: 12,
//               //     vertical: 2,
//               //   ),
//               //   decoration: BoxDecoration(
//               //     color: Colors.white,
//               //     borderRadius: BorderRadius.circular(8),
//               //     border: Border.all(color: const Color(0xFFE2E8F0)),
//               //     boxShadow: [
//               //       BoxShadow(
//               //         color: Colors.black.withOpacity(0.03),
//               //         blurRadius: 3,
//               //         offset: const Offset(0, 1),
//               //       ),
//               //     ],
//               //   ),
//               //   child: DropdownButtonHideUnderline(
//               //     child: DropdownButton<String>(
//               //       value: selectedBranchId,
//               //       icon: const Icon(
//               //         Icons.keyboard_arrow_down,
//               //         size: 16,
//               //         color: Color(0xFF64748B),
//               //       ),
//               //       style: const TextStyle(
//               //         fontSize: 13,
//               //         fontWeight: FontWeight.w600,
//               //         color: Color(0xFF1E293B),
//               //       ),
//               //       items: [
//               //         const DropdownMenuItem<String>(
//               //           value: "warehouse",
//               //           child: Text("Main Warehouse"),
//               //         ),
//               //         ...branches.map((b) {
//               //           return DropdownMenuItem<String>(
//               //             value: b['id']?.toString() ?? "",
//               //             child: Text(b['branch_name'] ?? ""),
//               //           );
//               //         }).toList(),
//               //       ],
//               //       onChanged: (v) {
//               //         if (v != null) {
//               //           _onBranchChanged(v);
//               //         }
//               //       },
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//           const Divider(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodayStatsRow() {
//     final stats = headerData?['today_sales'] ?? {};
//     return Wrap(
//       alignment: WrapAlignment.spaceBetween,
//       crossAxisAlignment: WrapCrossAlignment.center,
//       spacing: 10,
//       runSpacing: 10,
//       children: [
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Today: ",
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             Text(
//               "${stats['count'] ?? 0} Sales",
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//             const Text(
//               " | Total: ",
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             Text(
//               "₹${(stats['amount'] ?? 0).toString()}",
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//           ],
//         ),
//         // ElevatedButton.icon(
//         //   onPressed: () {},
//         //   icon: const Icon(Icons.list, size: 16),
//         //   label: const Text(
//         //     "View Today's Sales",
//         //     style: TextStyle(fontSize: 12),
//         //   ),
//         //   style: ElevatedButton.styleFrom(
//         //     backgroundColor: Colors.white,
//         //     foregroundColor: Colors.blue,
//         //     elevation: 0,
//         //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         //     // ignore: deprecated_member_use
//         //     side: BorderSide(color: Colors.blue.withOpacity(0.3)),
//         //     shape: RoundedRectangleBorder(
//         //       borderRadius: BorderRadius.circular(8),
//         //     ),
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _buildTransactionDetailsCard() {
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Tablet only
//     final bool isTablet = screenWidth >= 700;

//     return _buildCard(
//       title: "Transaction Details",
//       child: Column(
//         children: [
//           // MOBILE VIEW
//           if (!isTablet) ...[
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildInput(
//                     "Customer Number",
//                     customerNumberController,
//                     hint: "9876543210",
//                     keyboardType: TextInputType.phone,
//                     onChanged: lookupCustomer,
//                     suffix: customerStatus == 'found'
//                         ? const Icon(
//                             Icons.check_circle,
//                             color: Colors.green,
//                             size: 18,
//                           )
//                         : customerStatus == 'not_found'
//                         ? const Icon(
//                             Icons.person_add,
//                             color: Colors.orange,
//                             size: 18,
//                           )
//                         : null,
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: _buildInput(
//                     "Customer Name",
//                     customerNameController,
//                     hint: "Enter customer name",
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 15),

//             _buildInput(
//               "Sales Date",
//               dateController,
//               readOnly: true,
//               onTap: () async {
//                 final date = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime.now(),
//                 );

//                 if (date != null) {
//                   dateController.text = DateFormat('yyyy-MM-dd').format(date);
//                 }
//               },
//               suffix: const Icon(
//                 Icons.calendar_today,
//                 size: 18,
//                 color: Colors.grey,
//               ),
//             ),
//           ],

//           // TABLET VIEW
//           if (isTablet)
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildInput(
//                     "Customer Number",
//                     customerNumberController,
//                     hint: "9876543210",
//                     keyboardType: TextInputType.phone,
//                     onChanged: lookupCustomer,
//                     suffix: customerStatus == 'found'
//                         ? const Icon(
//                             Icons.check_circle,
//                             color: Colors.green,
//                             size: 18,
//                           )
//                         : customerStatus == 'not_found'
//                         ? const Icon(
//                             Icons.person_add,
//                             color: Colors.orange,
//                             size: 18,
//                           )
//                         : null,
//                   ),
//                 ),

//                 const SizedBox(width: 20),

//                 Expanded(
//                   child: _buildInput(
//                     "Customer Name",
//                     customerNameController,
//                     hint: "Enter customer name",
//                   ),
//                 ),

//                 const SizedBox(width: 20),

//                 Expanded(
//                   child: _buildInput(
//                     "Sales Date",
//                     dateController,
//                     readOnly: true,
//                     onTap: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime.now(),
//                       );

//                       if (date != null) {
//                         dateController.text = DateFormat(
//                           'yyyy-MM-dd',
//                         ).format(date);
//                       }
//                     },
//                     suffix: const Icon(
//                       Icons.calendar_today,
//                       size: 18,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductSelectionCard() {
//     final screenWidth = MediaQuery.of(context).size.width;

//     // ONLY TABLET
//     final bool isTablet = screenWidth >= 700;

//     return _buildCard(
//       title: "Product Selection",

//       child: Column(
//         children: [
//           // TextField(
//           //   controller: searchController,
//           //   onChanged: (v) {
//           //     setState(() {
//           //       filteredProducts = products
//           //           .where(
//           //             (p) =>
//           //                 p.productName.toLowerCase().contains(v.toLowerCase()),
//           //           )
//           //           .toList();
//           //     });
//           //   },
//           //   decoration: InputDecoration(
//           //     hintText: "Search product by name",
//           //     prefixIcon: const Icon(Icons.search),
//           //     filled: true,
//           //     fillColor: Colors.grey.shade50,
//           //     border: OutlineInputBorder(
//           //       borderRadius: BorderRadius.circular(10),
//           //       borderSide: BorderSide(color: Colors.grey.shade200),
//           //     ),
//           //     enabledBorder: OutlineInputBorder(
//           //       borderRadius: BorderRadius.circular(10),
//           //       borderSide: BorderSide(color: Colors.grey.shade200),
//           //     ),
//           //     contentPadding: const EdgeInsets.symmetric(vertical: 0),
//           //   ),
//           // ),
//           // const SizedBox(height: 10),
//           GridView.builder(
//             shrinkWrap: true,

//             physics: const NeverScrollableScrollPhysics(),

//             itemCount: filteredProducts.length,

//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: isTablet ? 5 : 2,

//               childAspectRatio: isTablet ? 2.0 : 1.3,

//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),

//             itemBuilder: (context, index) {
//               final p = filteredProducts[index];

//               final isOutOfStock = p.stockEggs <= 0;

//               final isSelected = selectedProductIndex == index;

//               return InkWell(
//                 onTap: isOutOfStock
//                     ? null
//                     : () {
//                         setState(() {
//                           selectedProductIndex = index;

//                           // SHOW
//                           showSalesItems = true;
//                         });

//                         addProductFromCard(p);
//                       },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),

//                   padding: EdgeInsets.all(isTablet ? 8 : 12),

//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? Colors.blue.withOpacity(0.08)
//                         : Colors.white,

//                     borderRadius: BorderRadius.circular(12),

//                     border: Border.all(
//                       color: isSelected ? Colors.blue : Colors.grey.shade200,

//                       width: isSelected ? 2 : 1,
//                     ),
//                   ),

//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,

//                     crossAxisAlignment: CrossAxisAlignment.start,

//                     children: [
//                       Flexible(
//                         child: Text(
//                           p.productName,

//                           maxLines: 1,

//                           overflow: TextOverflow.ellipsis,

//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,

//                             fontSize: isTablet ? 11 : 14,

//                             height: 1.0,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 2),

//                       Text(
//                         "₹${(p.perTrayPrice / 30).toStringAsFixed(2)} / Egg",

//                         maxLines: 1,

//                         overflow: TextOverflow.ellipsis,

//                         style: TextStyle(
//                           color: Colors.blue,

//                           fontWeight: FontWeight.w700,

//                           fontSize: isTablet ? 10 : 12,

//                           height: 1.0,
//                         ),
//                       ),

//                       const SizedBox(height: 2),

//                       Text(
//                         "Stock: ${p.stockEggs}",

//                         maxLines: 1,

//                         overflow: TextOverflow.ellipsis,

//                         style: TextStyle(
//                           color: isOutOfStock ? Colors.red : Colors.green,

//                           fontSize: isTablet ? 10 : 11,

//                           height: 1.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           if (isTablet) ...[
//             const SizedBox(height: 10),

//             Align(
//               alignment: Alignment.centerRight,

//               child: Wrap(
//                 alignment: WrapAlignment.end,
//                 spacing: 16,

//                 children: [0.5, 1.0, 1.5, 2.0, 2.5].map((d) {
//                   final selected = selectedDozen == d;

//                   return AnimatedScale(
//                     scale: selected ? 0.92 : 1,

//                     duration: const Duration(milliseconds: 120),

//                     curve: Curves.easeOut,

//                     child: Material(
//                       color: Colors.transparent,

//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(8),

//                         splashColor: Colors.blue.withOpacity(0.25),

//                         highlightColor: Colors.blue.withOpacity(0.10),

//                         onTap: selectedProductIndex == null
//                             ? null
//                             : () {
//                                 setState(() {
//                                   // selected highlight
//                                   selectedDozen = d;
//                                 });

//                                 // add dozen
//                                 selectDozen(d);
//                               },

//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 150),

//                           curve: Curves.easeInOut,

//                           width: 52,

//                           height: 44,

//                           decoration: BoxDecoration(
//                             color: selected ? Colors.blue : Colors.white,

//                             borderRadius: BorderRadius.circular(8),

//                             border: Border.all(
//                               color: selected
//                                   ? Colors.blue
//                                   : Colors.grey.shade300,

//                               width: selected ? 2 : 1,
//                             ),

//                             boxShadow: selected
//                                 ? [
//                                     BoxShadow(
//                                       color: Colors.blue.withOpacity(0.25),

//                                       blurRadius: 10,

//                                       spreadRadius: 1,
//                                     ),
//                                   ]
//                                 : [],
//                           ),

//                           child: Center(
//                             child: AnimatedDefaultTextStyle(
//                               duration: const Duration(milliseconds: 150),

//                               style: TextStyle(
//                                 color: selected ? Colors.white : Colors.black,

//                                 fontWeight: FontWeight.bold,

//                                 fontSize: selected ? 13 : 14,
//                               ),

//                               child: Text(d.toStringAsFixed(1)),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildSalesItemsCard(bool isWide) {
//     return _buildCard(
//       title: "Sales Items",
//       trailing: InkWell(
//         onTap: addItem,
//         child: Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2563EB),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.add, color: Colors.white, size: 20),
//         ),
//       ),
//       child: Column(
//         children: [
//           if (isWide)
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),

//               color: Colors.grey.shade100,

//               child: Row(
//                 children: const [
//                   Expanded(
//                     flex: 5,
//                     child: Text(
//                       "Product",
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       "Dozen",

//                       textAlign: TextAlign.center,

//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       "Trays",

//                       textAlign: TextAlign.center,

//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       "Eggs",

//                       textAlign: TextAlign.center,

//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       "Rate/Egg",

//                       textAlign: TextAlign.center,

//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       "Total",

//                       textAlign: TextAlign.right,

//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   SizedBox(width: 28),
//                 ],
//               ),
//             ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: salesItems.length,
//             itemBuilder: (context, index) {
//               final item = salesItems[index];
//               if (isWide) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Row(
//                     children: [
//                       // Expanded(
//                       //   flex: 3,
//                       //   child: Container(
//                       //     padding: const EdgeInsets.symmetric(horizontal: 5),
//                       //     decoration: BoxDecoration(
//                       //       border: Border.all(color: Colors.grey.shade300),
//                       //       borderRadius: BorderRadius.circular(8),
//                       //     ),
//                       //     child: DropdownButtonHideUnderline(
//                       //       child: DropdownButton<String>(
//                       //         value: item.eggCategoryGrade.isEmpty
//                       //             ? null
//                       //             : item.eggCategoryGrade,
//                       //         isExpanded: true,
//                       //         hint: const Text(
//                       //           "Select Product",
//                       //           style: TextStyle(fontSize: 11),
//                       //         ),
//                       //         items: products
//                       //             .map(
//                       //               (p) => DropdownMenuItem(
//                       //                 value: p.productName,
//                       //                 child: Text(
//                       //                   p.productName,
//                       //                   style: const TextStyle(fontSize: 11),
//                       //                 ),
//                       //               ),
//                       //             )
//                       //             .toList(),
//                       //         onChanged: (v) => updateItem(index, 'product', v),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       Expanded(
//                         flex: 5,
//                         child: Container(
//                           height: 60,
//                           padding: const EdgeInsets.symmetric(horizontal: 14),
//                           alignment: Alignment.centerLeft,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             item.eggCategoryGrade.isEmpty
//                                 ? "Select Product"
//                                 : item.eggCategoryGrade,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: item.eggCategoryGrade.isEmpty
//                                   ? Colors.grey
//                                   : Colors.black,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 12),

//                       Expanded(
//                         flex: 3,
//                         child: SizedBox(
//                           height: 60,
//                           child: _buildStepper(
//                             item.dozen,
//                             (v) => updateItem(index, 'dozen', v),
//                             isDozen: true,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 12),

//                       Expanded(
//                         flex: 3,
//                         child: SizedBox(
//                           height: 60,
//                           child: _buildStepper(
//                             item.trays.toDouble(),
//                             (v) => updateItem(index, 'trays', v.toInt()),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         flex: 2,
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: Text(
//                             "${item.eggs}",
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         flex: 2,
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: Text(
//                             item.eggs == 0
//                                 ? "0"
//                                 : (item.total / item.eggs).toStringAsFixed(1),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         flex: 2,
//                         child: Align(
//                           alignment: Alignment.centerRight,
//                           child: Text(
//                             "₹${item.total.toStringAsFixed(1)}",
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w800,
//                               color: Color(0xFF16A34A),
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 14),

//                       InkWell(
//                         onTap: () => removeItem(index),
//                         child: Container(
//                           width: 32,
//                           height: 32,
//                           alignment: Alignment.center,
//                           child: const Icon(
//                             Icons.delete_outline,
//                             color: Color(0xFFEF4444),
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                       // const SizedBox(width: 4),
//                       // InkWell(
//                       //   onTap: () => removeItem(index),
//                       //   child: const Icon(
//                       //     Icons.delete_outline,
//                       //     color: Color(0xFFEF4444),
//                       //     size: 20,
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 );
//               } else {
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade300),
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.white,
//                               ),
//                               child: DropdownButtonHideUnderline(
//                                 child: DropdownButton<String>(
//                                   value: item.eggCategoryGrade.isEmpty
//                                       ? null
//                                       : item.eggCategoryGrade,
//                                   isExpanded: true,
//                                   hint: const Text(
//                                     "Select Product",
//                                     style: TextStyle(fontSize: 13),
//                                   ),
//                                   items: products
//                                       .map(
//                                         (p) => DropdownMenuItem(
//                                           value: p.productName,
//                                           child: Text(
//                                             p.productName,
//                                             style: const TextStyle(
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (v) =>
//                                       updateItem(index, 'product', v),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           InkWell(
//                             onTap: () => removeItem(index),
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(
//                                 Icons.delete_outline,
//                                 color: Color(0xFFEF4444),
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "Dozen",
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 _buildStepper(
//                                   item.dozen,
//                                   (v) => updateItem(index, 'dozen', v),
//                                   isDozen: true,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "Trays",
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 _buildStepper(
//                                   item.trays.toDouble(),
//                                   (v) => updateItem(index, 'trays', v.toInt()),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 const Text(
//                                   "Total Eggs:",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "${item.eggs}",
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w900,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 const Text(
//                                   "Price:",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "₹${item.total.toStringAsFixed(1)}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w900,
//                                     color: Color(0xFF16A34A),
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrayTypesCard() {
//     return _buildCard(
//       title: "Tray Types Used",
//       trailing: ElevatedButton.icon(
//         onPressed: () => setState(() => saleTrays.add(SaleTray())),
//         icon: const Icon(Icons.add, size: 14),
//         label: const Text("Add Tray", style: TextStyle(fontSize: 12)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF2563EB),
//           foregroundColor: Colors.white,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//         ),
//       ),
//       child: Column(
//         children: saleTrays.asMap().entries.map((entry) {
//           int idx = entry.key;
//           SaleTray tray = entry.value;
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: tray.trayType,
//                         isExpanded: true,
//                         items:
//                             [
//                                   "without tray",
//                                   "Empty paper tray",
//                                   "Empty plastic tray",
//                                   "Plastic tray (With egg)",
//                                   "Paper tray (with egg)",
//                                 ]
//                                 .map(
//                                   (t) => DropdownMenuItem(
//                                     value: t,
//                                     child: Text(
//                                       t,
//                                       style: const TextStyle(fontSize: 12),
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                         onChanged: (v) => setState(() => tray.trayType = v!),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   flex: 2,
//                   child: _buildStepper(
//                     tray.qty.toDouble(),
//                     (v) => setState(() => tray.qty = v.toInt()),
//                   ),
//                 ),
//                 if (saleTrays.length > 1) ...[
//                   const SizedBox(width: 10),
//                   InkWell(
//                     onTap: () => setState(() => saleTrays.removeAt(idx)),
//                     child: const Icon(
//                       Icons.delete_outline,
//                       color: Color(0xFFEF4444),
//                       size: 20,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildOffersCard() {
//     return _buildCard(
//       title: "Available Offers",
//       child: Column(
//         children: offers.map((o) {
//           final isAllProducts = o.category.toLowerCase() == 'all products';
//           final matchingItem = salesItems.any(
//             (item) => isAllProducts
//                 ? item.eggCategoryGrade.isNotEmpty
//                 : item.eggCategoryGrade.toLowerCase() ==
//                       o.category.toLowerCase(),
//           );

//           bool isEligible = false;
//           String message = "";
//           if (o.offerType == 'buy_x_get_y') {
//             final totalEggs = salesItems
//                 .where(
//                   (i) => isAllProducts
//                       ? i.eggCategoryGrade.isNotEmpty
//                       : i.eggCategoryGrade.toLowerCase() ==
//                             o.category.toLowerCase(),
//                 )
//                 .fold(0, (sum, i) => sum + i.eggs);
//             isEligible = totalEggs >= o.buyQty;
//             message = "Need ${o.buyQty.toInt()} eggs";
//           } else {
//             isEligible = matchingItem;
//             message = isAllProducts ? "Add any product" : "Add product";
//           }

//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               color: o.applied ? Colors.green.shade50 : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: o.applied ? Colors.green : Colors.grey.shade200,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         o.name,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w800,
//                           fontSize: 15,
//                           color: Color(0xFF1E293B),
//                         ),
//                       ),
//                       Text(
//                         o.category,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: isEligible ? () => toggleOffer(o.id) : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: o.applied
//                         ? const Color(0xFF16A34A)
//                         : const Color(0xFF2563EB),
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (o.applied) const Icon(Icons.check, size: 14),
//                       if (o.applied) const SizedBox(width: 4),
//                       Text(
//                         o.applied
//                             ? "Applied"
//                             : (isEligible ? "Apply" : message),
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildPaymentAndSummaryGrid() {
// <<<<<<< HEAD
//     return Column(
//       children: [
//         _buildCard(
//           title: "Payment Details",
//           trailing: ElevatedButton.icon(
//             onPressed: _addPaymentRow,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2563EB),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             ),
//             icon: const Icon(Icons.add, size: 16),
//             label: const Text("Add Payment", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFE2E8F0)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         children: [
//                           const Text("TOTAL AMOUNT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey)),
//                           const SizedBox(height: 4),
//                           Text("₹ ${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                         ],
//                       ),
//                     ),
//                     Container(width: 1, height: 30, color: Colors.grey.shade300),
//                     Expanded(
//                       child: Column(
//                         children: [
//                           const Text("PAID AMOUNT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey)),
//                           const SizedBox(height: 4),
//                           Text("₹ ${paidAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
//                         ],
//                       ),
//                     ),
//                     Container(width: 1, height: 30, color: Colors.grey.shade300),
//                     Expanded(
//                       child: Column(
//                         children: [
//                           const Text("BALANCE / DEBT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey)),
//                           const SizedBox(height: 4),
//                           Text("₹ ${balance.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: payments.length,
//                 itemBuilder: (context, index) {
//                   final pay = payments[index];
//                   return Container(
//                     key: ValueKey(pay["id"]),
//                     margin: const EdgeInsets.only(bottom: 16),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF1F5F9),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFFE2E8F0)),
//                     ),
//                     child: Stack(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const Text("Method", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
//                                       const SizedBox(height: 6),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           border: Border.all(color: const Color(0xFFE2E8F0)),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: DropdownButtonHideUnderline(
//                                           child: DropdownButton<String>(
//                                             value: pay["method"],
//                                             isExpanded: true,
//                                             items: ["Cash", "UPI", "Card", "Credit"].map((m) {
//                                               return DropdownMenuItem(value: m, child: Text(m));
//                                             }).toList(),
//                                             onChanged: (val) {
//                                               setState(() {
//                                                 pay["method"] = val ?? "Cash";
//                                                 if (pay["method"] != "UPI") {
//                                                   pay["app"] = "";
//                                                   pay["reference"] = "";
//                                                 }
//                                               });
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
// =======
//     final currentTotal = totalAmount;
//     final entered = double.tryParse(cashReceivedController.text);
//     if (cashReceivedController.text.isEmpty || entered == _lastTotalAmount) {
//       cashReceivedController.text = currentTotal.toStringAsFixed(2);

//       cashReceivedController.selection = TextSelection.fromPosition(
//         TextPosition(offset: cashReceivedController.text.length),
//       );
//     }

//     _lastTotalAmount = currentTotal;

//     final isTablet = MediaQuery.of(context).size.width >= 500;
//     return Column(
//       children: [
//         _buildCard(
//           title: "Payment Method",
//           child: IntrinsicHeight(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Sidebar-like payment selector
//                 Container(
//                   width: isTablet ? 60 : 100,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: Column(
//                     children: [
//                       _sidebarMethodBtn("CASH"),
//                       _sidebarMethodBtn("UPI"),
//                       _sidebarMethodBtn("CARD"),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: isTablet ? 6 : 15),
//                 // Payment content
//                 Expanded(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,

//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (selectedPaymentMethod == "UPI") ...[
//                         // 1. Select UPI App
//                         const Text(
//                           "Select UPI App",
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w800,
//                             color: Color(0xFF374151),
//                           ),
//                         ),

//                         SizedBox(height: isTablet ? 10 : 15),

//                         Wrap(
//                           spacing: isTablet ? 6 : 4,

//                           runSpacing: isTablet ? 6 : 4,

//                           children: ["Google Pay", "PhonePe", "Paytm"]
//                               .map(
//                                 (app) => ChoiceChip(
//                                   label: Text(
//                                     app,

//                                     style: TextStyle(
//                                       fontSize: 11,

//                                       color: selectedUpiApp == app
//                                           ? Colors.white
//                                           : Colors.black,

//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),

//                                   selected: selectedUpiApp == app,

//                                   onSelected: (v) {
//                                     setState(() {
//                                       selectedUpiApp = app;
//                                     });
//                                   },

//                                   selectedColor: const Color(0xFF2563EB),

//                                   backgroundColor: Colors.white,
// >>>>>>> b66a218e5de472e3c988b6ce113336a0dfd3a9c0
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const Text("Amount (₹)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
//                                       const SizedBox(height: 6),
//                                       TextField(
//                                         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                                         inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
//                                         decoration: InputDecoration(
//                                           hintText: "0.00",
//                                           filled: true,
//                                           fillColor: Colors.white,
//                                           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                         ),
//                                         controller: TextEditingController.fromValue(
//                                           TextEditingValue(
//                                             text: pay["amount"] ?? "",
//                                             selection: TextSelection.collapsed(offset: (pay["amount"] ?? "").length),
//                                           ),
//                                         ),
//                                         onChanged: (val) {
//                                           setState(() {
//                                             pay["amount"] = val;
//                                           });
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (pay["method"] == "UPI") ...[
//                               const SizedBox(height: 12),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         const Text("UPI App", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
//                                         const SizedBox(height: 6),
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             border: Border.all(color: const Color(0xFFE2E8F0)),
//                                             borderRadius: BorderRadius.circular(8),
//                                           ),
//                                           child: DropdownButtonHideUnderline(
//                                             child: DropdownButton<String>(
//                                               value: pay["app"].toString().isEmpty ? null : pay["app"],
//                                               isExpanded: true,
//                                               hint: const Text("Select App"),
//                                               items: ["Google Pay", "PhonePe", "Paytm", "Other"].map((app) {
//                                                 return DropdownMenuItem(value: app, child: Text(app));
//                                               }).toList(),
//                                               onChanged: (val) {
//                                                 setState(() {
//                                                   pay["app"] = val ?? "";
//                                                 });
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         const Text("Reference No.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
//                                         const SizedBox(height: 6),
//                                         TextField(
//                                           decoration: InputDecoration(
//                                             hintText: "Txn ID",
//                                             filled: true,
//                                             fillColor: Colors.white,
//                                             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                           ),
//                                           controller: TextEditingController.fromValue(
//                                             TextEditingValue(
//                                               text: pay["reference"] ?? "",
//                                               selection: TextSelection.collapsed(offset: (pay["reference"] ?? "").length),
//                                             ),
//                                           ),
//                                           onChanged: (val) {
//                                             setState(() {
//                                               pay["reference"] = val;
//                                             });
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                             if (pay["method"] == "Card") ...[
//                               const SizedBox(height: 12),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text("Reference No.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
//                                   const SizedBox(height: 6),
//                                   TextField(
//                                     decoration: InputDecoration(
//                                       hintText: "Txn ID or Ref",
//                                       filled: true,
//                                       fillColor: Colors.white,
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                     ),
//                                     controller: TextEditingController.fromValue(
//                                       TextEditingValue(
//                                         text: pay["reference"] ?? "",
//                                         selection: TextSelection.collapsed(offset: (pay["reference"] ?? "").length),
//                                       ),
//                                     ),
//                                     onChanged: (val) {
//                                       setState(() {
//                                         pay["reference"] = val;
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ],
//                             if (pay["method"] == "Credit") ...[
//                               const SizedBox(height: 12),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text("Debt Notes", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
//                                   const SizedBox(height: 6),
//                                   TextField(
//                                     decoration: InputDecoration(
//                                       hintText: "Notes",
//                                       filled: true,
//                                       fillColor: Colors.white,
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
//                                     ),
//                                     controller: TextEditingController.fromValue(
//                                       TextEditingValue(
//                                         text: pay["notes"] ?? "",
//                                         selection: TextSelection.collapsed(offset: (pay["notes"] ?? "").length),
//                                       ),
//                                     ),
//                                     onChanged: (val) {
//                                       setState(() {
//                                         pay["notes"] = val;
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ],
//                         ),
// <<<<<<< HEAD
//                         if (payments.length > 1)
//                           Positioned(
//                             right: 0,
//                             top: 0,
//                             child: InkWell(
//                               onTap: () => _removePaymentRow(pay["id"]),
//                               child: const Icon(Icons.close, color: Colors.red, size: 20),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 10),
//               _buildInput(
//                 "Notes",
//                 notesController,
//                 hint: "Add internal notes",
//               ),
//             ],
// =======

//                         SizedBox(height: isTablet ? 10 : 15),

//                         // 2. Amount
//                         _buildInput(
//                           "Enter Amount Received",

//                           cashReceivedController,

//                           keyboardType: TextInputType.number,

//                           hint: "0.00",

//                           prefix: const Padding(
//                             padding: EdgeInsets.only(left: 24, top: 10),

//                             child: Text(
//                               "₹",

//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),

//                           onChanged: (v) {
//                             setState(() {});
//                           },
//                         ),
//                         SizedBox(height: isTablet ? 10 : 15),

//                         // 3. Optional Details
//                         _buildInput(
//                           "Other UPI Details (Optional)",

//                           otherUpiDetailsController,

//                           hint: "Transaction ID / Notes",
//                         ),

//                         SizedBox(height: isTablet ? 10 : 15),
//                       ],
//                       // CASH
//                       if (selectedPaymentMethod == "CASH") ...[
//                         _buildInput(
//                           "Enter Amount Received",
//                           cashReceivedController,

//                           keyboardType: TextInputType.number,

//                           hint: "0.00",
//                         ),

//                         SizedBox(height: isTablet ? 10 : 15),

//                         _buildInput("Customer Debt (Optional)", debtController),
//                       ],

//                       // CARD
//                       if (selectedPaymentMethod == "CARD") ...[
//                         _buildInput(
//                           "Enter Amount Received",
//                           cashReceivedController,

//                           keyboardType: TextInputType.number,

//                           hint: "0.00",
//                         ),

//                         SizedBox(height: isTablet ? 10 : 15),

//                         _buildInput("Customer Debt (Optional)", debtController),
//                       ],

//                       SizedBox(height: isTablet ? 10 : 15),
//                       _buildInput(
//                         "Notes",
//                         notesController,
//                         hint: "Add internal notes",
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
// >>>>>>> b66a218e5de472e3c988b6ce113336a0dfd3a9c0
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBillSummaryCard() {
//     return _buildCard(
//       title: "Bill Summary",

//       child: Column(
//         children: [
//           _summaryRow("Subtotal", "₹ ${subtotal.toStringAsFixed(2)}"),

//           _summaryRow(
//             "Discount",
//             "- ₹ ${totalDiscount.toStringAsFixed(2)}",

//             color: const Color(0xFFEF4444),
//           ),

//           const Divider(height: 40),

//           _summaryRow(
//             "Total",
//             "₹ ${totalAmount.toStringAsFixed(2)}",

//             isBold: true,
//           ),

//           const SizedBox(height: 15),

//           SizedBox(
//             width: double.infinity,
//             height: 40,

//             child: ElevatedButton(
//               onPressed: isSubmitting ? null : handlePayment,

//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.blueAccent,

//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),

//                 elevation: 4,
//               ),

//               child: isSubmitting
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text(
//                       "Complete Sale",

//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepper(
//     double value,
//     Function(double) onChanged, {
//     bool isDozen = false,
//   }) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     // TABLET ONLY
//     final bool isTablet = screenWidth >= 700;

//     return Container(
//       height: 40,

//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),

//         borderRadius: BorderRadius.circular(8),

//         color: Colors.white,
//       ),

//       child: Row(
//         children: [
//           // REMOVE BUTTON
//           InkWell(
//             onTap: () {
//               if (value > 0) {
//                 onChanged(value - (isDozen ? 0.5 : 1));
//               }
//             },

//             child: Padding(
//               padding: const EdgeInsets.all(4),

//               child: Container(
//                 width: 30,
//                 height: 34,

//                 alignment: Alignment.center,

//                 decoration: isTablet
//                     ? BoxDecoration(
//                         color: Colors.grey.shade100,

//                         borderRadius: BorderRadius.circular(6),

//                         border: Border.all(color: Colors.grey.shade300),
//                       )
//                     : null,

//                 child: const Icon(Icons.remove, size: 12, color: Colors.black),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               isDozen ? value.toStringAsFixed(1) : value.toInt().toString(),

//               textAlign: TextAlign.center,

//               style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
//             ),
//           ),

//           // ADD BUTTON
//           InkWell(
//             onTap: () => onChanged(value + (isDozen ? 0.5 : 1)),

//             child: Padding(
//               padding: const EdgeInsets.all(6),

//               child: Container(
//                 width: 30,
//                 height: 34,

//                 alignment: Alignment.center,

//                 // TABLET ONLY CONTAINER
//                 decoration: isTablet
//                     ? BoxDecoration(
//                         color: Colors.grey.shade100,

//                         borderRadius: BorderRadius.circular(6),

//                         border: Border.all(color: Colors.grey.shade300),
//                       )
//                     : null,

//                 child: const Icon(Icons.add, size: 12, color: Colors.black),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard({
//     required String title,
//     required Widget child,
//     Widget? trailing,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 17,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//               if (trailing != null) trailing,
//             ],
//           ),
//           const SizedBox(height: 20),
//           child,
//         ],
//         // ignore: deprecated_member_use
//         // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//     );
//   }

//   Widget _buildInput(
//     String label,
//     TextEditingController controller, {
//     String? hint,
//     Function(String)? onChanged,
//     TextInputType? keyboardType,
//     Widget? suffix,
//     Widget? prefix,
//     bool readOnly = false,
//     VoidCallback? onTap,
//   }) {
//     final width = MediaQuery.of(context).size.width;

//     final compactTablet = width >= 600 && width < 1000;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Color(0xFF64748B),
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           onChanged: onChanged,
//           keyboardType: keyboardType,
//           readOnly: readOnly,
//           onTap: onTap,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: compactTablet ? 12 : 14,
//           ),
//           decoration: InputDecoration(
//             hintText: hint,
//             suffixIcon: suffix,
//             prefixIcon: prefix,
//             filled: true,
//             fillColor: const Color(0xFFF8FAFC),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 10,
//               vertical: compactTablet ? 4 : 12,
//             ),

//             constraints: BoxConstraints(minHeight: compactTablet ? 42 : 52),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _summaryRow(
//     String label,
//     String value, {
//     Color? color,
//     bool isBold = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
//               fontSize: isBold ? 18 : 15,
//               color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.w900,
//               color:
//                   color ??
//                   (isBold ? const Color(0xFF1E293B) : const Color(0xFF1E293B)),
//               fontSize: isBold ? 22 : 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SuccessDialog extends StatelessWidget {
//   final String saleId;
//   final double amount;
//   final bool isPending;
//   final String customerName;
//   final String customerNumber;
//   final String date;
//   final List<SalesItem> items;
//   final double discount;
//   final double subtotal;
//   final String paymentMethod;
//   final VoidCallback onNextSale;
//   final VoidCallback onDashboard;

//   const _SuccessDialog({
//     required this.saleId,
//     required this.amount,
//     required this.isPending,
//     required this.customerName,
//     required this.customerNumber,
//     required this.date,
//     required this.items,
//     required this.discount,
//     required this.subtotal,
//     required this.paymentMethod,
//     required this.onNextSale,
//     required this.onDashboard,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     final isTablet = width >= 600;

//     return Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: isTablet ? 120 : 20,
//         vertical: isTablet ? 20 : 24,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isTablet ? 20 : 30),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isTablet ? 22 : 40),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(isTablet ? 18 : 25),
//               decoration: BoxDecoration(
//                 color: isPending
//                     ? const Color.fromARGB(255, 255, 255, 255)
//                     : const Color(0xFFF0FDF4),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isPending ? Icons.timer_outlined : Icons.check_circle_outline,
//                 size: isTablet ? 40 : 70,
//                 color: isPending
//                     ? const Color(0xFFF97316)
//                     : const Color(0xFF22C55E),
//               ),
//             ),
//             SizedBox(height: isTablet ? 13 : 22),
//             Text(
//               isPending ? "Approval Requested" : "Payment Successful!",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: isTablet ? 18 : 24,
//                 fontWeight: FontWeight.w900,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               isPending
//                   ? "This sale exceeds egg limits and requires admin approval."
//                   : "Your transaction has been recorded successfully.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Color(0xFF64748B),
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: isTablet ? 13 : 32),
//             _infoBox(
//               isPending ? "Request ID:" : "Sale ID:",
//               "#$saleId",
//               isPending ? "REQ" : "S",
//             ),
//             _infoBox("Amount Paid:", "₹${amount.toStringAsFixed(2)}", "INR"),
//             SizedBox(height: isTablet ? 8 : 32),
//             if (!isPending)
//               Row(
//                 children: [
//                   Expanded(
//                     child: Material(
//                       color: Colors.transparent,

//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(16),

//                         splashColor: Colors.amber.withOpacity(0.30),

//                         highlightColor: Colors.yellow.withOpacity(0.15),

//                         onTap: () async {
//                           await SalesReceiptService.generateAndPrintReceipt(
//                             saleId: saleId,
//                             customerName: customerName,
//                             customerNumber: customerNumber,
//                             date: date,
//                             items: items,
//                             subtotal: subtotal,
//                             discount: discount,
//                             total: amount,
//                             paymentMethod: paymentMethod,
//                             isThermal: false,
//                           );
//                         },

//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 150),

//                           padding: const EdgeInsets.symmetric(vertical: 10),

//                           decoration: BoxDecoration(
//                             color: Colors.white,

//                             borderRadius: BorderRadius.circular(16),

//                             border: Border.all(color: Colors.blue, width: 1.5),
//                           ),

//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,

//                             mainAxisAlignment: MainAxisAlignment.center,

//                             children: [
//                               Icon(
//                                 Icons.file_download_outlined,

//                                 color: Colors.blue,

//                                 size: 20,
//                               ),

//                               const SizedBox(width: 8),

//                               const Text(
//                                 "PDF",

//                                 style: TextStyle(
//                                   color: Colors.blue,

//                                   fontWeight: FontWeight.w800,

//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: Material(
//                       color: Colors.transparent,

//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(16),

//                         splashColor: Colors.orange.withOpacity(0.30),

//                         highlightColor: Colors.amber.withOpacity(0.15),

//                         onTap: () async {
//                           await SalesReceiptService.generateAndPrintReceipt(
//                             saleId: saleId,
//                             customerName: customerName,
//                             customerNumber: customerNumber,
//                             date: date,
//                             items: items,
//                             subtotal: subtotal,
//                             discount: discount,
//                             total: amount,
//                             paymentMethod: paymentMethod,
//                             isThermal: true,
//                           );
//                         },

//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 150),

//                           padding: const EdgeInsets.symmetric(vertical: 10),

//                           decoration: BoxDecoration(
//                             color: Colors.blue,

//                             borderRadius: BorderRadius.circular(16),

//                             border: Border.all(color: Colors.blue, width: 1.5),
//                           ),

//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,

//                             mainAxisAlignment: MainAxisAlignment.center,

//                             children: [
//                               Icon(
//                                 Icons.print_outlined,

//                                 color: Colors.white,

//                                 size: 20,
//                               ),

//                               const SizedBox(width: 8),

//                               const Text(
//                                 "Print",

//                                 style: TextStyle(
//                                   color: Colors.white,

//                                   fontWeight: FontWeight.w800,

//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             SizedBox(height: isTablet ? 13 : 32),
//             SizedBox(
//               width: double.infinity,
//               height: isTablet ? 40 : 55,
//               child: ElevatedButton(
//                 onPressed: onNextSale,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1E293B),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   elevation: 4,
//                 ),
//                 child: const Text(
//                   "Next Sale",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextButton(
//               onPressed: onDashboard,
//               child: const Text(
//                 "Back to Dashboard",
//                 style: TextStyle(
//                   color: Color(0xFF64748B),
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoBox(String label, String value, String tag) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF64748B),
//               fontWeight: FontWeight.w800,
//               fontSize: 14,
//             ),
//           ),
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFDBEAFE),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   tag,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFF2563EB),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 17,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, size: 20),
//       label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: const Color(0xFF1E293B),
//         side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proteinova_connect/core/services/sales_receipt_service.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/utlis/responsive_height_width.dart';
import 'package:proteinova_connect/features/branch/sales/data/datasource/branch_sales_remote_datasource.dart';
import 'package:proteinova_connect/features/branch/sales/data/model/sales_entry_model.dart';
import 'package:proteinova_connect/features/branch/sales/data/model/sales_item_model.dart';
import 'package:proteinova_connect/features/branch/sales/widget/sales_entry_skeleton.dart';
import 'package:proteinova_connect/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaleTray {
  String trayType;
  int qty;
  double rate;
  SaleTray({this.trayType = "without tray", this.qty = 0, this.rate = 1.0});
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _TrayRow extends StatefulWidget {
  final SaleTray tray;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  final bool showDelete;

  const _TrayRow({
    Key? key,
    required this.tray,
    required this.onDelete,
    required this.onChanged,
    required this.showDelete,
  }) : super(key: key);

  @override
  State<_TrayRow> createState() => _TrayRowState();
}

class _TrayRowState extends State<_TrayRow> {
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.tray.rate % 1 == 0
          ? widget.tray.rate.toInt().toString()
          : widget.tray.rate.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _TrayRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tray.rate != widget.tray.rate) {
      final text = widget.tray.rate % 1 == 0
          ? widget.tray.rate.toInt().toString()
          : widget.tray.rate.toString();
      if (_rateController.text != text) {
        _rateController.text = text;
      }
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 600;

    final dropdownWidget = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.tray.trayType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items:
              [
                    "without tray",
                    "Empty paper tray",
                    "Empty plastic tray",
                    "Plastic tray (With egg)",
                    "Paper tray (with egg)",
                  ]
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                widget.tray.trayType = v;
              });
              widget.onChanged();
            }
          },
        ),
      ),
    );

    final stepperWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (widget.tray.qty > 0) {
              setState(() {
                widget.tray.qty--;
              });
              widget.onChanged();
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2E3E50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove, size: 16, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
      Container(
  width: getWidth(context, 48),
  height: getHeight(context, 36),
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: const Color(0xFFF8FAFC),
    border: Border.all(
      color: const Color(0xFFE2E8F0),
      width: getWidth(context, 1),
    ),
    borderRadius: BorderRadius.circular(
      getWidth(context, 8),
    ),
  ),
  child: Text(
    "${widget.tray.qty}",
    style: TextStyle(
      fontSize: getWidth(context, 14),
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
), const SizedBox(width: 8),
        InkWell(
          onTap: () {
            setState(() {
              widget.tray.qty++;
            });
            widget.onChanged();
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2E3E50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ),
      ],
    );

    final rateInputWidget =Container(
  width: getWidth(context, 100),
  height: getHeight(context, 48),
  padding: EdgeInsets.symmetric(
    horizontal: getWidth(context, 6),
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: Colors.grey.shade300,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(
      getWidth(context, 8),
    ),
  ),
  child: Row(
    children: [
      Text(
        "₹",
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: getWidth(context, 11),
          fontWeight: FontWeight.w500,
        ),
      ),

      SizedBox(width: getWidth(context, 2)),

      Expanded(
        child: TextField(
          controller: _rateController,
          keyboardType:
              const TextInputType.numberWithOptions(
            decimal: true,
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getWidth(context, 12),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) {
            final val =
                double.tryParse(v) ?? 0.0;

            widget.tray.rate = val;

            widget.onChanged();
          },
        ),
      ),

      Flexible(
        child: Text(
          "/tray",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: getWidth(context, 8),
          ),
        ),
      ),
    ],
  ),
);
final totalWidget = Text(
      " = ₹${(widget.tray.qty * widget.tray.rate).toStringAsFixed(2)}",
      style: const TextStyle(
        color: Color(0xFF16A34A),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );

    final deleteWidget = widget.showDelete
        ? InkWell(
            onTap: widget.onDelete,
            child: const Icon(
              Icons.delete_outline,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          )
        : const SizedBox.shrink();

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(flex: 4, child: dropdownWidget),
            const SizedBox(width: 16),
            stepperWidget,
            const SizedBox(width: 16),
            rateInputWidget,
            const SizedBox(width: 12),
            totalWidget,
            if (widget.showDelete) ...[const SizedBox(width: 12), deleteWidget],
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: dropdownWidget),
                  if (widget.showDelete) ...[
                    const SizedBox(width: 12),
                    deleteWidget,
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  stepperWidget,
                  const SizedBox(width: 12),
                  rateInputWidget,
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Charge:",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  totalWidget,
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({super.key});

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  // --- State Variables ---
  String salesHappen = "In_warehouse";
  Map<String, dynamic>? headerData;
  List<ProductDetail> products = [];
  List<OfferModel> offers = [];
  List<SalesItem> salesItems = [SalesItem()];
  List<SaleTray> saleTrays = [SaleTray()];

  bool isLoading = true;
  bool isSubmitting = false;
  String? customerStatus; // 'found', 'not_found', null

  String selectedPaymentMethod = "CASH";
  String selectedUpiApp = "";
  List<dynamic> branches = [];
  String selectedBranchId = "warehouse";
  String soldLocation = "Warehouse";
  String soldTo = "Retail";

  final TextEditingController customerNumberController =
      TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController cashReceivedController = TextEditingController();
  final TextEditingController debtController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController cashReceivedByController =
      TextEditingController();
  final TextEditingController cashContactNumberController =
      TextEditingController();
  final TextEditingController otherUpiDetailsController =
      TextEditingController();

  final BranchSalesRemoteDatasource datasource = BranchSalesRemoteDatasource();
  List<ProductDetail> filteredProducts = [];
  int? selectedProductIndex;
  bool showSalesItems = false;

  int loginUserId = 0;
  int branchId = 0;
  double _lastTotalAmount = 0.0;

  double? selectedDozen;

  void selectDozen(double dozen) {
    if (selectedProductIndex == null) return;

    final product = filteredProducts[selectedProductIndex!];

    setState(() {
      selectedDozen = dozen;

      final existingIndex = salesItems.indexWhere(
        (e) => e.eggCategoryGrade == product.productName,
      );

      if (existingIndex != -1) {
        final item = salesItems[existingIndex];
        item.dozen = dozen;
        item.calculateFromDozen();
      } else {
        salesItems.removeWhere((e) => e.eggCategoryGrade.isEmpty);
        final newItem = SalesItem(
          eggCategoryGrade: product.productName,
          price: product.perTrayPrice / 30,
          dozen: dozen,
        );
        newItem.calculateFromDozen();
        salesItems.add(newItem);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadUserData().then((_) => _fetchInitialData());
  }

  @override
  void dispose() {
    customerNumberController.dispose();
    customerNameController.dispose();
    cashReceivedController.dispose();
    debtController.dispose();
    notesController.dispose();
    dateController.dispose();
    searchController.dispose();
    cashReceivedByController.dispose();
    cashContactNumberController.dispose();
    otherUpiDetailsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      branchId = prefs.getInt('branch_id') ?? 1;
      loginUserId = prefs.getInt('user_id') ?? 1;
    });
  }

  Future<void> _fetchInitialData() async {
    try {
      if (mounted) setState(() => isLoading = true);
      final response = await datasource.getSalesEntry(
        loginUserId: loginUserId,
        branchId: selectedBranchId == "warehouse"
            ? null
            : int.tryParse(selectedBranchId),
      );
      final model = SalesEntryModel.fromJson(response);

      // Fetch offers from /api/offers exactly like the React flow
      List<OfferModel> fetchedOffers = [];
      try {
        final offersList = await datasource.getOffers();
        fetchedOffers = offersList
            .where((o) => o['status'] == 'active')
            .map((o) => OfferModel.fromJson(o))
            .toList();
      } catch (e) {
        debugPrint("Error fetching offers, falling back to entry response: $e");
        fetchedOffers = model.offers;
      }

      // Fetch branches from /api/branches exactly like the React flow
      List<dynamic> fetchedBranches = [];
      try {
        final branchRes = await datasource.getBranches();
        fetchedBranches = branchRes['data'] ?? [];
      } catch (e) {
        debugPrint("Error fetching branches: $e");
      }

      if (mounted) {
        setState(() {
          headerData = model.header;
          salesHappen = model.header['sales_happen'] ?? "In_warehouse";
          products = model.productDetails;
          offers = fetchedOffers;
          branches = fetchedBranches;
          filteredProducts = products;

          if (model.header['sales_happen'] == "In_warehouse") {
            soldLocation = "Warehouse";
          } else {
            soldLocation = model.header['branch_name'] ?? "Branch";
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching sales data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- Calculations ---
  double get subtotal => salesItems.fold(0.0, (sum, item) => sum + item.total);

  double get totalDiscount {
    double discount = 0;
    final double totalEggsInCart = salesItems.fold(
      0.0,
      (sum, item) => sum + item.eggs,
    );

    for (var offer in offers) {
      if (!offer.applied) continue;

      final isAllProducts =
          offer.category.trim().toLowerCase() == "all products";
      final matchingItem = isAllProducts
          ? null
          : salesItems.firstWhere(
              (item) =>
                  item.eggCategoryGrade.trim().toLowerCase() ==
                  offer.category.trim().toLowerCase(),
              orElse: () => SalesItem(eggCategoryGrade: ""),
            );

      if (!isAllProducts &&
          (matchingItem == null || matchingItem.eggCategoryGrade.isEmpty)) {
        continue;
      }

      if (offer.offerType == 'buy_x_get_y') {
        final double relevantEggs = isAllProducts
            ? totalEggsInCart
            : (matchingItem?.eggs.toDouble() ?? 0.0);
        final double pricePerEgg = isAllProducts
            ? (salesItems.isNotEmpty ? salesItems.first.price : 0.0)
            : (matchingItem?.price ?? 0.0);

        final double buyEggs = offer.buyQty * 30;
        final double freeEggs = offer.freeQty * 30;

        if (relevantEggs >= buyEggs && buyEggs > 0) {
          final double freeEggsCount =
              (relevantEggs / buyEggs).floorToDouble() * freeEggs;
          discount += double.parse(
            (freeEggsCount * pricePerEgg).toStringAsFixed(2),
          );
        }
      } else if (offer.offerType == 'percentage') {
        final double relevantTotal = isAllProducts
            ? subtotal
            : (matchingItem?.total ?? 0.0);
        discount += double.parse(
          (relevantTotal * offer.discountValue / 100).toStringAsFixed(2),
        );
      } else if (offer.offerType == 'fixed' ||
          offer.offerType == 'fixed_amount') {
        discount += offer.discountValue;
      }
    }
    return double.parse(discount.toStringAsFixed(2));
  }

  double get totalTrayCharges =>
      saleTrays.fold(0.0, (sum, tray) => sum + (tray.qty * tray.rate));
  double get totalAmount => subtotal - totalDiscount + totalTrayCharges;
  double get credit =>
      totalAmount - (double.tryParse(cashReceivedController.text) ?? 0);

  // --- Actions ---
  void addItem() {
    setState(() => salesItems.add(SalesItem()));
  }

  void removeItem(int index) {
    setState(() {
      salesItems.removeAt(index);
      if (salesItems.isEmpty) {
        setState(() {
          showSalesItems = false;

          selectedProductIndex = null;

          selectedDozen = null;
        });
      }
    });
  }

  void updateItem(int index, String field, dynamic value) {
    setState(() {
      final item = salesItems[index];
      if (field == 'product') {
        // final product = products.firstWhere((p) => p.productName == value);
        final product = products
            .where((p) => p.productName == value)
            .firstOrNull;

        if (product == null) return;
        item.eggCategoryGrade = product.productName;
        item.price = product.perTrayPrice / 30;
        item.calculateFromDozen();
      } else if (field == 'dozen') {
        item.dozen = double.tryParse(value.toString()) ?? 0;
        item.calculateFromDozen();
      } else if (field == 'trays') {
        item.trays = int.tryParse(value.toString()) ?? 0;
        item.calculateFromTrays();
      }
    });
  }

  // void addProductFromCard(ProductDetail product) {
  //   setState(() {
  //     final existingIndex = salesItems.indexWhere(
  //       (i) => i.eggCategoryGrade == product.productName,
  //     );
  //     if (existingIndex != -1) {
  //       final item = salesItems[existingIndex];
  //       item.trays += 1;
  //       item.calculateEggs();
  //     } else {
  //       salesItems.removeWhere((i) => i.eggCategoryGrade.isEmpty);
  //       final newItem = SalesItem(
  //         eggCategoryGrade: product.productName,
  //         price: product.perTrayPrice / 30,
  //         trays: 1,
  //       );
  //       newItem.calculateEggs();
  //       salesItems.add(newItem);
  //     }
  //   });
  // }
  void addProductFromCard(ProductDetail product) {
    setState(() {
      final existingIndex = salesItems.indexWhere(
        (i) => i.eggCategoryGrade == product.productName,
      );

      if (existingIndex == -1) {
        salesItems.removeWhere((i) => i.eggCategoryGrade.isEmpty);

        salesItems.add(
          SalesItem(
            eggCategoryGrade: product.productName,
            price: product.perTrayPrice / 30,

            // Start empty
            eggs: 0,
            total: 0,
          ),
        );
      }

      // No auto tray increment
      selectedProductIndex = filteredProducts.indexOf(product);
    });
  }

  Future<void> lookupCustomer(String number) async {
    if (number.length < 10) {
      setState(() => customerStatus = null);
      return;
    }
    try {
      final res = await datasource.getCustomerByNumber(number);
      // ignore: unnecessary_null_comparison
      if (res != null && res['customer'] != null) {
        setState(() {
          customerNameController.text = res['customer']['name'] ?? "";
          customerStatus = 'found';
        });
      } else {
        setState(() => customerStatus = 'not_found');
      }
    } catch (e) {
      setState(() => customerStatus = 'not_found');
    }
  }

  void toggleOffer(int offerId) {
    setState(() {
      final index = offers.indexWhere((o) => o.id == offerId);
      if (index != -1) {
        offers[index].applied = !offers[index].applied;
      }
    });
  }

  Future<void> handlePayment() async {
    final cName = customerNameController.text.trim();
    final cNumber = customerNumberController.text.trim();

    if (cName.isEmpty && cNumber.isEmpty) {
      _showError("Please enter Customer Name or Number");
      return;
    }

    // if (selectedPaymentMethod == "CASH") {
    //   final cashReceivedBy = cashReceivedByController.text.trim();
    //   final cashContactNumber = cashContactNumberController.text.trim();

    //   if (cashReceivedBy.isEmpty) {
    //     _showError("Please enter Cash Received By name");
    //     return;
    //   }

    //   if (cashContactNumber.isEmpty) {
    //     _showError("Please enter Cash Contact Number");
    //     return;
    //   }

    //   if (cashContactNumber.length != 10 ||
    //       double.tryParse(cashContactNumber) == null) {
    //     _showError("Cash Contact Number must be a valid 10-digit number");
    //     return;
    //   }
    // }

    final validItems = salesItems
        .where((i) => i.eggCategoryGrade.isNotEmpty)
        .toList();
    if (validItems.isEmpty) {
      _showError("Please add at least one product");
      return;
    }

    // Validate quantities
    for (final item in validItems) {
      if (item.eggs <= 0) {
        _showError(
          "Please add quantity (Dozen or Trays) for ${item.eggCategoryGrade}",
        );
        return;
      }
    }

    setState(() => isSubmitting = true);
    try {
      final upiApp = selectedPaymentMethod == "UPI"
          ? (selectedUpiApp.isEmpty ? "Other" : selectedUpiApp)
          : "";
      final ref = selectedPaymentMethod == "UPI"
          ? otherUpiDetailsController.text.trim()
          : "";
      final otherUpiList = [
        {
          "method": selectedPaymentMethod == "CASH"
              ? "Cash"
              : (selectedPaymentMethod == "UPI"
                    ? "UPI"
                    : (selectedPaymentMethod == "CARD" ? "Card" : "Credit")),
          "amount": (double.tryParse(cashReceivedController.text) ?? 0)
              .toStringAsFixed(0),
          "app": upiApp,
          "reference": ref,
          "notes": notesController.text,
        },
      ];

      final payload = {
        "login_user_id": loginUserId,
        "sales_happen": salesHappen,
        "sold_location_id": selectedBranchId,
        "customer_name": cName.isEmpty ? null : cName,
        "customer_number": cNumber.isEmpty ? "N/A" : cNumber,
        "customer_debit": double.tryParse(debtController.text) ?? 0,
        "dispatch_date": dateController.text,
        "sales_date": dateController.text,
        "payment_method": selectedPaymentMethod.toUpperCase(),
        "cash_received": double.tryParse(cashReceivedController.text) ?? 0,
        "cash_received_by": selectedPaymentMethod == "CASH"
            ? (cashReceivedByController.text.trim().isEmpty
                  ? null
                  : cashReceivedByController.text.trim())
            : null,
        "cash_contact_number": selectedPaymentMethod == "CASH"
            ? (cashContactNumberController.text.trim().isEmpty
                  ? null
                  : cashContactNumberController.text.trim())
            : null,
        "upi_app": selectedPaymentMethod == "UPI"
            ? (selectedUpiApp.isEmpty ? "Other" : selectedUpiApp)
            : null,
        "other_upi_details": otherUpiList,
        "total_amount": totalAmount,
        "tray_charges": totalTrayCharges,
        "offer_discount": totalDiscount,
        "applied_offers": offers
            .where((o) => o.applied)
            .map((o) => o.name)
            .toList(),
        "sold_to": soldTo,
        "sold_location": soldLocation,
        "notes": notesController.text,
        "items": validItems
            .map(
              (i) => {
                "egg_category_grade": i.eggCategoryGrade,
                "dozen": i.dozen,
                "eggs": i.eggs,
                "trays": (i.eggs / 30).ceil(),
                "total": i.total,
              },
            )
            .toList(),
        "sale_trays": saleTrays
            .where((t) => t.qty > 0)
            .map(
              (t) => {"tray_type": t.trayType, "qty": t.qty, "price": t.rate},
            )
            .toList(),
        "branch_id": selectedBranchId == "warehouse"
            ? branchId
            : (int.tryParse(selectedBranchId) ?? branchId),
      };

      if (customerStatus == 'not_found' && cNumber.isNotEmpty) {
        await datasource.createCustomer(
          name: cName.isEmpty ? "Unknown Customer" : cName,
          number: cNumber,
        );
      }

      final res = await datasource.createSale(body: payload);
      setState(() => isSubmitting = false);

      final saleId =
          res['sale']?['id'] ??
          res['data']?['id'] ??
          res['id'] ??
          res['sale_id'] ??
          res['approval_id'] ??
          'N/A';
      final isPending =
          res['status'] == "PENDING_REVIEW" || res['approval_id'] != null;

      if (isPending) {
        final totalEggs = validItems.fold(0, (sum, i) => sum + i.eggs);
        NotificationService.sendAdminApprovalNotification(
          saleId: saleId.toString(),
          branchName: headerData?['title'] ?? 'Branch',
          totalEggs: totalEggs,
        );
      }

      _showSuccessPopup(saleId, isPending, validItems);
    } catch (e) {
      setState(() => isSubmitting = false);
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFEF4444),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Sale Failed",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup(
    dynamic saleId,
    bool isPending,
    List<SalesItem> finalItems,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(
        saleId: saleId.toString(),
        amount: totalAmount,
        isPending: isPending,
        customerName: customerNameController.text,
        customerNumber: customerNumberController.text,
        date: dateController.text,
        items: finalItems,
        discount: totalDiscount,
        subtotal: subtotal,
        trayCharges: totalTrayCharges,
        paymentMethod: selectedPaymentMethod,
        onNextSale: () {
          Navigator.pop(context);
          setState(() {
            salesItems = [SalesItem()];
            saleTrays = [SaleTray()];
            customerNameController.clear();
            customerNumberController.clear();
            cashReceivedController.clear();
            debtController.clear();
            notesController.clear();
            customerStatus = null;
            for (var o in offers) {
              o.applied = false;
            }
          });
        },
        onDashboard: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: SalesEntrySkeleton());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isTablet =
                constraints.maxWidth >= 700 && constraints.maxWidth < 1200;

            final bool isDesktop = constraints.maxWidth >= 1200;

            final bool isWide = isTablet || isDesktop;

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        _buildTodayStatsRow(),
                        const SizedBox(height: 16),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildTransactionDetailsCard(),

                                    const SizedBox(height: 16),

                                    _buildProductSelectionCard(),

                                    const SizedBox(height: 16),

                                    if (showSalesItems)
                                      _buildSalesItemsCard(isWide),

                                    const SizedBox(height: 16),

                                    _buildTrayTypesCard(),

                                    const SizedBox(height: 16),
                                    _buildOffersCard(),
                                    const SizedBox(height: 16),
                                    // ROW START
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Expanded(
                                          child: _buildPaymentAndSummaryGrid(),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildBillSummaryCard(),
                                        ),
                                      ],
                                    ),
                                    // ROW END
                                  ],
                                ),
                              ),
                              // const SizedBox(width: 16),
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     children: [
                              //       _buildSalesItemsCard(isWide),
                              //       const SizedBox(height: 16),
                              //       _buildTrayTypesCard(),
                              //       const SizedBox(height: 16),
                              //       _buildOffersCard(),
                              //       const SizedBox(height: 16),
                              //       _buildPaymentAndSummaryGrid(),
                              //     ],
                              //   ),
                              // ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildTransactionDetailsCard(),
                              const SizedBox(height: 16),
                              _buildProductSelectionCard(),
                              const SizedBox(height: 16),
                              _buildSalesItemsCard(isWide),
                              const SizedBox(height: 16),
                              _buildTrayTypesCard(),
                              const SizedBox(height: 16),
                              _buildOffersCard(),
                              const SizedBox(height: 16),
                              _buildPaymentAndSummaryGrid(),
                              const SizedBox(height: 16),
                              _buildBillSummaryCard(),
                            ],
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Flexible(
                      child: Text(
                        "$soldLocation / ",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Text(
                      "Sales Entry",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(width: 10),
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 2,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: const Color(0xFFE2E8F0)),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.03),
              //         blurRadius: 3,
              //         offset: const Offset(0, 1),
              //       ),
              //     ],
              //   ),
              //   child: DropdownButtonHideUnderline(
              //     child: DropdownButton<String>(
              //       value: selectedBranchId,
              //       icon: const Icon(
              //         Icons.keyboard_arrow_down,
              //         size: 16,
              //         color: Color(0xFF64748B),
              //       ),
              //       style: const TextStyle(
              //         fontSize: 13,
              //         fontWeight: FontWeight.w600,
              //         color: Color(0xFF1E293B),
              //       ),
              //       items: [
              //         const DropdownMenuItem<String>(
              //           value: "warehouse",
              //           child: Text("Main Warehouse"),
              //         ),
              //         ...branches.map((b) {
              //           return DropdownMenuItem<String>(
              //             value: b['id']?.toString() ?? "",
              //             child: Text(b['branch_name'] ?? ""),
              //           );
              //         }).toList(),
              //       ],
              //       onChanged: (v) {
              //         if (v != null) {
              //           _onBranchChanged(v);
              //         }
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTodayStatsRow() {
    final stats = headerData?['today_sales'] ?? {};
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Today: ",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              "${stats['count'] ?? 0} Sales",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              " | Total: ",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              "₹${(stats['amount'] ?? 0).toString()}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        // ElevatedButton.icon(
        //   onPressed: () {},
        //   icon: const Icon(Icons.list, size: 16),
        //   label: const Text(
        //     "View Today's Sales",
        //     style: TextStyle(fontSize: 12),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.white,
        //     foregroundColor: Colors.blue,
        //     elevation: 0,
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     // ignore: deprecated_member_use
        //     side: BorderSide(color: Colors.blue.withOpacity(0.3)),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildTransactionDetailsCard() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Tablet only
    final bool isTablet = screenWidth >= 700;

    return _buildCard(
      title: "Transaction Details",
      child: Column(
        children: [
          // MOBILE VIEW
          if (!isTablet) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    "Customer Number",
                    customerNumberController,
                    hint: "9876543210",
                    keyboardType: TextInputType.phone,
                    onChanged: lookupCustomer,
                    suffix: customerStatus == 'found'
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          )
                        : customerStatus == 'not_found'
                        ? const Icon(
                            Icons.person_add,
                            color: Colors.orange,
                            size: 18,
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildInput(
                    "Customer Name",
                    customerNameController,
                    hint: "Enter customer name",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            _buildInput(
              "Sales Date",
              dateController,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (date != null) {
                  dateController.text = DateFormat('yyyy-MM-dd').format(date);
                }
              },
              suffix: const Icon(
                Icons.calendar_today,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],

          // TABLET VIEW
          if (isTablet)
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    "Customer Number",
                    customerNumberController,
                    hint: "9876543210",
                    keyboardType: TextInputType.phone,
                    onChanged: lookupCustomer,
                    suffix: customerStatus == 'found'
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          )
                        : customerStatus == 'not_found'
                        ? const Icon(
                            Icons.person_add,
                            color: Colors.orange,
                            size: 18,
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: _buildInput(
                    "Customer Name",
                    customerNameController,
                    hint: "Enter customer name",
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: _buildInput(
                    "Sales Date",
                    dateController,
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );

                      if (date != null) {
                        dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(date);
                      }
                    },
                    suffix: const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProductSelectionCard() {
    final screenWidth = MediaQuery.of(context).size.width;

    // ONLY TABLET
    final bool isTablet = screenWidth >= 700;

    return _buildCard(
      title: "Product Selection",

      child: Column(
        children: [
          // TextField(
          //   controller: searchController,
          //   onChanged: (v) {
          //     setState(() {
          //       filteredProducts = products
          //           .where(
          //             (p) =>
          //                 p.productName.toLowerCase().contains(v.toLowerCase()),
          //           )
          //           .toList();
          //     });
          //   },
          //   decoration: InputDecoration(
          //     hintText: "Search product by name",
          //     prefixIcon: const Icon(Icons.search),
          //     filled: true,
          //     fillColor: Colors.grey.shade50,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: BorderSide(color: Colors.grey.shade200),
          //     ),
          //     enabledBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: BorderSide(color: Colors.grey.shade200),
          //     ),
          //     contentPadding: const EdgeInsets.symmetric(vertical: 0),
          //   ),
          // ),
          // const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            itemCount: filteredProducts.length,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 5 : 2,

              childAspectRatio: isTablet ? 2.0 : 1.3,

              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),

            itemBuilder: (context, index) {
              final p = filteredProducts[index];

              final isOutOfStock = p.stockEggs <= 0;

              final isSelected = selectedProductIndex == index;

              return InkWell(
                onTap: isOutOfStock
                    ? null
                    : () {
                        setState(() {
                          selectedProductIndex = index;

                          // SHOW
                          showSalesItems = true;
                        });

                        addProductFromCard(p);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),

                  padding: EdgeInsets.all(isTablet ? 8 : 12),

                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.08)
                        : Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,

                      width: isSelected ? 2 : 1,
                    ),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Flexible(
                        child: Text(
                          p.productName,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontWeight: FontWeight.w700,

                            fontSize: isTablet ? 11 : 14,

                            height: 1.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "₹${(p.perTrayPrice / 30).toStringAsFixed(2)} / Egg",

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: Colors.blue,

                          fontWeight: FontWeight.w700,

                          fontSize: isTablet ? 10 : 12,

                          height: 1.0,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Stock: ${p.stockEggs}",

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: isOutOfStock ? Colors.red : Colors.green,

                          fontSize: isTablet ? 10 : 11,

                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (isTablet) ...[
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,

              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 16,

                children: [0.5, 1.0, 1.5, 2.0, 2.5].map((d) {
                  final selected = selectedDozen == d;

                  return AnimatedScale(
                    scale: selected ? 0.92 : 1,

                    duration: const Duration(milliseconds: 120),

                    curve: Curves.easeOut,

                    child: Material(
                      color: Colors.transparent,

                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),

                        splashColor: Colors.blue.withOpacity(0.25),

                        highlightColor: Colors.blue.withOpacity(0.10),

                        onTap: selectedProductIndex == null
                            ? null
                            : () {
                                setState(() {
                                  // selected highlight
                                  selectedDozen = d;
                                });

                                // add dozen
                                selectDozen(d);
                              },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),

                          curve: Curves.easeInOut,

                          width: 52,

                          height: 44,

                          decoration: BoxDecoration(
                            color: selected ? Colors.blue : Colors.white,

                            borderRadius: BorderRadius.circular(8),

                            border: Border.all(
                              color: selected
                                  ? Colors.blue
                                  : Colors.grey.shade300,

                              width: selected ? 2 : 1,
                            ),

                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.25),

                                      blurRadius: 10,

                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),

                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),

                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black,

                                fontWeight: FontWeight.bold,

                                fontSize: selected ? 13 : 14,
                              ),

                              child: Text(d.toStringAsFixed(1)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSalesItemsCard(bool isWide) {
    return _buildCard(
      title: "Sales Items",
      trailing: InkWell(
        onTap: addItem,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
      child: Column(
        children: [
          if (isWide)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),

              color: Colors.grey.shade100,

              child: Row(
                children: const [
                  Expanded(
                    flex: 5,
                    child: Text(
                      "Product",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Text(
                      "Dozen",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Text(
                      "Trays",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "Eggs",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "Rate/Egg",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "Total",

                      textAlign: TextAlign.right,

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(width: 28),
                ],
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: salesItems.length,
            itemBuilder: (context, index) {
              final item = salesItems[index];
              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // Expanded(
                      //   flex: 3,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(horizontal: 5),
                      //     decoration: BoxDecoration(
                      //       border: Border.all(color: Colors.grey.shade300),
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     child: DropdownButtonHideUnderline(
                      //       child: DropdownButton<String>(
                      //         value: item.eggCategoryGrade.isEmpty
                      //             ? null
                      //             : item.eggCategoryGrade,
                      //         isExpanded: true,
                      //         hint: const Text(
                      //           "Select Product",
                      //           style: TextStyle(fontSize: 11),
                      //         ),
                      //         items: products
                      //             .map(
                      //               (p) => DropdownMenuItem(
                      //                 value: p.productName,
                      //                 child: Text(
                      //                   p.productName,
                      //                   style: const TextStyle(fontSize: 11),
                      //                 ),
                      //               ),
                      //             )
                      //             .toList(),
                      //         onChanged: (v) => updateItem(index, 'product', v),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.eggCategoryGrade.isEmpty
                                ? "Select Product"
                                : item.eggCategoryGrade,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: item.eggCategoryGrade.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 60,
                          child: _buildStepper(
                            item.dozen,
                            (v) => updateItem(index, 'dozen', v),
                            isDozen: true,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 60,
                          child: _buildStepper(
                            item.trays.toDouble(),
                            (v) => updateItem(index, 'trays', v.toInt()),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${item.eggs}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            item.eggs == 0
                                ? "0"
                                : (item.total / item.eggs).toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "₹${item.total.toStringAsFixed(1)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      InkWell(
                        onTap: () => removeItem(index),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                      ),
                      // const SizedBox(width: 4),
                      // InkWell(
                      //   onTap: () => removeItem(index),
                      //   child: const Icon(
                      //     Icons.delete_outline,
                      //     color: Color(0xFFEF4444),
                      //     size: 20,
                      //   ),
                      // ),
                    ],
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: item.eggCategoryGrade.isEmpty
                                      ? null
                                      : item.eggCategoryGrade,
                                  isExpanded: true,
                                  hint: const Text(
                                    "Select Product",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  items: products
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p.productName,
                                          child: Text(
                                            p.productName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      updateItem(index, 'product', v),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => removeItem(index),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Dozen",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStepper(
                                  item.dozen,
                                  (v) => updateItem(index, 'dozen', v),
                                  isDozen: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Trays",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStepper(
                                  item.trays.toDouble(),
                                  (v) => updateItem(index, 'trays', v.toInt()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Total Eggs:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${item.eggs}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Price:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "₹${item.total.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF16A34A),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrayTypesCard() {
    return _buildCard(
      title: "Tray Types Used",
      trailing: ElevatedButton.icon(
        onPressed: () => setState(() => saleTrays.add(SaleTray(rate: 1.0))),
        icon: const Icon(Icons.add, size: 14),
        label: const Text("Add Tray", style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...saleTrays.asMap().entries.map((entry) {
            int idx = entry.key;
            SaleTray tray = entry.value;
            return _TrayRow(
              key: ValueKey(tray),
              tray: tray,
              onDelete: () => setState(() => saleTrays.removeAt(idx)),
              onChanged: () => setState(() {}),
              showDelete: true,
            );
          }).toList(),
          const SizedBox(height: 16),
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: DashedLinePainter(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Tray Charges: ₹${totalTrayCharges.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersCard() {
    return _buildCard(
      title: "Available Offers",
      child: Column(
        children: offers.map((o) {
          final isAllProducts = o.category.toLowerCase() == 'all products';
          final matchingItem = salesItems.any(
            (item) => isAllProducts
                ? item.eggCategoryGrade.isNotEmpty
                : item.eggCategoryGrade.toLowerCase() ==
                      o.category.toLowerCase(),
          );

          bool isEligible = false;
          String message = "";
          if (o.offerType == 'buy_x_get_y') {
            final totalEggs = salesItems
                .where(
                  (i) => isAllProducts
                      ? i.eggCategoryGrade.isNotEmpty
                      : i.eggCategoryGrade.toLowerCase() ==
                            o.category.toLowerCase(),
                )
                .fold(0, (sum, i) => sum + i.eggs);
            isEligible = totalEggs >= (o.buyTrays * 30);
            message = "Need ${o.buyTrays} trays";
          } else {
            isEligible = matchingItem;
            message = isAllProducts ? "Add any product" : "Add product";
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: o.applied ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: o.applied ? Colors.green : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        o.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isEligible ? () => toggleOffer(o.id) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: o.applied
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (o.applied) const Icon(Icons.check, size: 14),
                      if (o.applied) const SizedBox(width: 4),
                      Text(
                        o.applied
                            ? "Applied"
                            : (isEligible ? "Apply" : message),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentAndSummaryGrid() {
    final currentTotal = totalAmount.ceilToDouble();
    final entered = double.tryParse(cashReceivedController.text);
    if (cashReceivedController.text.isEmpty || entered == _lastTotalAmount) {
      cashReceivedController.text = currentTotal.toStringAsFixed(2);

      cashReceivedController.selection = TextSelection.fromPosition(
        TextPosition(offset: cashReceivedController.text.length),
      );
    }

    _lastTotalAmount = currentTotal;

    final isTablet = MediaQuery.of(context).size.width >= 500;
    return Column(
      children: [
        _buildCard(
          title: "Payment Method",
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sidebar-like payment selector
                Container(
                  width: isTablet ? 60 : 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _sidebarMethodBtn("CASH"),
                      _sidebarMethodBtn("UPI"),
                      _sidebarMethodBtn("CARD"),
                    ],
                  ),
                ),
                SizedBox(width: isTablet ? 6 : 15),
                // Payment content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedPaymentMethod == "UPI") ...[
                        // 1. Select UPI App
                        const Text(
                          "Select UPI App",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF374151),
                          ),
                        ),

                        SizedBox(height: isTablet ? 10 : 15),

                        Wrap(
                          spacing: isTablet ? 6 : 4,

                          runSpacing: isTablet ? 6 : 4,

                          children: ["Google Pay", "PhonePe", "Paytm"]
                              .map(
                                (app) => ChoiceChip(
                                  label: Text(
                                    app,

                                    style: TextStyle(
                                      fontSize: 11,

                                      color: selectedUpiApp == app
                                          ? Colors.white
                                          : Colors.black,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  selected: selectedUpiApp == app,

                                  onSelected: (v) {
                                    setState(() {
                                      selectedUpiApp = app;
                                    });
                                  },

                                  selectedColor: const Color(0xFF2563EB),

                                  backgroundColor: Colors.white,
                                ),
                              )
                              .toList(),
                        ),

                        SizedBox(height: isTablet ? 10 : 15),

                        // 2. Amount
                        _buildInput(
                          "Enter Amount Received",

                          cashReceivedController,

                          keyboardType: TextInputType.number,

                          hint: "0.00",

                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 24, top: 10),

                            child: Text(
                              "₹",

                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          onChanged: (v) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: isTablet ? 10 : 15),

                        // 3. Optional Details
                        _buildInput(
                          "Other UPI Details (Optional)",

                          otherUpiDetailsController,

                          hint: "Transaction ID / Notes",
                        ),

                        SizedBox(height: isTablet ? 10 : 15),
                      ],
                      // CASH
                      if (selectedPaymentMethod == "CASH") ...[
                        _buildInput(
                          "Enter Amount Received",
                          cashReceivedController,

                          keyboardType: TextInputType.number,

                          hint: "0.00",
                        ),

                        SizedBox(height: isTablet ? 10 : 15),

                        _buildInput("Customer Debt (Optional)", debtController),
                      ],

                      // CARD
                      if (selectedPaymentMethod == "CARD") ...[
                        _buildInput(
                          "Enter Amount Received",
                          cashReceivedController,

                          keyboardType: TextInputType.number,

                          hint: "0.00",
                        ),

                        SizedBox(height: isTablet ? 10 : 15),

                        _buildInput("Customer Debt (Optional)", debtController),
                      ],

                      SizedBox(height: isTablet ? 10 : 15),
                      _buildInput(
                        "Notes",
                        notesController,
                        hint: "Add internal notes",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // const SizedBox(height: 16),
        // _buildCard(
        //   title: "Bill Summary",
        //   child: Column(
        //     children: [
        //       _summaryRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
        //       _summaryRow(
        //         "Discount",
        //         "-₹${totalDiscount.toStringAsFixed(2)}",
        //         color: const Color(0xFFEF4444),
        //       ),
        //       const Divider(height: 40),
        //       _summaryRow(
        //         "Total",
        //         "₹${totalAmount.toStringAsFixed(2)}",
        //         isBold: true,
        //       ),
        //       const SizedBox(height: 25),
        //       SizedBox(
        //         width: double.infinity,
        //         height: 55,
        //         child: ElevatedButton(
        //           onPressed: isSubmitting ? null : handlePayment,
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: AppColors.blueAccent,
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(15),
        //             ),
        //             elevation: 4,
        //           ),
        //           child: isSubmitting
        //               ? const CircularProgressIndicator(color: Colors.white)
        //               : const Text(
        //                   "Complete Sale",
        //                   style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 16,
        //                     fontWeight: FontWeight.w800,
        //                   ),
        //                 ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildBillSummaryCard() {
    return _buildCard(
      title: "Bill Summary",

      child: Column(
        children: [
          _summaryRow("Subtotal", "₹ ${subtotal.toStringAsFixed(2)}"),

          _summaryRow(
            "Discount",
            "- ₹ ${totalDiscount.toStringAsFixed(2)}",

            color: const Color(0xFFEF4444),
          ),

          if (totalTrayCharges > 0)
            _summaryRow(
              "Tray Charges",
              "₹ ${totalTrayCharges.toStringAsFixed(2)}",
            ),

          const Divider(height: 40),
          _summaryRow(" Total", "₹ ${(totalAmount).toStringAsFixed(2)}"),
          _summaryRow(
            "Grand Total",
            "₹ ${(totalAmount.ceilToDouble()).toStringAsFixed(2)}",
            isBold: true,
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 40,

            child: ElevatedButton(
              onPressed: isSubmitting ? null : handlePayment,

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueAccent,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                elevation: 4,
              ),

              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Complete Sale",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarMethodBtn(String method) {
    bool active = selectedPaymentMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedPaymentMethod = method),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            method,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(
    double value,
    Function(double) onChanged, {
    bool isDozen = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    // TABLET ONLY
    final bool isTablet = screenWidth >= 700;

    return Container(
      height: 40,

      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),

        borderRadius: BorderRadius.circular(8),

        color: Colors.white,
      ),

      child: Row(
        children: [
          // REMOVE BUTTON
          InkWell(
            onTap: () {
              if (value > 0) {
                onChanged(value - (isDozen ? 0.5 : 1));
              }
            },

            child: Padding(
              padding: const EdgeInsets.all(4),

              child: Container(
                width: 30,
                height: 34,

                alignment: Alignment.center,

                decoration: isTablet
                    ? BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(6),

                        border: Border.all(color: Colors.grey.shade300),
                      )
                    : null,

                child: const Icon(Icons.remove, size: 12, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Text(
              isDozen ? value.toStringAsFixed(1) : value.toInt().toString(),

              textAlign: TextAlign.center,

              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),

          // ADD BUTTON
          InkWell(
            onTap: () => onChanged(value + (isDozen ? 0.5 : 1)),

            child: Padding(
              padding: const EdgeInsets.all(6),

              child: Container(
                width: 30,
                height: 34,

                alignment: Alignment.center,

                // TABLET ONLY CONTAINER
                decoration: isTablet
                    ? BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(6),

                        border: Border.all(color: Colors.grey.shade300),
                      )
                    : null,

                child: const Icon(Icons.add, size: 12, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
        // ignore: deprecated_member_use
        // boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    String? hint,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    Widget? suffix,
    Widget? prefix,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final width = MediaQuery.of(context).size.width;

    final compactTablet = width >= 600 && width < 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: compactTablet ? 12 : 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
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
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: compactTablet ? 4 : 12,
            ),

            constraints: BoxConstraints(minHeight: compactTablet ? 42 : 52),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              fontSize: isBold ? 18 : 15,
              color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color:
                  color ??
                  (isBold ? const Color(0xFF1E293B) : const Color(0xFF1E293B)),
              fontSize: isBold ? 22 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String saleId;
  final double amount;
  final bool isPending;
  final String customerName;
  final String customerNumber;
  final String date;
  final List<SalesItem> items;
  final double discount;
  final double subtotal;
  final double trayCharges;
  final String paymentMethod;
  final VoidCallback onNextSale;
  final VoidCallback onDashboard;

  const _SuccessDialog({
    required this.saleId,
    required this.amount,
    required this.isPending,
    required this.customerName,
    required this.customerNumber,
    required this.date,
    required this.items,
    required this.discount,
    required this.subtotal,
    required this.trayCharges,
    required this.paymentMethod,
    required this.onNextSale,
    required this.onDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isTablet = width >= 600;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 120 : 20,
        vertical: isTablet ? 20 : 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 30),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 22 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 18 : 25),
              decoration: BoxDecoration(
                color: isPending
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.timer_outlined : Icons.check_circle_outline,
                size: isTablet ? 40 : 70,
                color: isPending
                    ? const Color(0xFFF97316)
                    : const Color(0xFF22C55E),
              ),
            ),
            SizedBox(height: isTablet ? 13 : 22),
            Text(
              isPending ? "Approval Requested" : "Payment Successful!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 18 : 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? "This sale exceeds egg limits and requires admin approval."
                  : "Your transaction has been recorded successfully.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isTablet ? 13 : 32),
            _infoBox(
              isPending ? "Request ID:" : "Sale ID:",
              "#$saleId",
              isPending ? "REQ" : "S",
            ),
            _infoBox(
              "Amount Paid:",
              "₹${amount.ceilToDouble().toStringAsFixed(2)}",
              "INR",
            ),
            SizedBox(height: isTablet ? 8 : 32),
            if (!isPending)
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,

                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),

                        splashColor: Colors.amber.withOpacity(0.30),

                        highlightColor: Colors.yellow.withOpacity(0.15),

                        onTap: () async {
                          await SalesReceiptService.generateAndPrintReceipt(
                            saleId: saleId,
                            customerName: customerName,
                            customerNumber: customerNumber,
                            date: date,
                            items: items,
                            subtotal: subtotal,
                            discount: discount,
                            total: amount,
                            trayCharges: trayCharges,
                            paymentMethod: paymentMethod,
                            isThermal: false,
                          );
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),

                          padding: const EdgeInsets.symmetric(vertical: 10),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(16),

                            border: Border.all(color: Colors.blue, width: 1.5),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(
                                Icons.file_download_outlined,

                                color: Colors.blue,

                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              const Text(
                                "PDF",

                                style: TextStyle(
                                  color: Colors.blue,

                                  fontWeight: FontWeight.w800,

                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,

                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),

                        splashColor: Colors.orange.withOpacity(0.30),

                        highlightColor: Colors.amber.withOpacity(0.15),

                        onTap: () async {
                          await SalesReceiptService.generateAndPrintReceipt(
                            saleId: saleId,
                            customerName: customerName,
                            customerNumber: customerNumber,
                            date: date,
                            items: items,
                            subtotal: subtotal,
                            discount: discount,
                            total: amount,
                            trayCharges: trayCharges,
                            paymentMethod: paymentMethod,
                            isThermal: true,
                          );
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),

                          padding: const EdgeInsets.symmetric(vertical: 10),

                          decoration: BoxDecoration(
                            color: Colors.blue,

                            borderRadius: BorderRadius.circular(16),

                            border: Border.all(color: Colors.blue, width: 1.5),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(
                                Icons.print_outlined,

                                color: Colors.white,

                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              const Text(
                                "Print",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontWeight: FontWeight.w800,

                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: isTablet ? 13 : 32),
            SizedBox(
              width: double.infinity,
              height: isTablet ? 40 : 55,
              child: ElevatedButton(
                onPressed: onNextSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Next Sale",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onDashboard,
              child: const Text(
                "Back to Dashboard",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
  //   return OutlinedButton.icon(
  //     onPressed: onTap,
  //     icon: Icon(icon, size: 20),
  //     label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
  //     style: OutlinedButton.styleFrom(
  //       foregroundColor: const Color(0xFF1E293B),
  //       side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       padding: const EdgeInsets.symmetric(vertical: 12),
  //     ),
  //   );
  // }
}
