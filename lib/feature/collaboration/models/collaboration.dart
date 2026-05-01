import 'package:flutter/material.dart';

class MemberModel {
  final String initials;
  final Color color;

  const MemberModel({
    required this.initials,
    required this.color,
  });
}

class CollaborationModel {
  final String id;
  final String ownerName;
  final String ownerInitials;
  final Color ownerColor;
  final String role;
  final String status;
  final String projectName;
  final String category;
  final String date;
  final String description;
  final List<String> tags;
  final List<MemberModel> members;
  final int extraMembers;
  final bool isOwnedByUser;

  const CollaborationModel({
    required this.id,
    required this.ownerName,
    required this.ownerInitials,
    required this.ownerColor,
    required this.role,
    required this.status,
    required this.projectName,
    required this.category,
    required this.date,
    required this.description,
    required this.tags,
    required this.members,
    required this.extraMembers,
    required this.isOwnedByUser,
  });
}

final List<CollaborationModel> dummyCollaborations = [
  const CollaborationModel(
    id: '1',
    ownerName: 'Ellenors Blundell',
    ownerInitials: 'EB',
    ownerColor: Color(0xFF7C3AED),
    role: 'Pemilik Kolaborasi',
    status: 'Selesai',
    projectName: 'Moneyger Application Project',
    category: 'Portofolio project',
    date: '12 Maret 2023',
    description:
        'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah.',
    tags: ['Mobile Front End', 'Back End'],
    members: [
      MemberModel(initials: 'AB', color: Color(0xFF7C3AED)),
      MemberModel(initials: 'CD', color: Color(0xFFEC4899)),
      MemberModel(initials: 'EF', color: Color(0xFFF59E0B)),
    ],
    extraMembers: 2,
    isOwnedByUser: false,
  ),
  const CollaborationModel(
    id: '2',
    ownerName: 'Anda',
    ownerInitials: 'GY',
    ownerColor: Color(0xFF3B82F6),
    role: 'Pemilik Kolaborasi',
    status: 'Selesai',
    projectName: 'Moneyger Application Project',
    category: 'Portofolio project',
    date: '12 Maret 2023',
    description:
        'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah.',
    tags: ['Mobile Front End', 'Back End'],
    members: [
      MemberModel(initials: 'AB', color: Color(0xFF7C3AED)),
      MemberModel(initials: 'CD', color: Color(0xFFEC4899)),
      MemberModel(initials: 'EF', color: Color(0xFFF59E0B)),
    ],
    extraMembers: 2,
    isOwnedByUser: true,
  ),
  const CollaborationModel(
    id: '3',
    ownerName: 'Budi Santoso',
    ownerInitials: 'BS',
    ownerColor: Color(0xFF10B981),
    role: 'Anggota',
    status: 'Aktif',
    projectName: 'GabungYuk Mobile App',
    category: 'Portofolio project',
    date: '5 Januari 2024',
    description:
        'Platform kolaborasi untuk mahasiswa agar dapat bekerja sama dalam proyek nyata.',
    tags: ['Mobile Front End', 'UI/UX'],
    members: [
      MemberModel(initials: 'BS', color: Color(0xFF10B981)),
      MemberModel(initials: 'AN', color: Color(0xFF3B82F6)),
    ],
    extraMembers: 1,
    isOwnedByUser: false,
  ),
];
