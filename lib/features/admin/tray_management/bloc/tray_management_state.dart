import '../models/tray_inventory_model.dart';

class TrayManagementState {
  final bool isLoading;
  final bool isAdding;
  final List<TrayInventoryModel> inventory;
  final List<dynamic> pendingReturns;
  final String? error;
  final bool addSuccess;
  final bool returnSuccess;

  TrayManagementState({
    this.isLoading = false,
    this.isAdding = false,
    this.inventory = const [],
    this.pendingReturns = const [],
    this.error,
    this.addSuccess = false,
    this.returnSuccess = false,
  });

  TrayManagementState copyWith({
    bool? isLoading,
    bool? isAdding,
    List<TrayInventoryModel>? inventory,
    List<dynamic>? pendingReturns,
    String? error,
    bool? addSuccess,
    bool? returnSuccess,
    bool clearError = false,
  }) {
    return TrayManagementState(
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      inventory: inventory ?? this.inventory,
      pendingReturns: pendingReturns ?? this.pendingReturns,
      error: clearError ? null : (error ?? this.error),
      addSuccess: addSuccess ?? this.addSuccess,
      returnSuccess: returnSuccess ?? this.returnSuccess,
    );
  }
}
