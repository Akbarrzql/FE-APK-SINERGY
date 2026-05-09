import '../data/models/activity_log_model.dart';

abstract class ActivityLogState {}

class ActivityLogInitial extends ActivityLogState {}

class ActivityLogLoading extends ActivityLogState {}

class ActivityLogLoaded extends ActivityLogState {
  final List<Datum> activities;
  ActivityLogLoaded(this.activities);
}

class ActivityLogError extends ActivityLogState {
  final String message;
  ActivityLogError(this.message);
}
