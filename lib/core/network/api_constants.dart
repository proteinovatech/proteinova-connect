import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static final String dashboard = "$baseUrl/api/branch/dashboard";
  static final String salesEntry = "$baseUrl/api/sales/entry";
  static final String branchExpenses = "$baseUrl/api/branch/expenses";
  static final String branches = "$baseUrl/api/branches";
  static final String adminInventory = "$baseUrl/api/admin/inventory";
  static final String receiveStock = "$baseUrl/api/admin/receive"; // Requires /:purchaseId
  static final String markArrival = "$baseUrl/api/admin/arrival"; // Requires /:purchaseId
  static final String purchaseList = "$baseUrl/api/purchase";
  static final String branchIncomingStock = "$baseUrl/api/branch/incoming-stock";
  static final String assets = "$baseUrl/api/assets";
}
