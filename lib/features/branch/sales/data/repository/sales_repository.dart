import 'package:proteinova_connect/features/branch/sales/data/model/mobile_inventory_model.dart';

import '../datasource/branch_sales_remote_datasource.dart';
import '../model/sales_entry_model.dart';

class SalesRepository {
  final BranchSalesRemoteDatasource _datasource = BranchSalesRemoteDatasource();

  Future<SalesEntryModel> fetchSalesEntry({
    required int loginUserId,
    int? branchId,
  }) async {
    final data = await _datasource.getSalesEntry(
      loginUserId: loginUserId,
      branchId: branchId,
    );
    return SalesEntryModel.fromJson(data);
  }

  Future<Map<String, dynamic>> fetchSalesDashboard({String? branchId}) async {
    return await _datasource.getSalesDashboard(branchId: branchId);
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> body) async {
    return await _datasource.createSale(body: body);
  }

  Future<Map<String, dynamic>> fetchSingleSale(String id) async {
    return await _datasource.getSingleSale(id: id);
  }

  Future<Map<String, dynamic>> findCustomer(String number) async {
    return await _datasource.getCustomerByNumber(number);
  }

  Future<Map<String, dynamic>> rejectSale({required int approvalId}) async {
    return await _datasource.rejectSale(approvalId: approvalId);
  }

 Future<MobileInventoryModel> getMobileInventory() async {
  return await _datasource.getMobileInventory();
}
}
