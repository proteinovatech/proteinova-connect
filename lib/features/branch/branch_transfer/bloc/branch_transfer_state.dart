abstract class BranchTransferState {}

class BranchTransferInitial extends BranchTransferState {}

class BranchTransferLoading extends BranchTransferState {}

class BranchTransferDataLoaded extends BranchTransferState {
  final List<dynamic> branches;
  final List<dynamic> eggCategories;
  final List<dynamic> inventoryStock;
  final int emptyPlasticTrays;
  final int emptyPaperTrays;

  BranchTransferDataLoaded({
    required this.branches,
    required this.eggCategories,
    required this.inventoryStock,
    required this.emptyPlasticTrays,
    required this.emptyPaperTrays,
  });
}

class BranchTransferError extends BranchTransferState {
  final String message;
  BranchTransferError(this.message);
}

class BranchTransferSubmitting extends BranchTransferState {
  final BranchTransferDataLoaded previousData;
  BranchTransferSubmitting(this.previousData);
}

class BranchTransferSubmitSuccess extends BranchTransferState {
  final Map<String, dynamic> dispatchResponse;
  BranchTransferSubmitSuccess(this.dispatchResponse);
}

class BranchTransferSubmitError extends BranchTransferState {
  final String message;
  final BranchTransferDataLoaded previousData;
  BranchTransferSubmitError({required this.message, required this.previousData});
}
