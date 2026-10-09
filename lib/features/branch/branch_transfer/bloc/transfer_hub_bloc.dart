import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/datasource/branch_transfer_remote_datasource.dart';
import 'transfer_hub_event.dart';
import 'transfer_hub_state.dart';

class TransferHubBloc extends Bloc<TransferHubEvent, TransferHubState> {
  final BranchTransferRemoteDatasource datasource;

  TransferHubBloc({required this.datasource}) : super(TransferHubInitial()) {
    on<LoadTransferHubEvent>(_onLoadTransferHubEvent);
  }

  Future<void> _onLoadTransferHubEvent(
      LoadTransferHubEvent event, Emitter<TransferHubState> emit) async {
    emit(TransferHubLoading());
    try {
      final data = await datasource.getTransferHubData(event.branchId);
      emit(TransferHubLoaded(data: data));
    } catch (e) {
      emit(TransferHubError(message: e.toString()));
    }
  }
}
