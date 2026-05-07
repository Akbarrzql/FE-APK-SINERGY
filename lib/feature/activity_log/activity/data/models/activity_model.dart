class ActivityModel {
  final String userName;
  final String action;
  final DateTime timestamp;

  ActivityModel({
    required this.userName,
    required this.action,
    required this.timestamp,
  });

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    return '$hour:$minute - $day/$month/$year';
  }
}
