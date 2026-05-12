

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
<<<<<<< HEAD
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";
=======
  static final String baseUrl =
       dotenv.env['BASE_URL'] ?? '';

>>>>>>> 0dace55dca2ba7dfd6f695b5b67bbb20c93ecee5

  static const String login = "/login";
  static const String signup = "/signup";
  static const String purchase = "/api/purchase";
  static const String getSupplier = "/api/getSupplier";
  static String arrival(String purchaseId) => "/api/admin/arrival/$purchaseId";
  static const String adminDashboard = "/api/admin/dashboard";
} 
