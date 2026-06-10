import '../datasource/report_remote_datasource.dart';
import '../model/report_model.dart';

class ReportRepository {
  final ReportRemoteDatasource _datasource = ReportRemoteDatasource();

  Future<ReportData> fetchReport(int branchId, {String? startDate, String? endDate}) {
    return _datasource.fetchReport(branchId, startDate: startDate, endDate: endDate);
  }
}
