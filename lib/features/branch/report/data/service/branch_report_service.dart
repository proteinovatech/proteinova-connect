import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

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
}
