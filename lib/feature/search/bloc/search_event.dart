import 'package:flutter/foundation.dart';

@immutable
abstract class SearchEvent {}

class SearchQuery extends SearchEvent {
  final String query;

  SearchQuery(this.query);
}

class ClearSearch extends SearchEvent {}

