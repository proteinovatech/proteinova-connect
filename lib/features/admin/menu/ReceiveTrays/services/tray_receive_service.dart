import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/core/config/api_config.dart';

class TrayReceiveService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<dynamic>> getTrayReceiveNotes({int? trayReturnId}) async {
    try {
      String url = '$baseUrl/api/admin/tray-receive';
      if (trayReturnId != null) {
        url += '?tray_return_id=$trayReturnId';
      }
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['data'] ?? [];
      } else {
        throw Exception('Failed to load tray receive notes');
      }
    } catch (e) {
      throw Exception('Error fetching tray receive notes: $e');
    }
  }

  Future<bool> createTrayReceive({
    required int trayReturnId,
    required int receivedQty,
    required String receivedCondition,
    String? notes,
    int? receivedBy,
    int? warehouseId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/tray-receive'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "tray_return_id": trayReturnId,
          "received_qty": receivedQty,
          "received_condition": receivedCondition,
          "notes": notes,
          "received_by": receivedBy,
          "warehouse_id": warehouseId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create tray receive');
      }
    } catch (e) {
      throw Exception('Error creating tray receive: $e');
    }
  }
}
