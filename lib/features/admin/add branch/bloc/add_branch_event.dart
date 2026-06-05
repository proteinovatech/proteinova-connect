abstract class AddBranchEvent {}

class LoadFormOptionsEvent extends AddBranchEvent {}

class SaveBranchEvent extends AddBranchEvent {
  final bool isEditing;
  final int? branchId;
  final Map<String, dynamic> payload;

  SaveBranchEvent({
    required this.isEditing,
    this.branchId,
    required this.payload,
  });
}
