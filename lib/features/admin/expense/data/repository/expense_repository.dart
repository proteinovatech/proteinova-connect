import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/branch_expense_dashboard_model.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/expense_model.dart';


class ExpenseRepository {
  Future<BranchExpenseDashboardModel> fetchBranchExpenses({
    required int branchId,
    String? month,
    int limit = 10,
  }) async {
    try {
      final queryParameters = {
        'branch_id': branchId.toString(),
        if (month != null) 'month': month,
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        ApiConstants.branchExpenses,
      ).replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BranchExpenseDashboardModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to load branch expenses");
      }
    } catch (e) {
      throw Exception("Error fetching branch expenses: $e");
    }
  }

  Future<ExpenseModel> createBranchExpense({
    required int branchId,
    required String expenseDate,
    required String category,
    required double amount,
    required String paymentMethod,
    String? description,
    String status = "PAID",
    String? attachmentUrl,
    int? loginUserId,
  }) async {
    try {
      final body = {
        "branch_id": branchId,
        "expense_date": expenseDate,
        "category": category,
        "amount": amount,
        "payment_method": paymentMethod,
        "description": description,
        "status": status,
        "attachment_url": attachmentUrl,
        "login_user_id": loginUserId,
      };

      final response = await http.post(
        Uri.parse(ApiConstants.branchExpenses),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ExpenseModel.fromJson(data['expense']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? "Failed to create branch expense",
        );
      }
    } catch (e) {
      throw Exception("Error creating branch expense: $e");
    }
  }

  Future<Map<int, String>> fetchBranches() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.branches),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> branchesList = data['data'];
        final Map<int, String> branchesMap = {};
        for (var branch in branchesList) {
          branchesMap[branch['id']] = branch['branch_name'] ?? branch['id'].toString();
        }
        return branchesMap;
      } else {
        throw Exception("Failed to load branches");
      }
    } catch (e) {
      throw Exception("Error fetching branches: $e");
    }
  }
}
