import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/data/model/branch_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/models/receiving_dashboard_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/models/dispatch_details_model.dart';
import 'package:proteinova_connect/features/admin/Receiving branch/data/repository/receiving_branch_service.dart';

part 'receiving_branch_event.dart';
part 'receiving_branch_state.dart';

class ReceivingBranchBloc
    extends Bloc<ReceivingBranchEvent, ReceivingBranchState> {
  ReceivingBranchBloc() : super(ReceivingBranchInitial()) {
    on<FetchBranchesListEvent>((event, emit) async {
      emit(ReceivingBranchLoading());
      try {
        final branches = await ReceivingBranchService.fetchBranches();
        if (branches.isEmpty) {
          emit(ReceivingBranchError(message: 'No branches found'));
          return;
        }

        final defaultBranchId = branches[0].id;
        final dashboardData = await ReceivingBranchService.fetchDashboard(
          defaultBranchId,
        );

        emit(
          ReceivingBranchDashboardLoaded(
            branches: branches,
            selectedBranchId: defaultBranchId,
            dashboardData: dashboardData,
          ),
        );
      } catch (e) {
        emit(ReceivingBranchError(message: 'Failed to fetch dashboard: $e'));
      }
    });

    on<SelectBranchEvent>((event, emit) async {
      List<BranchModel> currentBranches = [];
      if (state is ReceivingBranchDashboardLoaded) {
        currentBranches = (state as ReceivingBranchDashboardLoaded).branches;
      }

      emit(ReceivingBranchLoading());
      try {
        final dashboardData = await ReceivingBranchService.fetchDashboard(
          event.branchId,
        );

        emit(
          ReceivingBranchDashboardLoaded(
            branches: currentBranches.isNotEmpty
                ? currentBranches
                : await ReceivingBranchService.fetchBranches(),
            selectedBranchId: event.branchId,
            dashboardData: dashboardData,
          ),
        );
      } catch (e) {
        emit(
          ReceivingBranchError(
            message: 'Failed to load branch data: $e',
            branches: currentBranches,
            selectedBranchId: event.branchId,
          ),
        );
      }
    });

    on<TriggerMarkArrivalEvent>((event, emit) async {
      if (state is ReceivingBranchDashboardLoaded) {
        final curr = state as ReceivingBranchDashboardLoaded;
        emit(
          MarkArrivalInProgress(
            branches: curr.branches,
            selectedBranchId: curr.selectedBranchId,
            dashboardData: curr.dashboardData,
            actionDispatchId: event.dispatchId,
          ),
        );

        try {
          await ReceivingBranchService.markArrival(
            event.branchId,
            event.dispatchId,
          );
          final updatedDashboard = await ReceivingBranchService.fetchDashboard(
            event.branchId,
          );

          emit(
            ReceivingBranchDashboardLoaded(
              branches: curr.branches,
              selectedBranchId: curr.selectedBranchId,
              dashboardData: updatedDashboard,
            ),
          );
        } catch (e) {
          emit(
            ReceivingBranchError(
              message: 'Failed to mark arrival: $e',
              branches: curr.branches,
              selectedBranchId: curr.selectedBranchId,
              dashboardData: curr.dashboardData,
            ),
          );
        }
      }
    });

    on<LoadDispatchDetailsEvent>((event, emit) async {
      List<BranchModel> branches = [];
      int selectedBranchId = event.branchId;
      ReceivingDashboardData? dashboardData;

      if (state is ReceivingBranchDashboardLoaded) {
        final curr = state as ReceivingBranchDashboardLoaded;
        branches = curr.branches;
        selectedBranchId = curr.selectedBranchId;
        dashboardData = curr.dashboardData;
      }

      emit(
        DispatchDetailsLoading(
          branches: branches,
          selectedBranchId: selectedBranchId,
          dashboardData:
              dashboardData ??
              ReceivingDashboardData(
                expectedToday: 0,
                readyForUnloading: 0,
                delayedInTransit: 0,
                totalShipments: 0,
                shipments: [],
              ),
        ),
      );

      try {
        final details = await ReceivingBranchService.fetchDispatchDetails(
          event.branchId,
          event.dispatchId,
        );
        emit(
          DispatchDetailsLoaded(
            branches: branches,
            selectedBranchId: selectedBranchId,
            dashboardData:
                dashboardData ??
                ReceivingDashboardData(
                  expectedToday: 0,
                  readyForUnloading: 0,
                  delayedInTransit: 0,
                  totalShipments: 0,
                  shipments: [],
                ),
            dispatchDetails: details,
          ),
        );
      } catch (e) {
        emit(
          ReceivingBranchError(
            message: 'Failed to load dispatch details: $e',
            branches: branches,
            selectedBranchId: selectedBranchId,
            dashboardData: dashboardData,
          ),
        );
      }
    });

    on<ConfirmDispatchReceiveEvent>((event, emit) async {
      if (state is DispatchDetailsLoaded) {
        final curr = state as DispatchDetailsLoaded;
        emit(
          ConfirmReceiveInProgress(
            branches: curr.branches,
            selectedBranchId: curr.selectedBranchId,
            dashboardData: curr.dashboardData,
            dispatchDetails: curr.dispatchDetails,
          ),
        );

        try {
          await ReceivingBranchService.receiveStock(
            branchId: event.branchId,
            dispatchId: event.dispatchId,
            items: event.items,
            notes: event.notes,
          );

          emit(ConfirmReceiveSuccess("Stock received successfully!"));
        } catch (e) {
          emit(
            ReceivingBranchError(
              message: 'Failed to receive stock: $e',
              branches: curr.branches,
              selectedBranchId: curr.selectedBranchId,
              dashboardData: curr.dashboardData,
            ),
          );
        }
      }
    });
  }
}
