import 'package:flutter_bloc/flutter_bloc.dart';
import 'sales_dashboard_event.dart';
import 'sales_dashboard_state.dart';
import '../data/datasource/sales_remote_datasource.dart';

class SalesDashboardBloc
    extends Bloc<SalesDashboardEvent, SalesDashboardState> {

  final SalesRemoteDatasource datasource;

  SalesDashboardBloc(this.datasource)
      : super(SalesDashboardInitial()) {

    on<FetchSalesDashboard>(_onFetchSalesDashboard);
  }

  Future<void> _onFetchSalesDashboard(
    FetchSalesDashboard event,
    Emitter<SalesDashboardState> emit,
  ) async {

    emit(SalesDashboardLoading());

    try {

      final response = await datasource.getSales();

      final recentOrders =
          response['sales'] ??
          response['recent_orders'] ??
          response['data'] ??
          [];

      emit(
        SalesDashboardLoaded(
          salesData: response,
          recentOrders: recentOrders,
        ),
      );

    } catch (e) {

      emit(
        SalesDashboardError(e.toString()),
      );
    }
  }
}