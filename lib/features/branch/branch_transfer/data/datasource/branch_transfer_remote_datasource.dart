import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BranchTransferRemoteDatasource {
  static String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? "";

  Future<Map<String, dynamic>> getBranches() async {
    final response = await http.get(Uri.parse("$baseUrl/api/branches"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load branches");
    }
  }

  Future<Map<String, dynamic>> getEggCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/api/egg-categories"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load egg categories");
    }
  }

  Future<Map<String, dynamic>> getInventoryStock(int loginUserId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/sales/entry?login_user_id=$loginUserId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load inventory stock");
    }
  }

  Future<Map<String, dynamic>> getTrayInventory() async {
    final response = await http.get(Uri.parse("$baseUrl/api/tray-inventory/get-inventory"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tray inventory");
    }
  }

  Future<Map<String, dynamic>> getTrayReturnData(int branchId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/admin/tray-returns?limit=50&branch_id=$branchId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load tray return data");
    }
  }

  Future<Map<String, dynamic>> getTransferHubData(int branchId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/branch/transfer-dashboard?branchId=$branchId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load transfer hub data");
    }
  }

  Future<dynamic> submitTransfer(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/dispatch"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 202 || response.statusCode == 200) {
      return {"status": response.statusCode, "data": data};
    } else {
      throw Exception(data["error"] ?? "Failed to initiate transfer.");
    }
  }
}
