import 'dart:convert';
import 'package:flutter/material.dart';

CalendarEventModel calendarEventModelFromJson(String str) =>
    CalendarEventModel.fromJson(jsonDecode(str));

class CalendarEventModel {
  final int status;
  final String message;
  final List<CalendarEvent> data;

  CalendarEventModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) => CalendarEventModel(
        status: json["status"] ?? 0,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<CalendarEvent>.from(
                json["data"].map((x) => CalendarEvent.fromJson(x))),
      );
}

class CalendarEvent {
  final int eventId;
  final int projectId;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isDone;

  CalendarEvent({
    required this.eventId,
    required this.projectId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isDone,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        eventId: json["eventId"] ?? 0,
        projectId: json["projectId"] ?? 0,
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        deadline: json["deadline"] != null
            ? DateTime.parse(json["deadline"])
            : DateTime.now(),
        isDone: json["isDone"] == true || 
                json["isDone"] == 1 || 
                json["isDone"] == "true" ||
                json["status"]?.toString().toUpperCase() == "DONE" ||
                json["status"]?.toString().toUpperCase() == "COMPLETED",
      );

  DateTime get date => deadline;

  String get time {
    final hour = deadline.hour.toString().padLeft(2, '0');
    final minute = deadline.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Color get color {
    if (isDone) return Colors.green;
    return const Color(0xFF1E6AF9);
  }
}
