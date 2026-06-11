import '../data/models/recap_model.dart';

abstract class RecapState {}

class RecapInitial extends RecapState {}

class RecapLoading extends RecapState {}

class RecapLoaded extends RecapState {
  final Map<DateTime, int> dailyDatasets;
  final RecapModel recapData;

  RecapLoaded({
    required this.dailyDatasets,
    required this.recapData,
  });
}

class RecapError extends RecapState {
  final String message;

  RecapError(this.message);
}
