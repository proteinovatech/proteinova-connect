import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final raw = dotenv.env['VITE_BACKEND_URL'] ?? dotenv.env['BASE_URL'] ?? '';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }


  // static final String baseUrl = dotenv.env['VITE_BACKEND_URL']!;
  // static final String baseUrl = dotenv.env['BASE_URL']!;

  static const String login = "/login";
  static const String signup = "/signup";
  static const String purchase = "/api/purchase";
  static const String getSupplier = "/api/getSupplier";
  static String arrival(String purchaseId) => "/api/admin/arrival/$purchaseId";
  static const String adminDashboard = "/api/admin/dashboard";
  static String damageCategories(int branchId) =>
      "/api/branch/damage/categories?branch_id=$branchId";
  static const String branches = "/api/branches";
  static const String mobileInventory = "/api/admin/mobile-inventory";
}