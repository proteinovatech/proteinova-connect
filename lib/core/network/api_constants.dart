import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
   static String get baseUrl =>
      dotenv.env['BASE_URL']?.trim() ?? '';
   //() {
  //   final url = dotenv.env['BASE_URL'] ?? "";
  //   return url.trim().isEmpty ? "https://proteinova-system-q3ob.onrender.com" : url.trim();
  // }();

  static String dashboard(int branchId) => "$baseUrl/api/branch/dashboard/$branchId";
  static final String salesEntry = "$baseUrl/api/sales/entry";
  static final String branchExpenses = "$baseUrl/api/branch/expenses";
  static final String branches = "$baseUrl/api/branches";
  static final String adminInventory = "$baseUrl/api/admin/inventory";
  static final String receiveStock = "$baseUrl/api/admin/receive"; // Requires /:purchaseId
  static final String markArrival = "$baseUrl/api/admin/arrival"; // Requires /:purchaseId
  static final String purchaseList = "$baseUrl/api/purchase";
  static final String branchIncomingStock = "$baseUrl/api/branch/incoming-stock";
  static final String assets = "$baseUrl/api/assets";
  static String dailyClosingDashboard(int branchId, String date) => "$baseUrl/api/branch/daily-closing/dashboard/$branchId?date=$date";
  static final String dailyClosingSubmit = "$baseUrl/api/branch/daily-closing";
  static String trayReturnDashboard(int branchId, String date) => "$baseUrl/api/admin/tray-returns?branch_id=$branchId&date=$date";
  static final String trayReturnSubmit = "$baseUrl/api/admin/tray-returns";
  // static String expenseList(int branchId) => "$baseUrl/api/branch/expenses/$branchId";
  static String expenseList(
  int branchId,
) =>
    "$baseUrl/api/branch/expenses?branch_id=$branchId";
  static final String expenseSubmit = "$baseUrl/api/branch/expenses";
  // Ledger (placeholder — backend team must implement)
  static String ledger(int branchId) => "$baseUrl/api/branch/ledger?branch_id=$branchId";
  static final String ledgerPayment = "$baseUrl/api/branch/ledger/payment";
  
  // Report (placeholder — backend team must implement)
  static String branchReport(int branchId) => "$baseUrl/api/branch/report?branch_id=$branchId";
}
