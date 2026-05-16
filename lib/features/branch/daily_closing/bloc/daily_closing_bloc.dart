import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/daily_closing/data/model/daily_closing_model.dart';
import 'package:proteinova_connect/features/branch/daily_closing/data/repository/dailyclosing_repository.dart';

part 'daily_closing_event.dart';
part 'daily_closing_state.dart';

class DailyClosingBloc extends Bloc<DailyClosingEvent, DailyClosingState> {
  final DailyClosingRepository repository;

  DailyClosingBloc({required this.repository}) : super(DailyClosingInitial()) {
    on<FetchDailyClosingData>((event, emit) async {
      emit(DailyClosingLoading());
      try {
        final model = await repository.fetchDailyClosing(event.branchId, event.date);
        emit(DailyClosingLoaded(model));
      } catch (e) {
        emit(DailyClosingError(e.toString()));
      }
    });

    on<SubmitDailyClosing>((event, emit) async {
      emit(DailyClosingSubmitting());
      try {
        final payload = {
          "status": event.status,
          "notes": event.notes,
          "counted_cash": event.countedCash,
          "login_user_id": 1 // Default as per React code
        };
        final response = await repository.closeDay(event.branchId, payload);
        emit(DailyClosingSuccess(response['message'] ?? "Action completed successfully"));
      } catch (e) {
        emit(DailyClosingError(e.toString()));
      }
    });
  }
}
