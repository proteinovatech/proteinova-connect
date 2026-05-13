import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_event.dart';
import 'package:proteinova_connect/features/branch/sales/bloc/sales_state.dart';
import 'package:proteinova_connect/services/branch_sales_service.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {
    on<FetchSalesDashboard>((event, emit) async {
      emit(SalesLoading());
      try {
        final dashboardData = await BranchSalesService.fetchDashboard(
          branchId: event.branchId,
        );
        final dispatches = await BranchSalesService.fetchDispatches();
        final salesOrders = await BranchSalesService.fetchSalesOrders();

        emit(
          SalesDashboardLoaded(
            dashboardData: dashboardData ?? {},
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
        final success = await BranchSalesService.createSale(event.saleData);
        if (success) {
          emit(SalesSuccess(message: "Sale created successfully"));
        } else {
          emit(SalesError("Failed to create sale"));
        }
      } catch (e) {
        emit(SalesError(e.toString()));
      }
    });
  }
}
