import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';
import '../widgets/activity_card.dart';
import '../widgets/empty_state.dart';

class ActivityLogPage extends StatelessWidget {
  ActivityLogPage({super.key});

  final List<ActivityModel> activities = [
    ActivityModel(
      userName: 'Magnus Carlsen',
      action: 'Melakukan Penambahan Kolaborasi',
      timestamp: DateTime(2025, 12, 23, 23, 58),
    ),
    ActivityModel(
      userName: 'Magnus Carlsen',
      action: 'Menambahkan Gambar Pada Halaman Project',
      timestamp: DateTime(2025, 12, 23, 23, 58),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 45,
        title: const Text(
          'Activity Log',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: activities.isEmpty
            ? const EmptyState()
            : ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ActivityCard(activity: activities[index]);
                },
              ),
      ),
    );
  }
}
