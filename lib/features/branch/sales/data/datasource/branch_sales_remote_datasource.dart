import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BranchSalesRemoteDatasource {
  static String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? "";

  // ──────────────────────────────────────────────
  // POST /api/branch/sales  →  createSale
  // ──────────────────────────────────────────────
  Future<dynamic> createSale({required Map<String, dynamic> body}) async {
    try {
      print("CREATE SALE BODY =>");
      print(body);

      final response = await http.post(
        Uri.parse("$baseUrl/api/sales"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      print("CREATE SALE RESPONSE => $data");

      if (data["error"] != null) {
        throw Exception(data["error"]);
      }

      return data;
    } catch (e) {
      print("CREATE SALE API ERROR => $e");
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // GET /api/branch/sales
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getSales({
    String? branchId,
    String? date,
  }) async {
    final Uri uri = Uri.parse("$baseUrl/api/branch/sales").replace(
      queryParameters: {
        if (branchId != null && branchId.isNotEmpty && branchId != "all")
          "branch_id": branchId,

        if (date != null && date.isNotEmpty) "date": date,
      },
    );

    print("GET SALES => $uri");

    final response = await http.get(uri);

    print("GET SALES BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load sales : ${response.statusCode}");
    }
  }

  // ──────────────────────────────────────────────
  // GET /api/branch/sales/dashboard
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getSalesDashboard({String? branchId}) async {
    final Uri uri = Uri.parse("$baseUrl/api/sales/").replace(
      queryParameters: {
        if (branchId != null && branchId.isNotEmpty && branchId != "all")
          "branch_id": branchId,
      },
    );

    print("DASHBOARD => $uri");

    final response = await http.get(uri);

    print("DASHBOARD BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load dashboard : ${response.statusCode}");
    }
  }

  // ──────────────────────────────────────────────
  // GET /api/branch/sales/dashboard/full
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getSalesDashboardFull({String? branchId}) async {
    final Uri uri = Uri.parse("$baseUrl/api/branch/sales/dashboard/full")
        .replace(
          queryParameters: {
            if (branchId != null && branchId.isNotEmpty && branchId != "all")
              "branch_id": branchId,
          },
        );

    print("DASHBOARD FULL => $uri");

    final response = await http.get(uri);

    print("DASHBOARD FULL BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load full dashboard : ${response.statusCode}");
    }
  }

  // ──────────────────────────────────────────────
  // GET /api/branch/sales/dashboard/dispatches
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getActiveDispatches({String? branchId}) async {
    final Uri uri = Uri.parse("$baseUrl/api/branch/sales/dashboard/dispatches")
        .replace(
          queryParameters: {
            if (branchId != null && branchId.isNotEmpty && branchId != "all")
              "branch_id": branchId,
          },
        );

    print("DISPATCHES => $uri");

    final response = await http.get(uri);

    print("DISPATCHES BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load dispatches : ${response.statusCode}");
    }
  }

  // ──────────────────────────────────────────────
  // GET CUSTOMER
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getCustomerByNumber(String mobile) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/customers/find?number=$mobile"),
    );

    print("CUSTOMER SEARCH => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {};
    }
  }

  // ──────────────────────────────────────────────
  // POST /api/customers
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> createCustomer({
    required String name,
    required String number,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/customers"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone": number}),
      );

      final data = jsonDecode(response.body);
      print("CREATE CUSTOMER RESPONSE => $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["error"] ?? "Failed to create customer");
      }
    } catch (e) {
      print("CREATE CUSTOMER ERROR => $e");
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // GET SALES ENTRY
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getSalesEntry({
    required int loginUserId,
    String? branchName,
    int? branchId,
  }) async {
    final Uri uri = Uri.parse("$baseUrl/api/sales/entry").replace(
      queryParameters: {
        "login_user_id": loginUserId.toString(),

        if (branchName != null && branchName.isNotEmpty)
          "branch_name": branchName,

        if (branchId != null) "selected_branch_id": branchId.toString(),
      },
    );

    print("ENTRY API => $uri");

    final response = await http.get(uri);

    print("ENTRY STATUS => ${response.statusCode}");
    print("ENTRY BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load sales entry : ${response.statusCode}");
    }
  }

  // ──────────────────────────────────────────────
  // GET SINGLE SALE
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getSingleSale({required String id}) async {
    final Uri uri = Uri.parse("$baseUrl/api/sales/$id");

    print("GET SINGLE SALE => $uri");

    final response = await http.get(uri);

    print("SINGLE SALE BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load sale $id : ${response.statusCode}");
    }
  }

  // ──────────────────────────────────────────────
  // GET BRANCHES
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getBranches() async {
    final response = await http.get(Uri.parse("$baseUrl/api/branches"));

    print("BRANCH STATUS => ${response.statusCode}");
    print("BRANCH BODY => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load branches : ${response.statusCode}");
    }
  }

  // ──────────────────────────────────────────────
  // GET WAREHOUSE LIST
  // ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getWarehouseList() async {
    final response = await http.get(Uri.parse("$baseUrl/api/branch/dashboard"));

    print("WAREHOUSE RESPONSE => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load warehouse list : ${response.statusCode}");
    }
  }

  //offer
  Future<List<dynamic>> getOffers() async {
    final response = await http.get(Uri.parse("$baseUrl/api/offers"));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["data"]["offers_list"] ?? [];
    } else {
      throw Exception("Failed to fetch offers");
    }
  }

  //customer number
  Future<Map<String, dynamic>?> findCustomerByNumber({
    required String number,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/customers/find?number=$number"),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["customer"];
    } else {
      return null;
    }
  }

  //approve
  Future<Map<String, dynamic>> approveSale({required int approvalId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/sales/$approvalId"),
    );

    print("APPROVE RESPONSE => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to approve sale");
    }
  }

  Future<Map<String, dynamic>> rejectSale({required int approvalId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/sales/$approvalId"),
    );

    print("REJECT RESPONSE => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to reject sale");
    }
  }

  //get pending
  Future<List<dynamic>> getPendingSales() async {
    final response = await http.get(Uri.parse("$baseUrl/api/sales"));

    print("PENDING SALES => ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["data"] ?? [];
    } else {
      throw Exception("Failed to load pending sales");
    }
  }
}
