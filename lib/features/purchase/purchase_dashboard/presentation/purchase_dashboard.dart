import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/core/theme/app_colors.dart';
import 'package:proteinova_connect/core/theme/app_text_styles.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/presentation/newpurchase.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_state.dart';

import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchase_dashboard_shimmer.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/widget/purchasecard.dart';

class PurchaseDashboard extends StatefulWidget {
  const PurchaseDashboard({super.key});

  @override
  State<PurchaseDashboard> createState() => _PurchaseDashboardState();
}

class _PurchaseDashboardState extends State<PurchaseDashboard> {
  
 static bool _hasLoadedOnce = false;
String? loadingPurchaseId;
  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cache = PurchaseCacheService();

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER (fixed)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Column(
                children: [
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/erplogo.png",
                          height: 37, width: 130),
                      // Icon(Icons.notifications_outlined,
                      //     color: AppColors.textSecondary),
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
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },

                child: BlocBuilder<PurchaseBloc, PurchaseState>(
                  builder: (context, state) {

                   
                    if (state is PurchaseLoading )  {
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

                    return ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.03),
                      children: [

                        Text("Purchase",
                            style: AppTextStyles.headingText25),

                        Text(
                          "Manage Purchase orders and Incoming stocks.",
                          style: AppTextStyles.bodyText16,
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
                                        SupplierRepository(
                                            DioClient().dio),
                                      )..add(FetchSuppliers()),
                                    ),
                                    BlocProvider(
                                      create: (_) => PurchaseBloc(
                                        SupplierRepository(
                                            DioClient().dio),
                                        PurchaseRepository(
                                            DioClient().dio, cache,),PurchaseCacheService(),
                                      )..add(FetchPurchaseInitData()),
                                    ),
                                  ],
                                  child: Newpurchase(
                                      isEdit: false,
                                      purchaseData: null),
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
                                Icon(Icons.add,
                                    color: AppColors.dark),
                                const SizedBox(width: 8),
                                Text("New Purchase Entry",
                                    style:
                                        AppTextStyles.headingText20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// PURCHASE LIST
                        ...state.purchases.map((p) {
  final items = p["items"] ?? [];
  final expenses = p["expenses"] ?? [];
  final itemsCost = items.fold(
  0.0,
  (sum, e) =>
      sum +
      ((e["trays"] ?? 0) *
          (e["capacity"] ?? 0) *
          (e["per_egg_price"] ?? 0)),
);
  

  final expenseCost = expenses.fold(
    0.0,
    (sum, e) => sum + (e["amount"] ?? 0),
  );

  final totalCost = itemsCost + expenseCost;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        PurchaseCard(
           isLoading:
      loadingPurchaseId == p['id'].toString(),
          movementStatus: p['movement_status'] ?? 'PENDING',
            onArrivalTap: () async {
               setState(() {
    loadingPurchaseId = p['id'].toString();
  });

                         context.read<PurchaseBloc>().add(
                           UpdateArrivalEvent(
                             purchaseId: p['id'].toString(),
                             data: {
    "movement_status": "RECEIVED"
  },
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
          itemboxes:
              "${items.fold(0, (sum, e) => sum + (e["trays"] as int))} Trays",
              
              
        ),

        const SizedBox(height: 8),
        
       
      ],
    ),
  );
}).toList(),

                        const SizedBox(height: 20),
                      ],
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

  Widget filterBox(IconData icon, String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey),
        ],
      ),
    );
  }
}
