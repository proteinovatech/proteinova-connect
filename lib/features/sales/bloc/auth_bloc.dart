import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/sales/bloc/auth_event.dart';
import 'package:proteinova_connect/features/sales/bloc/auth_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {

    on<CreateNewSaleEvent>((event, emit) {
      // Do your logic here
      emit(SalesLoading());

      // Example (you can call API here)
      emit(SalesSuccess());
    });

  }
}