<<<<<<< HEAD
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import 'package:proteinova_connect/core/network/api_constants.dart';
// // import '../model/dashboard_model.dart';

// // class DashboardRepository {
// //   Future<DashboardModel> fetchDashboardData() async {
// //     final response = await http.get(
// //       Uri.parse(ApiConstants.dashboard),
// //       headers: {
// //         "Accept": "application/json",
// //       },
// //     );

// //     if (response.statusCode == 200) {
// //       final jsonData = jsonDecode(response.body);
// //       return DashboardModel.fromJson(jsonData);
// //     } else {
// //       throw Exception("Failed to load dashboard");
// //     }
// //   }
// // }
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:proteinova_connect/core/network/api_constants.dart';
// import 'package:proteinova_connect/features/branch/branch_dashboard/data/model/dashboard_model.dart';

// class DashboardRepository {
//   final Dio dio;

//   DashboardRepository(this.dio);

//   Future<DashboardModel> fetchDashboardData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       final branchId = prefs.getInt("branch_id");

//       final response = await dio.get(
//         ApiConstants.dashboard(branchId!),
//       );

//       if (response.statusCode == 200) {
//         return DashboardModel.fromJson(response.data);
//       } else {
//         throw Exception(
//           "Failed to load dashboard: ${response.statusCode}",
//         );
//       }
//     } catch (e) {
//       throw Exception("Connection Error: $e");
//     }
//   }
// }
=======
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:proteinova_connect/core/network/api_constants.dart';
// import '../model/dashboard_model.dart';

// class DashboardRepository {
//   Future<DashboardModel> fetchDashboardData() async {
//     final response = await http.get(
//       Uri.parse(ApiConstants.dashboard),
//       headers: {
//         "Accept": "application/json",
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       return DashboardModel.fromJson(jsonData);
//     } else {
//       throw Exception("Failed to load dashboard");
//     }
//   }
// }
>>>>>>> 985535f3db39fce19bb7ce2ac31180ddc2961dc9
