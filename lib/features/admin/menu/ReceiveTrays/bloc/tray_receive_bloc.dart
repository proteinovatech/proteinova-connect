import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/tray_receive_service.dart';
import 'tray_receive_event.dart';
import 'tray_receive_state.dart';

class TrayReceiveBloc
    extends Bloc<TrayReceiveEvent, TrayReceiveState> {

  final TrayReceiveService service;

  TrayReceiveBloc(this.service)
      : super(TrayReceiveInitial()) {

    on<FetchTrayReceiveNotes>(_fetchNotes);
  }

  Future<void> _fetchNotes(
    FetchTrayReceiveNotes event,
    Emitter<TrayReceiveState> emit,
  ) async {

    emit(TrayReceiveLoading());

    try {

      final notes = await service.getTrayReceiveNotes();

      emit(TrayReceiveLoaded(notes));

    } catch (e) {

      emit(TrayReceiveError(e.toString()));
    }
  }
}