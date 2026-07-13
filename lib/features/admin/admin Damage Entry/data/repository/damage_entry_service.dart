import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_location_model.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_category_model.dart';
import 'package:proteinova_connect/features/admin/admin Damage Entry/data/models/damage_history_model.dart';

class DamageEntryService {
  static final String baseUrl = dotenv.env['VITE_BACKEND_URL'] ?? '';

  static Future<List<DamageLocation>> getLocations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/damage/locations'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List locationsJson = data['locations'] ?? [];
      return locationsJson.map((item) => DamageLocation.fromJson(item)).toList();
    }
    throw Exception('Failed to load target locations');
  }

  static Future<List<DamageCategory>> getCategories({
    required String locationType,
    required String locationName,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/admin/damage/categories?location_type=$locationType&location_name=${Uri.encodeComponent(locationName)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List categoriesJson = data['categories'] ?? [];
      return categoriesJson.map((item) => DamageCategory.fromJson(item)).toList();
    }
    throw Exception('Failed to load available egg categories');
  }

  static Future<List<DamageHistory>> getHistory({
    required String locationType,
    required String locationName,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/admin/damage/history?location_type=$locationType&location_name=${Uri.encodeComponent(locationName)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List historyJson = data['history'] ?? [];
      return historyJson.map((item) => DamageHistory.fromJson(item)).toList();
    }
    throw Exception('Failed to load damage history logs');
  }

  static Future<Map<String, dynamic>> reportDamage({
    required String locationType,
    required String locationName,
    required String category,
    required int damagedEggs,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/damage'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'location_type': locationType,
        'location_name': locationName,
        'category': category,
        'damaged_eggs': damagedEggs,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['error'] ?? data['message'] ?? 'Failed to report damage');
  }
}
