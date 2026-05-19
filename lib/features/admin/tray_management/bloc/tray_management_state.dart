import '../models/tray_inventory_model.dart';

class TrayManagementState {
  final bool isLoading;
  final bool isAdding;
  final List<TrayInventoryModel> inventory;
  final String? error;
  final bool addSuccess;

  TrayManagementState({
    this.isLoading = false,
    this.isAdding = false,
    this.inventory = const [],
    this.error,
    this.addSuccess = false,
  });

  TrayManagementState copyWith({
    bool? isLoading,
    bool? isAdding,
    List<TrayInventoryModel>? inventory,
    String? error,
    bool? addSuccess,
    bool clearError = false,
  }) {
    return TrayManagementState(
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      inventory: inventory ?? this.inventory,
      error: clearError ? null : (error ?? this.error),
      addSuccess: addSuccess ?? this.addSuccess,
    );
  }
}
