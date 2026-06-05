import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = () {
    final url = dotenv.env['BASE_URL'] ?? '';
    return url.trim().isEmpty ? 'https://proteinova-system-q3ob.onrender.com' : url.trim();
  }();


  static const String login = "/login";
  static const String signup = "/signup";
  static const String purchase = "/api/purchase";
  static const String getSupplier = "/api/getSupplier";
  static String arrival(String purchaseId) => "/api/admin/arrival/$purchaseId";
  static const String adminDashboard = "/api/admin/dashboard";
   static String damageCategories(int branchId) =>
      "/api/branch/damage/categories?branch_id=$branchId";
  static const String branches="/api/branches";

}