

class ApiConfig {
  static final String baseUrl =
      "https://proteinova-system.onrender.com";

  static const String login = "/login";
  static const String signup = "/signup";
  static const String purchase = "/api/purchase";
  static const String getSupplier = "/api/getSupplier";
   static String arrival(String purchaseId) => "/api/admin/arrival/$purchaseId";
} 
