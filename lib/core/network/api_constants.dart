import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";
  static final String dashboard = "$baseUrl/api/branch/dashboard";
  static final String salesEntry = "$baseUrl/api/sales/entry";
}
