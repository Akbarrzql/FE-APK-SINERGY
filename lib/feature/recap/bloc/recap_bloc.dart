import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/recap_repository.dart';
import 'recap_event.dart';
import 'recap_state.dart';
import '../../home/service/collaboration_service.dart';
import '../../activity_log/activity/data/repositories/activity_log_repository.dart';
import '../data/models/recap_model.dart';
import '../../collaboration/model/collaboration_profile_model.dart';
import '../../home/model/view_project_model.dart';

class RecapBloc extends Bloc<RecapEvent, RecapState> {
  final RecapRepository repository;
  final CollaborationService collaborationService = CollaborationService();
  final ActivityLogRepository activityLogRepository = ActivityLogRepositoryImpl();

  RecapBloc({required this.repository}) : super(RecapInitial()) {
    on<FetchRecapData>((event, emit) async {
      emit(RecapLoading());
      try {
        // 1. Fetch Recap Data (Heatmap & Stats)
        final recapData = await repository.getActivityRecap();
        
        // 2. Fetch Collaboration Data for accurate overview
        final collabDashboard = await collaborationService.getCollaborationDashboard();
        final ownedProjectsCount = collabDashboard.data?.ownedProjects?.length ?? 0;
        
        final allMyProjects = await collaborationService.getMyProjects();
        final totalProjects = allMyProjects.length;
        final collaborationsCount = totalProjects > ownedProjectsCount ? totalProjects - ownedProjectsCount : 0;

        // 3. Fetch Activity Logs & Project Names
        final activityLogs = await activityLogRepository.getActivityLogs();
        
        // Create a mapping of projectId to projectName for better activity display
        final Map<int, String> projectNames = {
          for (var p in allMyProjects) p.id: p.title
        };

        // Group logs by project to create ProjectStats
        final Map<int, int> projectActivityCounts = {};
        for (var log in activityLogs.data ?? []) {
          if (log.projectId != null) {
            projectActivityCounts[log.projectId!] = (projectActivityCounts[log.projectId!] ?? 0) + 1;
          }
        }

        final List<ProjectStat> projectStats = projectActivityCounts.entries.map((e) {
          return ProjectStat(
            projectName: projectNames[e.key] ?? "Project #${e.key}",
            contributionCount: e.value,
            isOwned: collabDashboard.data?.ownedProjects?.any((p) => p.id == e.key) ?? false,
          );
        }).toList();

        // Sort project stats by contribution count descending
        projectStats.sort((a, b) => b.contributionCount.compareTo(a.contributionCount));

        // 4. Process Heatmap: Generate full 365 days
        final dailyDatasets = <DateTime, int>{};
        final now = DateTime.now();
        // GitHub-style: end on the Saturday of the current week
        final endDate = now.add(Duration(days: 6 - (now.weekday % 7)));
        final startDate = endDate.subtract(const Duration(days: 363)); // 52 weeks exactly

        for (int i = 0; i < 364; i++) {
          final date = startDate.add(Duration(days: i));
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

        // 5. Update the recap model
        final updatedRecap = recapData.copyWith(
          ownedProjectsCount: ownedProjectsCount,
          collaborationProjectsCount: collaborationsCount,
          totalActivityCount: calculatedTotal,
        );

        // Manually inject projectStats and totalContributions
        final finalRecap = RecapModel(
          status: updatedRecap.status,
          message: updatedRecap.message,
          dailyContributions: updatedRecap.dailyContributions,
          totalContributions: calculatedTotal > 0 ? calculatedTotal : recapData.totalContributions,
          ownedProjectsCount: updatedRecap.ownedProjectsCount,
          collaborationProjectsCount: updatedRecap.collaborationProjectsCount,
          projectStats: projectStats,
          totalActivityCount: calculatedTotal,
        );

        emit(RecapLoaded(
          dailyDatasets: dailyDatasets,
          recapData: finalRecap,
        ));
      } catch (e) {
        emit(RecapError(e.toString()));
      }
    });
  }

  String _extractProjectName(String message) {
    // Basic logic to extract project name from log message if it follows a pattern
    // e.g., "Created task in Project X" or "Updated status in Project X"
    if (message.contains(" in ")) {
      return message.split(" in ").last;
    }
    return message;
  }
}
