import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['VITE_BACKEND_URL']!;


  static const String login = "/login";
  static const String signup = "/signup";
  static const String purchase = "/api/purchase";
  static const String getSupplier = "/api/getSupplier";
  static String arrival(String purchaseId) => "/api/admin/arrival/$purchaseId";
  static const String adminDashboard = "/api/admin/dashboard";
   static String damageCategories(int branchId) =>
      "/api/branch/damage/categories?branch_id=$branchId";
  static const String branches="/api/branches";
  static const String mobileInventory = "/api/admin/mobile-inventory";

}