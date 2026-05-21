part of 'asset_bloc.dart';

abstract class AssetState {}

class AssetInitial extends AssetState {}

class AssetLoading extends AssetState {}

class AssetLoaded extends AssetState {
  final List<AssetModel> assets;

  AssetLoaded(this.assets);
}

class AssetError extends AssetState {
  final String message;

  AssetError(this.message);
}