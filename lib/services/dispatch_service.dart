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

  static Future<List<Map<String, dynamic>>> fetchBranches() async {
    try {
      final url = Uri.parse('$baseUrl/api/branches');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print("Error fetching branches: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchWarehouseStock() async {
    try {
      final url = Uri.parse('$baseUrl/api/admin/inventory');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Map category_stock to a cleaner list for the dropdown
        final List<dynamic> stocks = data['category_stock'] ?? [];
        return stocks.map((e) => {
          'category': e['category'],
          'total_eggs': int.tryParse(e['total_eggs'].toString()) ?? 0,
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching warehouse stock: $e");
      return [];
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
      
      if (response.statusCode == 201) {
        return true;
      } else {
        print("Create dispatch failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error creating dispatch: $e");
      return false;
    }
  }
}
