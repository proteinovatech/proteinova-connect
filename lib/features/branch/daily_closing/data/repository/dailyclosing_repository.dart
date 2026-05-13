import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/branch/daily_closing/data/model/daily_closing_model.dart';

class DailyClosingRepository {
  Future<DailyClosingModel> fetchDailyClosing(int branchId, String date) async {
    final response = await http.get(
      Uri.parse(ApiConstants.dailyClosingDashboard(branchId, date)),
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

  Future<Map<String, dynamic>> closeDay(int branchId, String date) async {
    final response = await http.post(
      Uri.parse(ApiConstants.dailyClosingSubmit),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "branch_id": branchId,
        "closing_date": date,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to close day: ${response.body}");
    }
  }
}