import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/expense_model.dart';

class ExpenseService {

  final String baseUrl =
      dotenv.env['BASE_URL'] ?? "";

  Future<List<ExpenseModel>>
      fetchExpenses(int branchId) async {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/branch/expenses?branch_id=$branchId",
      ),
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      final List list =
          data["recent_expenses"] ?? [];

      return list
          .map(
            (e) =>
                ExpenseModel.fromJson(e),
          )
          .toList();

    } else {

      throw Exception(
        "Failed to fetch expenses",
      );
    }
  }

  Future<String> createExpense(
    Map<String, dynamic> body,
  ) async {

    final response = await http.post(
      Uri.parse(
        "$baseUrl/api/branch/expenses",
      ),

      headers: {
        "Content-Type":
            "application/json",
      },

      body: jsonEncode(body),
    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 201) {

      return data["message"];

    } else {

      throw Exception(
        data["error"] ?? "Failed",
      );
    }
  }
}