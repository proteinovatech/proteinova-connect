import 'package:equatable/equatable.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/data/models/purchase_detail_response.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/data/models/purchase_list_item.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/data/models/supplier_item.dart';


class PurchaseExpenseState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isSuccess;

  final List<PurchaseListItem> purchases;
  final List<SupplierItem> suppliers;

  final PurchaseDetailResponse? purchaseDetail;

  final String? error;

  const PurchaseExpenseState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSuccess = false,
    this.purchases = const [],
    this.suppliers = const [],
    this.purchaseDetail,
    this.error,
  });

  PurchaseExpenseState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSuccess,
    List<PurchaseListItem>? purchases,
    List<SupplierItem>? suppliers,
    PurchaseDetailResponse? purchaseDetail,
    String? error,
  }) {
    return PurchaseExpenseState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      purchases: purchases ?? this.purchases,
      suppliers: suppliers ?? this.suppliers,
      purchaseDetail: purchaseDetail ?? this.purchaseDetail,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        isSuccess,
        purchases,
        suppliers,
        purchaseDetail,
        error,
      ];
}