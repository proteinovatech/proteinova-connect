import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/features/branch/customer_trays/data/model/customer_tray_model.dart';

class CustomerTrayService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<List<CustomerTray>> getCustomerTrays({
    required int branchId,
    String search = '',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/sales/customer-trays?branch_id=$branchId&search=$search',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List sales = data['sales'] ?? [];

      return sales.map((item) => CustomerTray.fromJson(item)).toList();
    }

    throw Exception('Failed to load customer trays');
  }
}
