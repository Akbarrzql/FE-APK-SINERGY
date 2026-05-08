import 'package:flutter/material.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'package:gabungyuk/feature/home/presentation/widget/category_chip.dart';
import 'package:gabungyuk/feature/home/presentation/widget/collaboration_card.dart';
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';

import '../../../core/common/color_value.dart';
import 'create_collaboration.dart';
import 'detail_collaboration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();
  final CollaborationService _collaborationService = CollaborationService();

  ViewProfileModel? _profile;
  List<Datum> _projects = [];
  bool _isLoadingProfile = true;
  bool _isLoadingProjects = true;

  List<Datum> get _filteredProjects {
    // Reverse the projects list to show newest first
    final reversedProjects = _projects.reversed.toList();
    if (_selectedCategoryIndex == 0) {
      return reversedProjects;
    }
    return reversedProjects
        .where((project) =>
            project.category == _categories[_selectedCategoryIndex])
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchProfile(),
      _fetchProjects(),
    ]);
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await _profileRepository.getViewProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _fetchProjects() async {
    try {
      final projects = await _collaborationService.getMyProjects();
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProjects = false;
        });
      }
      debugPrint('Error fetching projects: $e');
    }
  }

  Widget _buildProfileAvatar(String? source) {
    final imageUrl = source?.trim() ?? '';
    return ClipOval(
      child: Container(
        width: 52,
        height: 52,
        color: Colors.blue,
        child: imageUrl.isEmpty
            ? const Icon(Icons.person, color: Colors.white, size: 30)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 52,
                height: 52,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 30),
              ),
      ),
    );
  }

  final List<String> _categories = [
    'Semua',
    'Web Development',
    'UI/UX Design',
    'Mobile Dev',
    'Back End',
    'Data Science',
    'Data Analyst',
  ];

  final List<Map<String, dynamic>> _collaborations = [
    {
      'ownerName': 'Ellenors Blundell',
      'ownerRole': 'Pemilik Kolaborasi',
      'ownerImageUrl': 'https://i.pravatar.cc/150?img=47',
      'memberImages': [
        'https://i.pravatar.cc/150?img=12',
        'https://i.pravatar.cc/150?img=23',
      ],
      'extraMembers': 2,
      'projectTitle': 'Moneyger Application Project',
      'projectType': 'Portofolio project',
      'projectDate': '12 Maret 2023',
      'projectDescription':
      'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah.',
      'skills': ['Mobile Front End', 'Back End', 'UI/UX'],
    },
    {
      'ownerName': 'Ellenors Blundell',
      'ownerRole': 'Pemilik Kolaborasi',
      'ownerImageUrl': 'https://i.pravatar.cc/150?img=47',
      'memberImages': [
        'https://i.pravatar.cc/150?img=12',
        'https://i.pravatar.cc/150?img=23',
      ],
      'extraMembers': 2,
      'projectTitle': 'Moneyger Application Project',
      'projectType': 'Portofolio project',
      'projectDate': '12 Maret 2023',
      'projectDescription':
      'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah.',
      'skills': ['Mobile Front End', 'Back End', 'UI/UX'],
    },
    {
      'ownerName': 'Rina Hartono',
      'ownerRole': 'Pemilik Kolaborasi',
      'ownerImageUrl': 'https://i.pravatar.cc/150?img=32',
      'memberImages': [
        'https://i.pravatar.cc/150?img=15',
        'https://i.pravatar.cc/150?img=19',
      ],
      'extraMembers': 3,
      'projectTitle': 'E-Commerce Platform Design',
      'projectType': 'Freelance project',
      'projectDate': '5 April 2023',
      'projectDescription':
      'Desain platform e-commerce modern dengan pengalaman pengguna yang intuitif.',
      'skills': ['UI/UX', 'Web Design', 'Prototyping'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValue.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildProfileAvatar(_profile?.profilePicture),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isLoadingProfile ? 'Loading...' : (_profile
                                      ?.namaLengkap ?? 'Guest'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ColorValue.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isLoadingProfile ? '...' : (_profile
                                      ?.institusi ?? 'No Institution'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: ColorValue.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Add button
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateCollaborationPage(),
                                ),
                              );
                              if (result == true) {
                                _fetchProjects();
                              }
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              child: const Icon(
                                Icons.add,
                                color: ColorValue.textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Bell button
                          Stack(
                            children: [
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: ColorValue.textPrimary,
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 50,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari Kolaborasi',
                            hintStyle: const TextStyle(
                              color: ColorValue.textSecondary,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: ColorValue.textSecondary,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: ColorValue.borderColor,
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: ColorValue.borderColor,
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF2F80ED),
                                width: 1.4,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15),
                          ),

                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pilih kategori pilihanmu yang kamu ingin cari',
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorValue.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) =>
                        CategoryChip(
                          label: _categories[i],
                          isSelected: _selectedCategoryIndex == i,
                          onTap: () =>
                              setState(() => _selectedCategoryIndex = i),
                        ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rekomendasi untuk anda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorValue.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 13,
                                color: ColorValue.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: ColorValue.primaryColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _isLoadingProjects
                    ? const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()))
                    : _filteredProjects.isEmpty
                    ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'Belum ada proyek di kategori ini',
                        style: TextStyle(
                          color: ColorValue.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      final item = _filteredProjects[i];
                      return CollaborationCard(
                        ownerName: _profile?.namaLengkap ?? 'User',
                        ownerRole: 'Pemilik Proyek',
                        ownerImageUrl: _profile?.profilePicture ??
                            'https://i.pravatar.cc/150?img=8',
                        memberImages: [],
                        extraMembers: 0,
                        projectTitle: item.title,
                        projectType: item.category ?? 'General',
                        projectDate: '-',
                        // Backend doesn't provide date yet
                        projectDescription: item.description,
                        skills: [],
                        // Backend doesn't provide skills list yet
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailCollaboration(
                                    project: item,
                                    owner: _profile,
                                  ),
                            ),
                          );
                          if (result == true) {
                            _fetchProjects();
                          }
                        },
                      );
                    },
                    childCount: _filteredProjects.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
