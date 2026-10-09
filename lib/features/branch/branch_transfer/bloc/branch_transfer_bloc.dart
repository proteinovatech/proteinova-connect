import 'package:flutter_bloc/flutter_bloc.dart';
import 'branch_transfer_event.dart';
import 'branch_transfer_state.dart';
import '../data/datasource/branch_transfer_remote_datasource.dart';

class BranchTransferBloc extends Bloc<BranchTransferEvent, BranchTransferState> {
  final BranchTransferRemoteDatasource datasource;

  BranchTransferBloc(this.datasource) : super(BranchTransferInitial()) {
    on<LoadInitialDataEvent>(_onLoadInitialData);
    on<SubmitTransferEvent>(_onSubmitTransfer);
  }

  Future<void> _onLoadInitialData(
    LoadInitialDataEvent event,
    Emitter<BranchTransferState> emit,
  ) async {
    emit(BranchTransferLoading());
    try {
      final results = await Future.wait([
        datasource.getBranches(),
        datasource.getEggCategories(),
        datasource.getInventoryStock(event.loginUserId),
        datasource.getTrayReturnData(event.branchId),
      ]);

      final branchesRes = results[0] as Map<String, dynamic>;
      final categoriesRes = results[1] as Map<String, dynamic>;
      final stockRes = results[2] as Map<String, dynamic>;
      final trayRes = results[3] as Map<String, dynamic>;

      List<dynamic> branches = branchesRes['data'] ?? [];
      List<dynamic> eggCategories = categoriesRes['data'] ?? [];
      
      List<dynamic> inventoryProducts = stockRes['product_details'] ?? [];
      List<dynamic> inventoryStock = inventoryProducts.map((p) => {
        "egg_category_grade": p['product_name'],
        "total_eggs": p['stock_eggs'],
        "total_trays": (p['stock_eggs'] / 30).floor(),
      }).toList();

      int plasticCount = 0;
      int paperCount = 0;
      
      final cardsData = trayRes['cards'] ?? {};
      plasticCount = cardsData['closing_empty_plastic'] ?? cardsData['empty_plastic'] ?? 0;
      paperCount = cardsData['closing_empty_paper'] ?? cardsData['empty_paper'] ?? 0;

      emit(BranchTransferDataLoaded(
        branches: branches,
        eggCategories: eggCategories,
        inventoryStock: inventoryStock,
        emptyPlasticTrays: plasticCount,
        emptyPaperTrays: paperCount,
      ));
    } catch (e) {
      emit(BranchTransferError(e.toString()));
    }
  }

  Future<void> _onSubmitTransfer(
    SubmitTransferEvent event,
    Emitter<BranchTransferState> emit,
  ) async {
    if (state is BranchTransferDataLoaded) {
      final currentState = state as BranchTransferDataLoaded;
      emit(BranchTransferSubmitting(currentState));
      try {
        final res = await datasource.submitTransfer(event.payload);
        emit(BranchTransferSubmitSuccess(res));
      } catch (e) {
        emit(BranchTransferSubmitError(
          message: e.toString(),
          previousData: currentState,
        ));
      }
    }
  }
}
