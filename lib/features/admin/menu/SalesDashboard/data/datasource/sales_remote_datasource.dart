import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SalesRemoteDatasource {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// GET SALES
  Future<Map<String, dynamic>> getSales() async {
    final response = await http.get(Uri.parse("$baseUrl/api/sales"));

    print("GET SALES => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load sales : ${response.statusCode}");
    }
  }

  /// CREATE SALE
  Future<Map<String, dynamic>> createSale({
    required Map<String, dynamic> body,
  }) async {
    print("CREATE SALE BODY =>");
    print(body);

    final response = await http.post(
      Uri.parse("$baseUrl/api/sales"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode(body),
    );

    print("CREATE SALE RESPONSE => ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create sale : ${response.statusCode}");
    }
  }

  /// DASHBOARD
  Future<Map<String, dynamic>> getSalesDashboard() async {
    final response = await http.get(Uri.parse("$baseUrl/api/sales/dashboard"));

    print("DASHBOARD RESPONSE => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load dashboard : ${response.statusCode}");
    }
  }

  /// SALES ENTRY
  // Future<Map<String, dynamic>> getSalesEntry({
  //   required int loginUserId,
  //   String? branchName,
  // }) async {
  //   final Uri uri = Uri.parse(
  //     "$baseUrl/api/sales/entry",
  //   ).replace(
  //     queryParameters: {
  //       "login_user_id": loginUserId.toString(),

  //       if (branchName != null &&
  //           branchName.isNotEmpty)
  //         "branch_name": branchName,
  //     },
  //   );

  //   print("ENTRY API => $uri");

  //   final response = await http.get(uri);

  //   print("ENTRY STATUS => ${response.statusCode}");
  //   print("ENTRY BODY => ${response.body}");

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception(
  //       "Failed to load sales entry : ${response.statusCode}",
  //     );
  //   }
  // }

  /// SALES ENTRY
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

        if (branchId != null) "branch_id": branchId.toString(),
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

  /// SINGLE SALE
  Future<Map<String, dynamic>> getSingleSale(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/api/sales/$id"));

    print("SINGLE SALE => ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load single sale : ${response.statusCode}");
    }
  }
}
