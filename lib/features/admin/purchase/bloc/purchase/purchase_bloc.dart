import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';
 class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final SupplierRepository supplierRepository;
  final PurchaseRepository purchaseRepository;
  final PurchaseCacheService cache;
  List<dynamic> _allPurchases = [];
  PurchaseBloc(this.supplierRepository, this.purchaseRepository,this.cache)
      : super(PurchaseInitial()) {
    on<SubmitPurchaseEvent>(_onSubmitPurchase);
    /// 🔹 INIT (Suppliers)
    on<FetchPurchaseInitData>((event, emit) async {
      emit(PurchaseLoading());
      try {
        final suppliers = await supplierRepository.fetchSuppliers();
        final purchases = await purchaseRepository.getPurchases();
        _allPurchases = purchases;
        await cache.savePurchases(purchases);

        emit(PurchaseLoaded(
          allPurchases: purchases,
          suppliers: suppliers,
          purchases: purchases,
        ));
      } catch (e) {
        emit(PurchaseError(e.toString()));
      }
    });
    on<GetCachedPurchasesEvent>((event, emit) async {
  final cacheData = cache.getPurchases();
   _allPurchases = cacheData;
  if (cacheData.isNotEmpty) {
    emit(PurchaseLoaded(
      allPurchases: cacheData,
      purchases: cacheData));
  } else {
    emit(PurchaseLoading());
  }

  // then fetch API in background
  add(GetPurchasesEvent());
});

    
    on<GetPurchasesEvent>((event, emit) async {
  
  try {
    final data = await purchaseRepository.getPurchases();

    _allPurchases = data;
     await cache.savePurchases(data);

    emit(PurchaseLoaded(
      allPurchases: data,
      purchases: data,
    ));
  } catch (e) {
    emit(PurchaseError("Failed to load purchases"));
  }
});
on<UpdateArrivalEvent>((event, emit) async {
  try {
    final response = await purchaseRepository.updateArrival(
  int.parse(event.purchaseId),
  event.data,
);

    final message = response['message']; 

    final updatedList = await purchaseRepository.getPurchases();

    emit(PurchaseLoaded(
      allPurchases: _allPurchases,
      purchases: updatedList,
      message: message, 
    ));

  } catch (e) {
    emit(PurchaseError("Failed to update arrival"));
  }
});
on<SearchPurchaseEvent>((event, emit) {
  final query = event.query.toLowerCase().trim();

  final filtered = query.isEmpty
      ? _allPurchases
      : _allPurchases.where((p) {
          final supplier = (p['supplier_company_name'] ?? '')
              .toString()
              .toLowerCase();

          final id = "po-${p['id']}".toLowerCase();

          return supplier.contains(query) || id.contains(query);
        }).toList();

  emit(PurchaseLoaded(
    allPurchases: _allPurchases,
    purchases: List.from(filtered),
  ));
});

  }
  Future<void> _onSubmitPurchase(
  SubmitPurchaseEvent event,
  Emitter<PurchaseState> emit,
) async {
  try {
    emit(PurchaseSubmitting());

    await purchaseRepository.postPurchase(event.purchase);

    // refresh purchase list
    final updatedList = await purchaseRepository.getPurchases();

    _allPurchases = updatedList;

    emit(PurchaseSubmitSuccess());

    emit(
      PurchaseLoaded(
        allPurchases: updatedList,
        purchases: updatedList,
      ),
    );
  } catch (e) {
    emit(PurchaseSubmitFailure(
      "Failed to submit purchase",
    ));
  }
}

}


    
