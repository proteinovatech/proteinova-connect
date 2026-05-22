import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/tray_management_service.dart';
import 'tray_management_event.dart';
import 'tray_management_state.dart';

class TrayManagementBloc extends Bloc<TrayManagementEvent, TrayManagementState> {
  final TrayManagementService service;

  TrayManagementBloc(this.service) : super(TrayManagementState()) {
    on<FetchInventoryEvent>(_onFetchInventory);
    on<AddTraysEvent>(_onAddTrays);
  }

  Future<void> _onFetchInventory(
    FetchInventoryEvent event,
    Emitter<TrayManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, addSuccess: false));
    try {
      final inventory = await service.getInventory();
      emit(state.copyWith(isLoading: false, inventory: inventory));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddTrays(
    AddTraysEvent event,
    Emitter<TrayManagementState> emit,
  ) async {
    emit(state.copyWith(isAdding: true, clearError: true, addSuccess: false));
    try {
      await service.addTraysToNamakkal(event.plasticTrays, event.paperTrays);
      emit(state.copyWith(isAdding: false, addSuccess: true));
      add(FetchInventoryEvent()); // Refresh inventory after adding
    } catch (e) {
      emit(state.copyWith(isAdding: false, error: e.toString()));
    }
  }
}
