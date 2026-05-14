import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';

class BranchSalesService {
  /// SALES DASHBOARD
  static Future<Map<String, dynamic>?> fetchDashboard({
    required int branchId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/sales?branch_id=$branchId"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// SALES ENTRY DATA
  static Future<Map<String, dynamic>?> fetchSalesEntry({
    required int loginUserId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/sales/entry?login_user_id=$loginUserId",
        ),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// CREATE SALE
  static Future<bool> createSale(Map<String, dynamic> saleData) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/sales"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(saleData),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// SINGLE SALE RECEIPT
  static Future<Map<String, dynamic>?> fetchSaleReceipt(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/sales/$id"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// FETCH DISPATCHES
  static Future<List<dynamic>> fetchDispatches() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/sales"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['recent_orders'] ?? [];
      }

      return [];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// FETCH SALES ORDERS
  static Future<List<dynamic>> fetchSalesOrders() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/sales"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['recent_orders'] ?? [];
      }

      return [];
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
