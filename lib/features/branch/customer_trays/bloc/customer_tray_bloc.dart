import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/service/customer_tray_service.dart';
import 'customer_tray_event.dart';
import 'customer_tray_state.dart';

class CustomerTrayBloc
    extends Bloc<CustomerTrayEvent, CustomerTrayState> {
  CustomerTrayBloc() : super(CustomerTrayInitial()) {
    on<FetchCustomerTraysEvent>(_fetchCustomerTrays);
  }

  Future<void> _fetchCustomerTrays(
    FetchCustomerTraysEvent event,
    Emitter<CustomerTrayState> emit,
  ) async {
    emit(CustomerTrayLoading());

    try {
      final prefs =
          await SharedPreferences.getInstance();

      final branchId =
          prefs.getInt('branch_id') ?? 1;

      final trays =
          await CustomerTrayService.getCustomerTrays(
        branchId: branchId,
        search: event.search,
      );

      emit(CustomerTrayLoaded(trays));
    } catch (e) {
      emit(CustomerTrayError(e.toString()));
    }
  }
}