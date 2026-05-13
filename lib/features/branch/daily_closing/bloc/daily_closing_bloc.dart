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
        final response = await repository.closeDay(event.branchId, event.date);
        emit(DailyClosingSuccess(response['message'] ?? "Day closed successfully"));
      } catch (e) {
        emit(DailyClosingError(e.toString()));
      }
    });
  }
}
