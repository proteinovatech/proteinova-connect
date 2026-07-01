import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import '../model/ledger_model.dart';

class LedgerRemoteDatasource {
  Future<List<LedgerEntry>> fetchLedger(int branchId) async {
    try {
      final url = ApiConstants.ledger(branchId);

      print("Ledger API URL => $url");
      print("Branch ID => $branchId");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      print("Status Code => ${response.statusCode}");
      print("Response Body => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> list = data['data'] is List
            ? data['data']
            : (data is List ? data : []);

        return list.map((e) => LedgerEntry.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load ledger (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching ledger: $e');
    }
  }

  Future<void> recordPayment({
    required int customerId,
    required double amount,
    required int branchId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.ledgerPayment),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'amount': amount,
          'branch_id': branchId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          final data = jsonDecode(response.body);
          throw Exception(data['message'] ?? 'Failed to record payment');
        } catch (_) {
          throw Exception(
            'Server returned an invalid response (${response.statusCode})',
          );
        }
      }
    } catch (e) {
      throw Exception('Error recording payment: $e');
    }
  }
}
