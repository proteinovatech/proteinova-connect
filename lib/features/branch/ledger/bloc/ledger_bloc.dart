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
      final ledger = await _repository.fetchLedger();
      print("Summary => ${ledger.summary.totalOutstanding}");
print("Charged => ${ledger.summary.totalCharged}");
print("Paid => ${ledger.summary.totalPaid}");
      emit(LedgerLoaded(ledger));
    } catch (e) {
      emit(LedgerError(e.toString()));
    }
  }

Future<void> _onRecordPayment(
  RecordPaymentEvent event,
  Emitter<LedgerState> emit,
) async {
  final currentLedger = state is LedgerLoaded
      ? (state as LedgerLoaded).ledger
      : state is PaymentSuccess
          ? (state as PaymentSuccess).ledger
          : LedgerModel(
               summary: Summary(
    totalOutstanding: 0,
    totalCharged: 0,
    totalPaid: 0,
    pendingCount: 0,
    clearedCount: 0,
  ),
              customers: [],
              branches: [],
            );

  emit(PaymentSubmitting(currentLedger));

  try {
    await _repository.recordPayment(
      customerId: event.customerId,
      amount: event.amount,
      branchId: event.branchId,
    );

    final updatedLedger = await _repository.fetchLedger();

    emit(PaymentSuccess(updatedLedger));
  } catch (e) {
    emit(PaymentFailure(currentLedger, e.toString()));
  }
}
}
