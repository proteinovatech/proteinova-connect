import 'package:proteinova_connect/features/branch/sales/data/model/branch_inventory_model.dart';



class MobileInventoryModel {
  final List<BranchInventory> inventoryByBranch;

  MobileInventoryModel({
    required this.inventoryByBranch,
  });

  factory MobileInventoryModel.fromJson(Map<String, dynamic> json) {
    return MobileInventoryModel(
      inventoryByBranch:
          (json["inventory_by_branch"] as List? ?? [])
              .map((e) => BranchInventory.fromJson(e))
              .toList(),
    );
  }
}