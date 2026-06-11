import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/recap_repository.dart';
import 'recap_event.dart';
import 'recap_state.dart';
import '../../home/service/collaboration_service.dart';
import '../../activity_log/activity/data/repositories/activity_log_repository.dart';
import '../../activity_log/activity/data/models/activity_log_model.dart' as activity_log;
import '../data/models/recap_model.dart';
import '../../collaboration/model/collaboration_profile_model.dart' as collab_model;
import '../../home/model/view_project_model.dart' as project_model;

class RecapBloc extends Bloc<RecapEvent, RecapState> {
  final RecapRepository repository;
  final CollaborationService collaborationService = CollaborationService();
  final ActivityLogRepository activityLogRepository = ActivityLogRepositoryImpl();

  RecapBloc({required this.repository}) : super(RecapInitial()) {
    on<FetchRecapData>((event, emit) async {
      emit(RecapLoading());
      try {
        // 1. Fetch data dari berbagai source
        final results = await Future.wait([
          repository.getActivityRecap(),
          collaborationService.getCollaborationDashboard(),
          activityLogRepository.getActivityLogs(),
        ]);

        final recapData = results[0] as RecapModel;
        final collabDashboard = results[1] as collab_model.CollaborationProfileModel;
        final activityLogs = results[2] as activity_log.ActivityLogModel;

        // 2. Tentukan Owned Projects & Collaborations (Mengikuti UI Kolaborasi Saya)
        // Owned Projects = projects created by user
        final ownedProjects = collabDashboard.data?.ownedProjects ?? [];
        
        // Collaborations = projects user has joined (Accepted only)
        final requestCollabs = collabDashboard.data?.requestCollab ?? [];
        
        // Filter requestCollab: We only count those where the status indicates active collaboration
        // status "ACCEPTED" or if the UI logic maps it to "Sedang Berjalan", "Selesai", etc.
        final joinedProjects = requestCollabs.where((c) {
          // If it's a Map (from dynamic list), check status
          if (c is Map) {
            final status = c['status']?.toString().toUpperCase();
            return status == 'ACCEPTED';
          }
          return false;
        }).toList();

        final ownedCount = ownedProjects.length;
        final collabCount = joinedProjects.length;

        // 3. Hitung Active Projects (Sedang Berjalan)
        // Active means status is 'OPEN' (Backend) or 'Sedang Berjalan' (UI Mapping)
        bool isProjectActive(String? status) {
          if (status == null) return false;
          final s = status.toUpperCase();
          return s == 'OPEN' || s == 'SEDANG BERJALAN';
        }

        final activeOwned = ownedProjects.where((p) => isProjectActive(p.status)).length;
        
        final activeJoined = joinedProjects.where((c) {
          if (c is Map) {
            final projectStatus = c['project']?['status']?.toString().toUpperCase();
            return isProjectActive(projectStatus);
          }
          return false;
        }).length;

        final activeProjectsCount = activeOwned + activeJoined;

        // 4. Process Heatmap: Generate FULL 365+ days range
        final dailyDatasets = <DateTime, int>{};
        final now = DateTime.now();
        final int daysToSaturday = (6 - (now.weekday % 7));
        final DateTime gridEnd = DateTime(now.year, now.month, now.day).add(Duration(days: daysToSaturday));
        final DateTime gridStart = gridEnd.subtract(const Duration(days: 370));

        for (int i = 0; i <= 370; i++) {
          final date = gridStart.add(Duration(days: i));
          dailyDatasets[DateTime(date.year, date.month, date.day)] = 0;
        }

        int calculatedTotal = 0;
        recapData.dailyContributions.forEach((key, value) {
          final date = DateTime.tryParse(key);
          if (date != null) {
            final normalizedDate = DateTime(date.year, date.month, date.day);
            if (dailyDatasets.containsKey(normalizedDate)) {
              dailyDatasets[normalizedDate] = value;
              calculatedTotal += value;
            }
          }
        });

        // 5. Update Recap Model
        final Map<String, int> dailyStringMap = dailyDatasets.map(
          (key, value) => MapEntry(key.toIso8601String(), value),
        );

        final finalRecap = RecapModel(
          status: recapData.status,
          message: recapData.message,
          dailyContributions: dailyStringMap,
          totalContributions: calculatedTotal,
          ownedProjectsCount: ownedCount,
          collaborationProjectsCount: collabCount,
          totalActivityCount: activityLogs.data?.length ?? 0,
          projectStats: recapData.projectStats,
        );

        emit(RecapLoaded(
          dailyDatasets: dailyDatasets,
          recapData: finalRecap,
          activeProjectsCount: activeProjectsCount,
          recentActivities: activityLogs.data ?? [],
        ));
      } catch (e) {
        emit(RecapError(e.toString()));
      }
    });
  }
}
