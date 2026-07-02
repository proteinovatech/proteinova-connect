abstract class LedgerEvent {}

class FetchLedgerEvent extends LedgerEvent {}

class RecordPaymentEvent extends LedgerEvent {
  final int customerId;
  final double amount;
  final int branchId;

  RecordPaymentEvent({
    required this.customerId,
    required this.amount,
    required this.branchId,
  });
}
