import '../data/models/activity_log_model.dart';

abstract class ActivityLogState {}

class ActivityLogInitial extends ActivityLogState {}

class ActivityLogLoading extends ActivityLogState {}

class ActivityLogLoaded extends ActivityLogState {
  final List<Datum> activities;
  final Map<String, int>? recap;
  ActivityLogLoaded(this.activities, {this.recap});
}

class ActivityLogError extends ActivityLogState {
  final String message;
  ActivityLogError(this.message);
}
