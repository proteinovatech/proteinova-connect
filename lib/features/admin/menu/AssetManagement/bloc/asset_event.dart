part of 'asset_bloc.dart';

abstract class AssetEvent {}

class FetchAssetsEvent extends AssetEvent {}

class RefreshAssetsEvent extends AssetEvent {}