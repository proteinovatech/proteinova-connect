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
