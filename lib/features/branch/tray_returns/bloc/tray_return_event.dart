part of 'tray_return_bloc.dart';

abstract class TrayReturnEvent {}

class FetchTrayReturnData extends TrayReturnEvent {
  final int branchId;
  final String date;

  FetchTrayReturnData({required this.branchId, required this.date});
}

class SubmitTrayReturn extends TrayReturnEvent {
  final Map<String, dynamic> data;

  SubmitTrayReturn({required this.data});
}
