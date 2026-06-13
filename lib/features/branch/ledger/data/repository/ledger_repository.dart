import '../datasource/ledger_remote_datasource.dart';
import '../model/ledger_model.dart';

class LedgerRepository {
  final LedgerRemoteDatasource _datasource = LedgerRemoteDatasource();

  Future<List<LedgerEntry>> fetchLedger(int branchId) {
    return _datasource.fetchLedger(branchId);
  }

  Future<void> recordPayment({
    required int customerId,
    required double amount,
    required int branchId,
  }) {
    return _datasource.recordPayment(
      customerId: customerId,
      amount: amount,
      branchId: branchId,
    );
  }
}
