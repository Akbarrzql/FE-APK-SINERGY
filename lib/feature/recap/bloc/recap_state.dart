import '../data/models/recap_model.dart';
import '../../activity_log/activity/data/models/activity_log_model.dart' as activity_log;

abstract class RecapState {}

class RecapInitial extends RecapState {}

class RecapLoading extends RecapState {}

class RecapLoaded extends RecapState {
  final Map<DateTime, int> dailyDatasets;
  final RecapModel recapData;
  final int activeProjectsCount;
  final List<activity_log.Datum> recentActivities;

  RecapLoaded({
    required this.dailyDatasets,
    required this.recapData,
    this.activeProjectsCount = 0,
    this.recentActivities = const [],
  });
}

class RecapError extends RecapState {
  final String message;

  RecapError(this.message);
}
