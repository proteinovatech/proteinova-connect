import 'dart:convert';

import 'package:proteinova_connect/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalesService {
  static Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final branchId = prefs.getInt("branch_id");

      final baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse("$baseUrl/api/sales/dashboard?branch_id=$branchId"),

        headers: {"Accept": "application/json"},
      );

      print(response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print(e);

      return null;
    }
  }

  static Future<List<dynamic>> fetchDispatches() async {
    try {
      final baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse("$baseUrl/api/dispatch"),

        headers: {"Accept": "application/json"},
      );

      print("DISPATCH => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["active_dispatches"] ?? [];
      }

      return [];
    } catch (e) {
      print(e);

      return [];
    }
  }

  static Future<List<dynamic>> fetchSalesOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final branchId = prefs.getInt("branch_id");

      final baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse("$baseUrl/api/sales?branch_id=$branchId"),

        headers: {"Accept": "application/json"},
      );

      print("SALES ORDERS => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["orders"] ?? [];
      }

      return [];
    } catch (e) {
      print(e);

      return [];
    }
  }
}
