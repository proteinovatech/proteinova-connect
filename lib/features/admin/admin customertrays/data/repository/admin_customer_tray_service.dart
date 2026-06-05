import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:proteinova_connect/features/admin/admin customertrays/data/models/admin_customer_tray_model.dart';

class AdminCustomerTrayService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<List<AdminCustomerTray>> getCustomerTrays({
    String search = '',
    bool isBranch = false,
    String branchName = '',
  }) async {
    String url = '$baseUrl/api/sales/customer-trays?search=${Uri.encodeComponent(search)}';
    if (isBranch && branchName.isNotEmpty) {
      url += '&branch_name=${Uri.encodeComponent(branchName)}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List sales = data['sales'] ?? [];
      return sales.map((item) => AdminCustomerTray.fromJson(item)).toList();
    }

    throw Exception('Failed to load customer trays');
  }
}
