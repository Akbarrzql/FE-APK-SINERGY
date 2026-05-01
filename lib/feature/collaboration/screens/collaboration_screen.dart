import 'package:flutter/material.dart';
import '../models/collaboration.dart';
import '../widgets/collaboration_card.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/search_bar.dart';
import '../../../app_colors.dart';

class CollaborationScreen extends StatefulWidget {
  const CollaborationScreen({super.key});

  @override
  State<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends State<CollaborationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  List<CollaborationModel> get _filteredList {
    List<CollaborationModel> list = dummyCollaborations;

    // Filter by tab
    if (_selectedFilter == 'Anda') {
      list = list.where((c) => c.isOwnedByUser).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.projectName.toLowerCase().contains(q) ||
              c.ownerName.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kolaborasi Saya',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Search Bar ──
            CollaborationSearchBar(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
            ),

            const SizedBox(height: 16),

            // ── Filter Tabs ──
            CollaborationFilterTabs(
              selected: _selectedFilter,
              onChanged: (val) => setState(() => _selectedFilter = val),
            ),

            const SizedBox(height: 16),

            // ── List ──
            Expanded(
              child: _filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada kolaborasi ditemukan',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) => CollaborationCard(
                        collaboration: _filteredList[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
