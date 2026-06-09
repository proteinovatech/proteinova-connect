import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/ledger_model.dart';
import '../data/repository/ledger_repository.dart';
import 'ledger_event.dart';
import 'ledger_state.dart';

class LedgerBloc extends Bloc<LedgerEvent, LedgerState> {
  final LedgerRepository _repository = LedgerRepository();

  LedgerBloc() : super(LedgerInitial()) {
    on<FetchLedgerEvent>(_onFetchLedger);
    on<RecordPaymentEvent>(_onRecordPayment);
  }

  Future<void> _onFetchLedger(
    FetchLedgerEvent event,
    Emitter<LedgerState> emit,
  ) async {
    emit(LedgerLoading());
    try {
      final entries = await _repository.fetchLedger(event.branchId);
      emit(LedgerLoaded(entries));
    } catch (e) {
      emit(LedgerError(e.toString()));
    }
  }

  Future<void> _onRecordPayment(
    RecordPaymentEvent event,
    Emitter<LedgerState> emit,
  ) async {
    // Keep current entries visible while submitting
    final currentEntries = state is LedgerLoaded
        ? (state as LedgerLoaded).entries
        : state is PaymentSuccess
            ? (state as PaymentSuccess).entries
            : <LedgerEntry>[];

    emit(PaymentSubmitting(currentEntries));
    try {
      await _repository.recordPayment(
        customerId: event.customerId,
        amount: event.amount,
        branchId: event.branchId,
      );
      // Re-fetch to get updated balances
      final updatedEntries = await _repository.fetchLedger(event.branchId);
      emit(PaymentSuccess(updatedEntries));
    } catch (e) {
      emit(PaymentFailure(currentEntries, e.toString()));
    }
  }
}
