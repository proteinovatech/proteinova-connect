import '../data/model/ledger_model.dart';

abstract class LedgerState {}

class LedgerInitial extends LedgerState {}

class LedgerLoading extends LedgerState {}

class LedgerLoaded extends LedgerState {
  final LedgerModel ledger;

  LedgerLoaded(this.ledger);
}

class LedgerError extends LedgerState {
  final String message;

  LedgerError(this.message);
}

class PaymentSubmitting extends LedgerState {
  final LedgerModel ledger;

  PaymentSubmitting(this.ledger);
}

class PaymentSuccess extends LedgerState {
  final LedgerModel ledger;

  PaymentSuccess(this.ledger);
}

class PaymentFailure extends LedgerState {
  final LedgerModel ledger;
  final String message;

  PaymentFailure(this.ledger, this.message);
}