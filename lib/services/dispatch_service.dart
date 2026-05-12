import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DispatchService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:5000';

  static Future<Map<String, dynamic>?> fetchDispatchDashboard({int page = 1, int limit = 10, String search = '', String status = ''}) async {
    try {
      final url = Uri.parse('$baseUrl/api/dispatch/dashboard?page=$page&limit=$limit&search=$search&status=$status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching dispatch dashboard: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchSingleDispatch(String id) async {
    try {
      final url = Uri.parse('$baseUrl/api/dispatch/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching single dispatch: $e");
      return null;
    }
  }

  static Future<bool> createDispatch(Map<String, dynamic> dispatchData) async {
    try {
      final url = Uri.parse('$baseUrl/api/dispatch');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dispatchData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error creating dispatch: $e");
      return false;
    }
  }
}
