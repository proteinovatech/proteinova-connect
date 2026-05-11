import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static final String dashboard = "$baseUrl/api/branch/dashboard";
  static final String salesEntry = "$baseUrl/api/sales/entry";
  static final String branchExpenses = "$baseUrl/api/branch/expenses";
}
