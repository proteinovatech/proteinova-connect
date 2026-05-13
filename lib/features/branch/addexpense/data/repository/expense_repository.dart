import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import '../model/expense_model.dart';

class ExpenseRepository {
  Future<List<ExpenseModel>> fetchExpenses(int branchId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.expenseList(branchId)),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final List list = data["expenses"] ?? data["data"] ?? [];
        return list.map((e) => ExpenseModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load expenses: ${response.body}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> submitExpense(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.expenseSubmit),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to save expense: ${response.body}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}