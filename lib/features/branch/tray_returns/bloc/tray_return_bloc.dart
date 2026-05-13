import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/tray_returns/data/model/tray_return_model.dart';
import 'package:proteinova_connect/features/branch/tray_returns/data/repository/tray_return_repository.dart';

part 'tray_return_event.dart';
part 'tray_return_state.dart';

class TrayReturnBloc extends Bloc<TrayReturnEvent, TrayReturnState> {
  final TrayReturnRepository repository;

  TrayReturnBloc({required this.repository}) : super(TrayReturnInitial()) {
    on<FetchTrayReturnData>((event, emit) async {
      emit(TrayReturnLoading());
      try {
        final model = await repository.fetchTrayReturnData(event.branchId, event.date);
        emit(TrayReturnLoaded(model));
      } catch (e) {
        emit(TrayReturnError(e.toString()));
      }
    });

    on<SubmitTrayReturn>((event, emit) async {
      emit(TrayReturnSubmitting());
      try {
        final result = await repository.submitTrayReturn(event.data);
        emit(TrayReturnSuccess(result['message'] ?? "Tray return submitted successfully"));
      } catch (e) {
        emit(TrayReturnError(e.toString()));
      }
    });
  }
}
