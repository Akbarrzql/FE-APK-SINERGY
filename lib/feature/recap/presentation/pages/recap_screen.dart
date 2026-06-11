import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/recap_bloc.dart';
import '../../bloc/recap_event.dart';
import '../../bloc/recap_state.dart';
import '../../data/repositories/recap_repository.dart';
import '../widgets/contribution_heatmap.dart';

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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF39D353)),
            );
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
                    
                    // Heatmap (Responsive)
                    ContributionHeatMap(
                      datasets: state.dailyDatasets,
                      endDate: state.dailyDatasets.keys.reduce((a, b) => a.isAfter(b) ? a : b),
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
                    const SizedBox(height: 12),
                    
                    // Stats Grid (Owned vs Collaboration)
                    _buildStatsGrid(recap),
                    
                    const SizedBox(height: 16),
                    
                    // Detailed Project Stats Card
                    if (recap.projectStats.isNotEmpty) ...[
                      _buildProjectStatsCard(recap),
                      const SizedBox(height: 24),
                    ],
                    
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
                    
                    // Dynamic Activity Items
                    if (recap.projectStats.isNotEmpty)
                      ...recap.projectStats.map((stat) => _buildActivityItem(
                        projectName: stat.projectName,
                        count: stat.contributionCount,
                        isOwned: stat.isOwned,
                      ))
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

  Widget _buildStatsGrid(dynamic recap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem('Owned Projects', recap.ownedProjectsCount.toString(), Colors.blue, itemWidth),
            _buildStatItem('Collaborations', recap.collaborationProjectsCount.toString(), Colors.green, itemWidth),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatsCard(dynamic recap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'Top Projects',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recap.projectStats.take(3).map((stat) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    stat.projectName,
                    style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF0969DA)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${stat.contributionCount} acts',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String projectName,
    required int count,
    required bool isOwned,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalDivider(
              thickness: 2,
              color: Color(0xFFD0D7DE),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isOwned ? Icons.person_outline : Icons.people_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: 'Made $count contributions to ',
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: projectName,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0969DA)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOwned ? 'Owned Project' : 'Collaboration',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isOwned ? Colors.blue.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.w500,
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
