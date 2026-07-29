import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportService {
  final String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? '';

  Future<Map<String, dynamic>> getBranchSalesReport({
    String? startDate,
    String? endDate,
    String? branchId,
  }) async {
    final query = {
      if (startDate != null) "start_date": startDate,
      if (endDate != null) "end_date": endDate,
      if (branchId != null) "branch_id": branchId,
    };

    final uri = Uri.parse(
      '$baseUrl/api/reports/branch-sales',
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    debugPrint("URL: $uri");
    debugPrint("Status: ${response.statusCode}");
    debugPrint("Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }
}
