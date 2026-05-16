import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/branch/daily_closing/data/model/daily_closing_model.dart';

class DailyClosingRepository {
  Future<DailyClosingModel> fetchDailyClosing(int branchId, String date) async {
    // React calls: /api/branch/daily-closing/dashboard/${branchId}
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/branch/daily-closing/dashboard/$branchId"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DailyClosingModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch daily closing data: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> closeDay(int branchId, Map<String, dynamic> payload) async {
    // React calls: POST /api/branch/daily-closing/${branch_id}
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/branch/daily-closing/$branchId"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to close day: ${response.body}");
    }
  }
}