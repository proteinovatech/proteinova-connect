import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc
    extends Bloc<InventoryEvent, InventoryState> {

  InventoryBloc() : super(InventoryInitial()) {

    on<FetchInventoryEvent>(_fetchInventory);

    on<RefreshInventoryEvent>(_fetchInventory);
  }

  Future<void> _fetchInventory(
    InventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {

    emit(InventoryLoading());

    try {

      final String baseUrl =
          dotenv.env['BASE_URL'] ?? "";

      int branchId = 1;
      if (event is FetchInventoryEvent && event.branchId != null) {
        branchId = event.branchId!;
      } else if (event is RefreshInventoryEvent && event.branchId != null) {
        branchId = event.branchId!;
      }

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/branch/incoming-stock/$branchId",
        ),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        emit(InventoryLoaded(data));

      } else {

        emit(
          InventoryError(
            "Failed : ${response.statusCode}",
          ),
        );
      }

    } catch (e) {

      emit(
        InventoryError(e.toString()),
      );
    }
  }
}