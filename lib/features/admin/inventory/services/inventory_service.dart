import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/features/admin/inventory/models/inventory_model.dart';

class InventoryService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<InventoryMetrics?> fetchInventory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/inventory'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return InventoryMetrics.fromJson(
          data['metrics'], // remove if API doesn't have metrics object
        );
      }
    } catch (e) {
      print('Inventory Error: $e');
    }

    return null;
  }
}