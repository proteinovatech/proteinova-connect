// import 'package:dio/dio.dart';
// import 'package:proteinova_connect/core/network/api_constants.dart';
// import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';

// class DashboardRepository {
//   final Dio dio;

//   DashboardRepository(this.dio);

//   Future<DashboardModel> fetchDashboardData() async {
//     try {
      
//       final response = await dio.get(ApiConstants.dashboard);

//       if (response.statusCode == 200) {
//         return DashboardModel.fromJson(response.data);
//       } else {
//         throw Exception("Failed to load dashboard: ${response.statusCode}");
//       }
//     } catch (e) {
//       throw Exception("Connection Error: $e");
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proteinova_connect/core/network/api_constants.dart';
import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';

class DashboardRepository {
  final Dio dio;

  DashboardRepository(this.dio);

  Future<DashboardModel> fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final branchId = prefs.getInt("branch_id");

      final response = await dio.get(
        ApiConstants.dashboard(branchId!),
      );

      if (response.statusCode == 200) {
        return DashboardModel.fromJson(response.data);
      } else {
        throw Exception(
          "Failed to load dashboard: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }
}