import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static String dashboard = "$baseUrl/api/branch/dashboard";

  static String salesEntry = "$baseUrl/api/sales/entry";
}
