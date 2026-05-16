import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/network/api_constants.dart';
import '../model/tray_return_model.dart';

class TrayReturnRepository {
  Future<TrayReturnModel> fetchTrayReturnData(int branchId, String? date) async {
    final queryParams = {
      "branch_id": branchId.toString(),
      "limit": "50",
      if (date != null && date.isNotEmpty) "date": date,
    };
    
    final uri = Uri.parse("${ApiConstants.baseUrl}/api/admin/tray-returns").replace(queryParameters: queryParams);
    print("TrayReturn API Request: $uri");
    
    final response = await http.get(
      uri,
      headers: {
        "Accept": "application/json",
      },
    );

    print("TrayReturn API Response: ${response.body}");

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      return TrayReturnModel.fromJson(decodedData);
    } else {
      throw Exception("Failed to load tray return data: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchWarehouses() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/api/warehouses"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      return decodedData["data"] ?? [];
    } else {
      throw Exception("Failed to load warehouses: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> submitTrayReturn(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiConstants.trayReturnSubmit),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to submit tray return: ${response.body}");
    }
  }
}