import 'package:flutter/material.dart';
import 'package:gabungyuk/feature/home/presentation/widget/category_chip.dart';
import 'package:gabungyuk/feature/home/presentation/widget/collaboration_card.dart';

import '../../../core/common/color_value.dart';
import 'detail_collaboration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 1;

  final List<String> _categories = [
    'Web Development',
    'UI/UX Design',
    'Mobile Dev',
    'Back End',
    'Data Science',
    'DevOps',
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundImage:
                          NetworkImage('https://i.pravatar.cc/150?img=8'),
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Magnus Carlsen',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ColorValue.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Android Developer',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ColorValue.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add button
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: const Icon(
                            Icons.add,
                            color: ColorValue.textPrimary,
                            size: 20,
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
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:  BorderSide(
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                  itemBuilder: (context, i) => CategoryChip(
                    label: _categories[i],
                    isSelected: _selectedCategoryIndex == i,
                    onTap: () => setState(() => _selectedCategoryIndex = i),
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
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final item = _collaborations[i];
                    return CollaborationCard(
                      ownerName: item['ownerName'],
                      ownerRole: item['ownerRole'],
                      ownerImageUrl: item['ownerImageUrl'],
                      memberImages: List<String>.from(item['memberImages']),
                      extraMembers: item['extraMembers'],
                      projectTitle: item['projectTitle'],
                      projectType: item['projectType'],
                      projectDate: item['projectDate'],
                      projectDescription: item['projectDescription'],
                      skills: List<String>.from(item['skills']),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const DetailCollaboration(),
                      )),
                    );
                  },
                  childCount: _collaborations.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}