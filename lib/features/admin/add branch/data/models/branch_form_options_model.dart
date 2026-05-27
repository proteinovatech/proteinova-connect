import 'branch_manager_model.dart';

class BranchFormOptionsModel {
  final List<BranchManagerModel> managers;
  final List<String> regions;
  final List<String> statuses;

  BranchFormOptionsModel({
    required this.managers,
    required this.regions,
    required this.statuses,
  });

  factory BranchFormOptionsModel.fromJson(Map<String, dynamic> json) {
    var managersList = json['managers'] as List? ?? [];
    List<BranchManagerModel> managersParsed = managersList
        .map((item) => BranchManagerModel.fromJson(item))
        .toList();

    var regionsList = json['regions'] as List? ?? [];
    List<String> regionsParsed = regionsList.map((item) => item.toString()).toList();

    var statusesList = json['statuses'] as List? ?? [];
    List<String> statusesParsed = statusesList.map((item) => item.toString()).toList();

    return BranchFormOptionsModel(
      managers: managersParsed,
      regions: regionsParsed,
      statuses: statusesParsed.isNotEmpty ? statusesParsed : ['Active', 'Inactive'],
    );
  }
}
