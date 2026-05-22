import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/config/api_config.dart';
import 'package:proteinova_connect/features/admin/data/model/dashboard_model.dart';



class DashboardService {
  Future<DashboardModel> fetchDashboard() async {
    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}${ApiConfig.adminDashboard}",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return DashboardModel.fromJson(data);
    } else {
      throw Exception("Failed to load dashboard");
    }
  }
}