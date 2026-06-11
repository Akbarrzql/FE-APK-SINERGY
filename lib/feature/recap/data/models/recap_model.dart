import 'dart:convert';

RecapModel recapModelFromJson(String str) => RecapModel.fromJson(json.decode(str));

String recapModelToJson(RecapModel data) => json.encode(data.toJson());

class RecapModel {
  final int status;
  final String message;
  final Map<String, int> dailyContributions;
  final int totalContributions;
  final int ownedProjectsCount;
  final int collaborationProjectsCount;
  final List<ProjectStat> projectStats;
  final int totalActivityCount;

  RecapModel({
    required this.status,
    required this.message,
    required this.dailyContributions,
    this.totalContributions = 0,
    this.ownedProjectsCount = 0,
    this.collaborationProjectsCount = 0,
    this.projectStats = const [],
    this.totalActivityCount = 0,
  });

  factory RecapModel.fromJson(Map<String, dynamic> json) {
    // Check if "data" is a Map or List. Based on prompt it's Map<String, int>
    final dynamic rawData = json["data"];
    final Map<String, int> daily = {};
    int total = 0;

    if (rawData is Map) {
      rawData.forEach((key, value) {
        if (value is int) {
          daily[key] = value;
          total += value;
        }
      });
    }

    final List<dynamic> pStats = json["project_stats"] ?? [];

    return RecapModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      dailyContributions: daily,
      totalContributions: json["total_contributions"] ?? total,
      ownedProjectsCount: json["owned_projects_count"] ?? 0,
      collaborationProjectsCount: json["collaboration_projects_count"] ?? 0,
      totalActivityCount: json["total_activity_count"] ?? total,
      projectStats: pStats.map((x) => ProjectStat.fromJson(x)).toList(),
    );
  }

  // Helper to create a copy with updated stats from other sources if needed
  RecapModel copyWith({
    int? ownedProjectsCount,
    int? collaborationProjectsCount,
    int? totalActivityCount,
  }) {
    return RecapModel(
      status: status,
      message: message,
      dailyContributions: dailyContributions,
      totalContributions: totalContributions,
      ownedProjectsCount: ownedProjectsCount ?? this.ownedProjectsCount,
      collaborationProjectsCount: collaborationProjectsCount ?? this.collaborationProjectsCount,
      projectStats: projectStats,
      totalActivityCount: totalActivityCount ?? this.totalActivityCount,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": dailyContributions,
    "total_contributions": totalContributions,
    "owned_projects_count": ownedProjectsCount,
    "collaboration_projects_count": collaborationProjectsCount,
    "total_activity_count": totalActivityCount,
    "project_stats": List<dynamic>.from(projectStats.map((x) => x.toJson())),
  };
}

class ProjectStat {
  final String projectName;
  final int contributionCount;
  final bool isOwned;

  ProjectStat({
    required this.projectName,
    required this.contributionCount,
    required this.isOwned,
  });

  factory ProjectStat.fromJson(Map<String, dynamic> json) => ProjectStat(
    projectName: json["project_name"] ?? "Unknown Project",
    contributionCount: json["contribution_count"] ?? 0,
    isOwned: json["is_owned"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "project_name": projectName,
    "contribution_count": contributionCount,
    "is_owned": isOwned,
  };
}
