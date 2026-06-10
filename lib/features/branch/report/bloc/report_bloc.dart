import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository = ReportRepository();

  ReportBloc() : super(ReportInitial()) {
    on<FetchBranchReportEvent>(_onFetchBranchReport);
  }

  Future<void> _onFetchBranchReport(
    FetchBranchReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final data = await _repository.fetchReport(
        event.branchId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(ReportLoaded(data));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
