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

      print("DEBUG: Fetching Dashboard for Branch ID: $branchId");

      final response = await http.get(
        Uri.parse("$baseUrl/api/sales/dashboard?branch_id=${branchId ?? 1}"),
        headers: {"Accept": "application/json"},
      );

      print("SALES DASHBOARD RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("SALES DASHBOARD ERROR => $e");
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

      print("DISPATCH RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        return data["active_dispatches"] ?? data["data"] ?? [];
      }
      return [];
    } catch (e) {
      print("DISPATCH ERROR => $e");
      return [];
    }
  }

  static Future<List<dynamic>> fetchSalesOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final branchId = prefs.getInt("branch_id");
      final baseUrl = ApiConfig.baseUrl;

      // Try with branch_id first, then without if empty
      String url = "$baseUrl/api/sales";
      if (branchId != null) {
        url += "?branch_id=$branchId";
      }

      print("DEBUG: Fetching Sales Orders from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );

      print("SALES ORDERS RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // If response is a List directly
        if (data is List) return data;
        
        // If response is a Map, check common keys
        if (data is Map) {
          return data["recent_orders"] ?? data["orders"] ?? data["sales"] ?? data["data"] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("SALES ORDERS ERROR => $e");
      return [];
    }
  }

  static Future<bool> createSale(Map<String, dynamic> body) async {
    try {
      final baseUrl = ApiConfig.baseUrl;
      final response = await http.post(
        Uri.parse("$baseUrl/api/sales"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print("CREATE SALE RESPONSE => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("CREATE SALE ERROR => $e");
      return false;
    }
  }
}
