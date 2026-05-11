import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

<<<<<<< HEAD
  static String dashboard = "$baseUrl/api/branch/dashboard";

  static String salesEntry = "$baseUrl/api/sales/entry";
=======
  static final String dashboard = "$baseUrl/api/branch/dashboard";
  static final String salesEntry = "$baseUrl/api/sales/entry";
  static final String branchExpenses = "$baseUrl/api/branch/expenses";
>>>>>>> ea3e69cdb2c09331bdc464ea5b45b3ec1a494c3e
}
