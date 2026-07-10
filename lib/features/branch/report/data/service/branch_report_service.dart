import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? '';

  Future<Map<String, dynamic>> getBranchSalesReport({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/reports/branch-sales').replace(
      queryParameters: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (branchId != null) 'branchId': branchId,
      },
    );

    debugPrint("API URL: $uri");

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to fetch report (${response.statusCode})');
  }

  Future<List<dynamic>> getBranches() async {
    final uri = Uri.parse('$baseUrl/api/branches');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        return List<dynamic>.from(data["data"] ?? []);
      }
    }

    throw Exception("Failed to fetch branches");
  }

  Future<List<dynamic>> getExpenseReport({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/reports/expense').replace(
      queryParameters: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (branchId != null) 'branchId': branchId,
      },
    );
    print("Base URL: $baseUrl");
    print("Expense API URL: $uri");

    final response = await http.get(uri);
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception("Failed to fetch Expense Report");
  }

  Future<Map<String, dynamic>> getBranchDetailedSales({
    required String branchId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/reports/branch-detailed-sales',
    ).replace(queryParameters: {'branchId': branchId});

    debugPrint("Detailed Sales API: $uri");

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint("Detailed Sales Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to fetch detailed sales (${response.statusCode})');
  }
}
