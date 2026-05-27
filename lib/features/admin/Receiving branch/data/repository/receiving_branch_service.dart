import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/models/receiving_dashboard_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/models/dispatch_details_model.dart';

class ReceivingBranchService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<List<BranchModel>> fetchBranches() async {
    final response = await http.get(Uri.parse('$baseUrl/api/branches'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((item) => BranchModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load branches');
  }

  static Future<ReceivingDashboardData> fetchDashboard(int branchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/branch/incoming-stock/$branchId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReceivingDashboardData.fromJson(data);
    }
    throw Exception('Failed to load branch incoming stock');
  }

  static Future<void> markArrival(int branchId, int dispatchId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/branch/incoming-stock/$branchId/dispatch/$dispatchId/arrival'),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to mark arrival');
    }
  }

  static Future<DispatchDetails> fetchDispatchDetails(int branchId, int dispatchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/branch/incoming-stock/$branchId/dispatch/$dispatchId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DispatchDetails.fromJson(data);
    }
    throw Exception('Failed to load dispatch details');
  }

  static Future<void> receiveStock({
    required int branchId,
    required int dispatchId,
    required List<Map<String, dynamic>> items,
    required String notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/branch/incoming-stock/$branchId/dispatch/$dispatchId/receive'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'items': items,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to receive stock');
    }
  }
}
