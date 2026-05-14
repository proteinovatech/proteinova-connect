import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';

import '../model/expense_model.dart';

class ExpenseRepository {
  

  Future<List<ExpenseModel>> fetchExpenses() async {
    try {
       final response = await http.get(
      Uri.parse(ApiConstants.dashboard as String),
      headers: {
        "Accept": "application/json",
      },
    );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // SINGLE OBJECT RESPONSE
        final expense = ExpenseModel.fromJson(
          data["expense"],
        );

        return [expense];

        /*
        List expenses = data["expenses"];

        return expenses
            .map(
              (e) => ExpenseModel.fromJson(e),
            )
            .toList();
        */
      } else {
        throw Exception(
          "Failed to load expenses",
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}