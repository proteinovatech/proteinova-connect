import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/config/api_config.dart';
import '../models/tray_inventory_model.dart';

class TrayManagementService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<TrayInventoryModel>> getInventory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tray-inventory/get-inventory'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          List data = jsonResponse['data'] ?? [];
          return data.map((e) => TrayInventoryModel.fromJson(e)).toList();
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'Failed to fetch inventory',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch inventory. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching inventory: $e');
    }
  }

  Future<void> addTraysToNamakkal(int plasticTrays, int paperTrays) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tray-inventory/add-to-namakkal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'plastic_tray_count': plasticTrays,
          'paper_tray_count': paperTrays,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] != true) {
          throw Exception(jsonResponse['message'] ?? 'Failed to add trays');
        }
      } else {
        throw Exception(
          'Failed to add trays. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error adding trays: $e');
    }
  }
}
