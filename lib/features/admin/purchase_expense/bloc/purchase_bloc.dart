import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/bloc/purchase_event.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/bloc/purchase_state.dart';
import 'package:proteinova_connect/features/admin/purchase_expense/data/repository/purchase_expense_repository.dart';


class PurchaseExpenseBloc
    extends Bloc<PurchaseExpenseEvent, PurchaseExpenseState> {
  final PurchaseExpenseRepository repository;

  PurchaseExpenseBloc(this.repository)
      : super(const PurchaseExpenseState()) {

    on<LoadPurchaseExpenseData>(_onLoadInitialData);

    on<LoadPurchaseDetail>(_onLoadPurchaseDetail);

    on<SaveExpenseEvent>(_onSaveExpense);

    on<MarkArrivalEvent>(_onMarkArrival);
  }

  /// LOAD PURCHASES + SUPPLIERS
  Future<void> _onLoadInitialData(
    LoadPurchaseExpenseData event,
    Emitter<PurchaseExpenseState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      isSuccess: false,
      error: null,
    ));

    try {
      final purchasesData =
          await repository.fetchPurchases();

      final suppliersData =
          await repository.fetchSuppliers();

      emit(state.copyWith(
        isLoading: false,
        purchases: purchasesData,
        suppliers: suppliersData,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// LOAD PURCHASE DETAIL
  Future<void> _onLoadPurchaseDetail(
    LoadPurchaseDetail event,
    Emitter<PurchaseExpenseState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
    ));

    try {
      final detail = await repository
          .fetchPurchaseDetail(event.purchaseId);

      emit(state.copyWith(
        isLoading: false,
        purchaseDetail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// SAVE EXPENSE
  Future<void> _onSaveExpense(
    SaveExpenseEvent event,
    Emitter<PurchaseExpenseState> emit,
  ) async {
    emit(state.copyWith(
      isSaving: true,
      error: null,
      isSuccess: false,
    ));

    try {
      await repository.saveExpenses(
        purchaseId: event.purchaseId,
        loading: event.loading,
        unloading: event.unloading,
        transport: event.transport,
      );

      emit(state.copyWith(
        isSaving: false,
        isSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: e.toString(),
      ));
    }
  }

  /// MARK ARRIVAL
  Future<void> _onMarkArrival(
    MarkArrivalEvent event,
    Emitter<PurchaseExpenseState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
    ));

    try {
      await repository.markArrival(event.purchaseId);

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}