import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_event.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_state.dart';
import 'package:proteinova_connect/features/branch/sales/data/repository/sales_repository.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _repository = SalesRepository();

  SalesBloc() : super(SalesInitial()) {
    on<FetchSalesDashboard>((event, emit) async {
      emit(SalesLoading());
      try {
        final dashboardData = await _repository.fetchSalesDashboard(
          branchId: event.branchId.toString(),
        );

        // Fetch dispatches and sales orders
        // Note: Repository should have methods for these, if not we'll use dashboardData
        final dispatches = dashboardData['active_dispatches'] ?? [];
        final salesOrders = dashboardData['recent_orders'] ?? [];

        emit(
          SalesDashboardLoaded(
            dashboardData: dashboardData,
            dispatches: dispatches,
            salesOrders: salesOrders,
          ),
        );
      } catch (e) {
        emit(SalesError(e.toString()));
      }
    });

    on<CreateNewSaleEvent>((event, emit) async {
      emit(SalesLoading());
      try {
        final response = await _repository.createSale(event.saleData);
        if (response["error"] == null) {
          emit(SalesSuccess(message: "Sale created successfully"));
        } else {
          emit(SalesError(response["error"]));
        }
      } catch (e) {
        emit(SalesError(e.toString()));
      }
    });
  }
}
