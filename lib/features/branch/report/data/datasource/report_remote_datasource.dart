import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import '../model/report_model.dart';

class ReportRemoteDatasource {
  Future<ReportData> fetchReport(int branchId, {String? startDate, String? endDate}) async {
    try {
      // Using the existing Dashboard API as a proxy for the Report
      String url = ApiConstants.dashboard(branchId);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        final cards = responseData['cards'] ?? {};

        // Mapping Dashboard data to ReportData
        return ReportData(
          totalRevenue: double.tryParse(cards['sales_today']?.toString() ?? '0') ?? 0.0,
          totalExpenses: double.tryParse(cards['today_expense']?.toString() ?? '0') ?? 0.0,
          totalSalesOrders: int.tryParse(cards['today_tray_sold']?.toString() ?? '0') ?? 0,
          totalPendingCollection: 0.0, // Dashboard doesn't provide ledger/pending collection
          totalTraysReturned: int.tryParse(cards['damaged_stock']?.toString() ?? '0') ?? 0, // Using damaged stock as proxy since tray returns isn't in cards
          categorySales: [], // Dashboard doesn't provide granular sales categories in cards
          expenseCategories: (responseData['today_expenses_list'] as List<dynamic>?)
              ?.map((e) => ExpenseCategory(
                name: e['category'] ?? 'Unknown',
                amount: double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0,
              ))
              .toList() ?? [],
        );
      } else {
        throw Exception('Failed to load report (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }
}
