import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreditLedgerService {
  final String baseUrl = dotenv.env['VITE_BACKEND_URL']!;

  Future<Map<String, dynamic>> getCreditLedger() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ledgers/admin/credit'),
      headers: {'Content-Type': 'application/json'},
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch data: ${response.statusCode}");
    }
  }
}
