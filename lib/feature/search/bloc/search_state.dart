import 'package:flutter/foundation.dart';
import 'package:gabungyuk/feature/search/model/screen_model.dart';

@immutable
abstract class SearchState {}

class InitialSearchState extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final SearchModel result;

  SearchLoaded(this.result);
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}

class SearchCleared extends SearchState {}

