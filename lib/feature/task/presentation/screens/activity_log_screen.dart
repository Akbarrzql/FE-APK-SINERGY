import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../activity_log/activity/bloc/activity_log_bloc.dart';
import '../../../activity_log/activity/bloc/activity_log_event.dart';
import '../../../activity_log/activity/bloc/activity_log_state.dart';
import '../../../activity_log/activity/data/models/activity_log_model.dart';
import '../../../activity_log/activity/data/repositories/activity_log_repository.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late final ActivityLogBloc _activityLogBloc;

  @override
  void initState() {
    super.initState();
    _activityLogBloc = ActivityLogBloc(
      repository: ActivityLogRepositoryImpl(),
    )..add(FetchActivityLogs());
  }

  @override
  void dispose() {
    _activityLogBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _activityLogBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ActivityLogBloc, ActivityLogState>(
          builder: (context, state) {
            if (state is ActivityLogLoading) {
              return _buildShimmerLoading();
            } else if (state is ActivityLogLoaded) {
              if (state.activities.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _activityLogBloc.add(FetchActivityLogs());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: state.activities.length,
                  itemBuilder: (context, index) {
                    return _buildLogItem(state.activities[index]);
                  },
                ),
              );
            } else if (state is ActivityLogError) {
              return _buildErrorState(state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLogItem(Datum activity) {
    String formattedTime = "";
    try {
      if (activity.timestamp != null) {
        final date = DateTime.parse(activity.timestamp!);
        formattedTime = DateFormat('HH:mm').format(date);
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activity.isRead == false 
              ? ColorValue.primaryColor.withOpacity(0.3) 
              : Colors.grey.shade200,
          width: activity.isRead == false ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorValue.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: ColorValue.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.namaLengkap ?? "Sistem",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activity.message ?? "-",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Belum ada aktivitas",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _activityLogBloc.add(FetchActivityLogs()),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValue.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
