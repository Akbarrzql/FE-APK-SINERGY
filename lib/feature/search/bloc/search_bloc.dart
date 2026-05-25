import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/feature/search/bloc/search_event.dart';
import 'package:gabungyuk/feature/search/bloc/search_state.dart';
import 'package:gabungyuk/feature/search/repository/search_repository.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/auth_session_manager.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;

  SearchBloc({required this.searchRepository}) : super(InitialSearchState()) {
    on<SearchQuery>((event, emit) async {
      emit(SearchLoading());
      try {
        final result = await searchRepository.searchQuery(event.query);
        emit(SearchLoaded(result));
      } catch (e) {
        if (e is ApiException) {
          if (e.statusCode == 401) {
            await AuthSessionManager.instance.forceLogout();
            return;
          }
          emit(SearchError(e.message));
        } else {
          emit(SearchError('Terjadi kesalahan saat mencari. Silakan coba lagi.'));
        }
      }
    });

    on<ClearSearch>((event, emit) async {
      emit(SearchCleared());
    });
  }
}

