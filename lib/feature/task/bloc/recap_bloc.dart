import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/auth_session_manager.dart';
import 'package:gabungyuk/feature/task/bloc/recap_event.dart';
import 'package:gabungyuk/feature/task/bloc/recap_state.dart';
import 'package:gabungyuk/feature/task/data/repositories/recap_repository.dart';

class RecapBloc extends Bloc<RecapEvent, RecapState> {
  final RecapRepository recapRepository;

  RecapBloc({required this.recapRepository}) : super(RecapInitial()) {
    on<FetchRecapData>((event, emit) async {
      emit(RecapLoading());
      try {
        final recap = await recapRepository.fetchRecap(event.filterWaktu);
        emit(RecapLoaded(dataRecap: recap, activeFilter: event.filterWaktu));
      } catch (e) {
        if (e is ApiException) {
          if (e.statusCode == 401) {
            await AuthSessionManager.instance.forceLogout();
            return;
          }
          emit(RecapError(message: e.message));
        } else {
          emit(RecapError(message: 'Terjadi kesalahan. Silakan coba lagi.'));
        }
      }
    });
  }
}
