import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/warehouse/daily%20closing/model/branchselector_model.dart';
import 'package:proteinova_connect/features/warehouse/daily%20closing/model/dailyclosing_adminmodel.dart';


class DailyClosingAdminService {
  Future<List<BranchSelectorModel>> fetchBranches() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.branches),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((e) => BranchSelectorModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch branches. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching branches: $e");
    }
  }

  Future<DailyClosingAdminModel> fetchDashboardData(int branchId) async {
    try {
      // Endpoint: /api/branch/daily-closing/dashboard/:branchId
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/branch/daily-closing/dashboard/$branchId"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return DailyClosingAdminModel.fromJson(jsonResponse);
      } else {
        throw Exception("Failed to fetch dashboard data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching daily closing: $e");
    }
  }

  Future<void> submitDailyClosing({
    required int branchId,
    required String status,
    required String notes,
    required double countedCash,
  }) async {
    try {
      // Endpoint: POST /api/branch/daily-closing/:branchId
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/branch/daily-closing/$branchId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "status": status,
          "notes": notes,
          "counted_cash": countedCash,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? "Failed to submit daily closing");
      }
    } catch (e) {
      throw Exception("Error submitting daily closing: $e");
    }
  }
}
