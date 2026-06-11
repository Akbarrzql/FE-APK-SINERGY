import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/activity_log_repository.dart';
import 'activity_log_event.dart';
import 'activity_log_state.dart';

class ActivityLogBloc extends Bloc<ActivityLogEvent, ActivityLogState> {
  final ActivityLogRepository repository;

  ActivityLogBloc({required this.repository}) : super(ActivityLogInitial()) {
    on<FetchActivityLogs>((event, emit) async {
      emit(ActivityLogLoading());
      try {
        final result = await repository.getActivityLogs();
        emit(ActivityLogLoaded(result.data ?? []));
      } catch (e) {
        emit(ActivityLogError(e.toString()));
      }
    });

    on<FetchActivityRecap>((event, emit) async {
      // In case we want to fetch only recap or update it
      // Usually we fetch both together in this specific UX
      add(FetchActivityLogs());
    });
  }
}
