import '../data/model/ledger_model.dart';

abstract class LedgerState {}

class LedgerInitial extends LedgerState {}

class LedgerLoading extends LedgerState {}

class LedgerLoaded extends LedgerState {
  final List<LedgerEntry> entries;

  LedgerLoaded(this.entries);
}

class LedgerError extends LedgerState {
  final String message;
  LedgerError(this.message);
}

class PaymentSubmitting extends LedgerState {
  final List<LedgerEntry> entries;
  PaymentSubmitting(this.entries);
}

class PaymentSuccess extends LedgerState {
  final List<LedgerEntry> entries;
  PaymentSuccess(this.entries);
}

class PaymentFailure extends LedgerState {
  final List<LedgerEntry> entries;
  final String message;
  PaymentFailure(this.entries, this.message);
}
