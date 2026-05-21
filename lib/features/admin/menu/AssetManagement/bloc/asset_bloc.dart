import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/asset_repository.dart';
import '../models/asset_model.dart';

part 'asset_event.dart';
part 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {

  final AssetRepository repository;

  AssetBloc(this.repository)
      : super(AssetInitial()) {

    on<FetchAssetsEvent>((event, emit) async {

      emit(AssetLoading());

      try {

        final assets =
            await repository.fetchAssets();

        emit(AssetLoaded(assets));

      } catch (e) {

        emit(
          AssetError(e.toString()),
        );
      }
    });

    on<RefreshAssetsEvent>((event, emit) async {

      try {

        final assets =
            await repository.fetchAssets();

        emit(AssetLoaded(assets));

      } catch (e) {

        emit(
          AssetError(e.toString()),
        );
      }
    });
  }
}