import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/tray_management_service.dart';
import 'tray_management_event.dart';
import 'tray_management_state.dart';

class TrayManagementBloc extends Bloc<TrayManagementEvent, TrayManagementState> {
  final TrayManagementService service;

  TrayManagementBloc(this.service) : super(TrayManagementState()) {
    on<FetchInventoryEvent>(_onFetchInventory);
    on<AddTraysToLocationEvent>(_onAddTraysToLocation);
    on<ReturnTraysToWarehouseEvent>(_onReturnTraysToWarehouse);
  }

  Future<void> _onFetchInventory(
    FetchInventoryEvent event,
    Emitter<TrayManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, addSuccess: false, returnSuccess: false));
    try {
      final inventory = await service.getInventory();
      final pendingReturns = await service.getPendingReturns();
      emit(state.copyWith(isLoading: false, inventory: inventory, pendingReturns: pendingReturns));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddTraysToLocation(
    AddTraysToLocationEvent event,
    Emitter<TrayManagementState> emit,
  ) async {
    emit(state.copyWith(isAdding: true, clearError: true, addSuccess: false, returnSuccess: false));
    try {
      await service.addToLocation(event.locationName, event.plasticTrays, event.paperTrays);
      emit(state.copyWith(isAdding: false, addSuccess: true));
      add(FetchInventoryEvent()); // Refresh inventory after adding
    } catch (e) {
      emit(state.copyWith(isAdding: false, error: e.toString()));
    }
  }

  Future<void> _onReturnTraysToWarehouse(
    ReturnTraysToWarehouseEvent event,
    Emitter<TrayManagementState> emit,
  ) async {
    emit(state.copyWith(isAdding: true, clearError: true, addSuccess: false, returnSuccess: false));
    try {
      await service.returnToWarehouse(event.branchName, event.plasticTrays, event.paperTrays);
      emit(state.copyWith(isAdding: false, returnSuccess: true));
      add(FetchInventoryEvent()); // Refresh inventory after returning
    } catch (e) {
      emit(state.copyWith(isAdding: false, error: e.toString()));
    }
  }
}
