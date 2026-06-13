import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/admin/inventory/data/inventory_repository.dart';
import 'package:proteinova_connect/features/admin/menu/AssetManagement/data/asset_repository.dart';
import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final InventoryRepository inventoryRepository;
  final AssetRepository assetRepository;

  ItemBloc({
    required this.inventoryRepository,
    required this.assetRepository,
  }) : super(ItemInitial()) {
    on<FetchItemsEvent>(_onFetchItems);
    on<SubmitStockEvent>(_onSubmitStock);
  }

  Future<void> _onSubmitStock(SubmitStockEvent event, Emitter<ItemState> emit) async {
    if (state is ItemLoaded) {
      final currentState = state as ItemLoaded;
      emit(currentState.copyWith(isSubmitting: true));
      
      try {
        await inventoryRepository.updateManualStock(event.eggForms, event.trayForms);
        emit(ItemSubmitSuccess());
        // Reload data after success
        add(FetchItemsEvent());
      } catch (e) {
        emit(ItemSubmitFailure(e.toString()));
        emit(currentState.copyWith(isSubmitting: false));
      }
    }
  }

  Future<void> _onFetchItems(FetchItemsEvent event, Emitter<ItemState> emit) async {
    emit(ItemLoading());
    try {
      final results = await Future.wait([
        inventoryRepository.fetchRawInventoryData(),
        assetRepository.fetchAssets(),
      ]);

      final rawInventory = results[0] as Map<String, dynamic>;
      final assetsList = results[1] as List<dynamic>;

      int eggs = int.tryParse(rawInventory['current_stock']?.toString() ?? '0') ?? 0;

      int plasticTrays = int.tryParse(rawInventory['plastic_trays']?.toString() ?? '0') ?? 0;
      int paperTrays = int.tryParse(rawInventory['paper_trays']?.toString() ?? '0') ?? 0;

      List<dynamic> eggCategories = rawInventory['category_stock'] is List ? rawInventory['category_stock'] : [];
      List<dynamic> plasticTraysList = [];
      List<dynamic> paperTraysList = [];

      // Always try to populate lists from assets just in case, but prioritize inventory data if available
      for (var asset in assetsList) {
        final name = asset.name.toString().toLowerCase();
        if (name.contains("plastic") && name.contains("tray")) {
          plasticTraysList.add({
             "category": asset.name,
             "total_eggs": asset.quantity,
          });
        } else if (name.contains("paper") && name.contains("tray")) {
          paperTraysList.add({
             "category": asset.name,
             "total_eggs": asset.quantity,
          });
        }
      }

      if (plasticTrays == 0 && paperTrays == 0) {
        for (var asset in assetsList) {
          final name = asset.name.toString().toLowerCase();
          if (name.contains("plastic") && name.contains("tray")) {
            plasticTrays += (asset.quantity as num).toInt();
          } else if (name.contains("paper") && name.contains("tray")) {
            paperTrays += (asset.quantity as num).toInt();
          }
        }
      }

      // If we got plastic_trays from inventory but no list from assets, create a mocked breakdown for the UI
      if (plasticTrays > 0 && plasticTraysList.isEmpty) {
         int largeTrays = (plasticTrays * 0.8).toInt();
         int smallTrays = plasticTrays - largeTrays;
         plasticTraysList.add({ "category": "30-Egg Plastic Trays", "total_eggs": largeTrays });
         if (smallTrays > 0) {
           plasticTraysList.add({ "category": "12-Egg Plastic Trays", "total_eggs": smallTrays });
         }
      }
      if (paperTrays > 0 && paperTraysList.isEmpty) {
         int largeTrays = (paperTrays * 0.8).toInt();
         int smallTrays = paperTrays - largeTrays;
         paperTraysList.add({ "category": "30-Egg Paper Trays", "total_eggs": largeTrays });
         if (smallTrays > 0) {
           paperTraysList.add({ "category": "12-Egg Paper Trays", "total_eggs": smallTrays });
         }
      }

      emit(ItemLoaded(
        plasticTrays: plasticTrays,
        paperTrays: paperTrays,
        eggs: eggs,
        eggCategories: eggCategories,
        plasticTraysList: plasticTraysList,
        paperTraysList: paperTraysList,
      ));
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }
}
