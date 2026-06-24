import 'dart:convert';
import 'package:http/http.dart' as http;

class CreditLedgerService {
  static const String baseUrl = 'https://proteinova-system-4z2a.onrender.com';

  Future<Map<String, dynamic>> getCreditLedger() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ledgers/admin/credit'),
      headers: {'Content-Type': 'application/json'},
    );

    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load credit ledger: ${response.statusCode}');
    }
  }
}
