import 'package:dio/dio.dart';
import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/admin%20branch/data/models/admin_branch_dashboard_model.dart';

class AdminBranchRepository {
  final Dio dio;

  AdminBranchRepository(this.dio);

  /// Fetch all branches for the admin selector dropdown.
  Future<List<BranchModel>> fetchBranches() async {
    try {
      final response = await dio.get(ApiConstants.branches);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List<dynamic> list = [];
        if (responseData is Map<String, dynamic>) {
          list = responseData['data'] ?? responseData['branches'] ?? [];
        } else if (responseData is List) {
          list = responseData;
        }
        return list.map((e) => BranchModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch branches: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching branches: $e");
    }
  }

  /// Fetch dashboard data for a specific branch.
  /// If [branchId] is null, fetch default branch dashboard.
  Future<AdminBranchDashboardModel> fetchDashboardData(int? branchId) async {
    try {
      final String url = branchId != null
          ? ApiConstants.dashboard(branchId)
          : "${ApiConstants.baseUrl}/api/branch/dashboard";

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return AdminBranchDashboardModel.fromJson(response.data);
      } else {
        throw Exception("Failed to load dashboard: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }
}
