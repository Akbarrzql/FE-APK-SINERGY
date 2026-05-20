import 'package:meta/meta.dart';
import 'package:gabungyuk/feature/task/data/models/recap_model.dart';

@immutable
abstract class RecapState {}

class RecapInitial extends RecapState {}

class RecapLoading extends RecapState {}

class RecapLoaded extends RecapState {
  final RecapModel dataRecap;
  final String activeFilter;

  RecapLoaded({required this.dataRecap, required this.activeFilter});
}

class RecapError extends RecapState {
  final String message;

  RecapError({required this.message});
}
