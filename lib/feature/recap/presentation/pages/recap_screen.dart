import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../bloc/recap_bloc.dart';
import '../../bloc/recap_event.dart';
import '../../bloc/recap_state.dart';
import '../../data/repositories/recap_repository.dart';
import '../widgets/contribution_heatmap.dart';
import '../../../activity_log/activity/data/models/activity_log_model.dart' as activity_log;

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecapBloc(
        repository: RecapRepositoryImpl(),
      )..add(FetchRecapData()),
      child: BlocBuilder<RecapBloc, RecapState>(
        builder: (context, state) {
          if (state is RecapLoading) {
            return _buildShimmerLoading();
          }

          if (state is RecapError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RecapBloc>().add(FetchRecapData());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF238636),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RecapLoaded) {
            final recap = state.recapData;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RecapBloc>().add(FetchRecapData());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Contributions Header
                    Text(
                      '${recap.totalContributions} contributions in the last year',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Heatmap (GitHub Style)
                    ContributionHeatMap(
                      datasets: state.dailyDatasets,
                      endDate: DateTime.now(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Activity Overview Section
                    Text(
                      'Activity overview',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Grid (Mirip GitHub overview)
                    _buildOverviewGrid(recap, state.activeProjectsCount),
                    
                    const SizedBox(height: 24),
                    
                    // Contribution Activity Section
                    Text(
                      'Contribution activity',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Real Activity Items
                    if (state.recentActivities.isNotEmpty)
                      ...state.recentActivities.map((activity) => _buildActivityItem(activity))
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, color: Colors.grey.shade300, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'No recent activity found',
                                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOverviewGrid(dynamic recap, int activeCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatItem('Owned Projects', recap.ownedProjectsCount.toString(), const Color(0xFF0969DA), Icons.folder_outlined),
        _buildStatItem('Collaborations', recap.collaborationProjectsCount.toString(), const Color(0xFF1A7F37), Icons.people_outline),
        _buildStatItem('Contribution Acts', recap.totalActivityCount.toString(), const Color(0xFF9A6700), Icons.bolt),
        _buildStatItem('Active Projects', activeCount.toString(), const Color(0xFF8250DF), Icons.rocket_launch_outlined),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingShimmer(width: 200, height: 14),
          const SizedBox(height: 12),
          const LoadingShimmer(width: double.infinity, height: 150),
          const SizedBox(height: 24),
          const LoadingShimmer(width: 120, height: 16),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: List.generate(4, (index) => const LoadingShimmer(width: double.infinity, height: double.infinity, borderRadius: 16)),
          ),
          const SizedBox(height: 24),
          const LoadingShimmer(width: 150, height: 16),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const LoadingShimmer(width: 30, height: 30, borderRadius: 15),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LoadingShimmer(width: double.infinity, height: 13),
                      const SizedBox(height: 4),
                      const LoadingShimmer(width: 100, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withOpacity(0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(activity_log.Datum activity) {
    DateTime? date;
    if (activity.timestamp != null) {
      date = DateTime.tryParse(activity.timestamp!);
    }
    
    final timeStr = date != null ? DateFormat('MMM d').format(date) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.commit, size: 14, color: Colors.grey),
                ),
                Expanded(
                  child: VerticalDivider(
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          activity.message ?? 'Unknown activity',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Activity in ${activity.namaLengkap ?? 'Project'}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
