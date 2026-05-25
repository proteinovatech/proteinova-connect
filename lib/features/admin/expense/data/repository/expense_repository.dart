import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/branch_expense_dashboard_model.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/expense_model.dart';
import 'package:proteinova_connect/features/admin/expense/data/models/location_model.dart';

class ExpenseRepository {
  Future<BranchExpenseDashboardModel> fetchExpenses({
    int? branchId,
    int? warehouseId,
    String? month,
    int limit = 20,
  }) async {
    try {
      final queryParameters = {
        if (branchId != null) 'branch_id': branchId.toString(),
        if (warehouseId != null) 'warehouse_id': warehouseId.toString(),
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
        throw Exception(errorData['error'] ?? "Failed to load expenses");
      }
    } catch (e) {
      throw Exception("Error fetching expenses: $e");
    }
  }

  Future<ExpenseModel> createExpense({
    int? branchId,
    int? warehouseId,
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
        if (branchId != null) "branch_id": branchId,
        if (warehouseId != null) "warehouse_id": warehouseId,
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
          errorData['error'] ?? "Failed to create expense",
        );
      }
    } catch (e) {
      throw Exception("Error creating expense: $e");
    }
  }

  Future<List<Location>> fetchLocations() async {
    try {
      final List<Location> locations = [];

      // Concurrently fetch branches and warehouses
      final branchFuture = http.get(
        Uri.parse(ApiConstants.branches),
        headers: {"Accept": "application/json"},
      );

      final warehouseFuture = http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/warehouses"),
        headers: {"Accept": "application/json"},
      );

      final results = await Future.wait([branchFuture, warehouseFuture]);
      final branchResponse = results[0];
      final warehouseResponse = results[1];

      if (branchResponse.statusCode == 200) {
        final data = jsonDecode(branchResponse.body);
        final List<dynamic> branchesList = data['data'] ?? [];
        for (var branch in branchesList) {
          locations.add(Location.fromJson(branch, 'branch'));
        }
      } else {
        throw Exception("Failed to load branches");
      }

      if (warehouseResponse.statusCode == 200) {
        final data = jsonDecode(warehouseResponse.body);
        final List<dynamic> warehousesList = data['data'] ?? [];
        for (var warehouse in warehousesList) {
          locations.add(Location.fromJson(warehouse, 'warehouse'));
        }
      } else {
        throw Exception("Failed to load warehouses");
      }

      return locations;
    } catch (e) {
      throw Exception("Error fetching locations: $e");
    }
  }
}
