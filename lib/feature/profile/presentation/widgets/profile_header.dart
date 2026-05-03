import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel? profile;

  const ProfileHeader({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blueAccent,
                child: _buildProfileAvatar(profile?.profilePicture),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.namaLengkap ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.bio ?? '-',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profile?.bio ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _socialIcon(FontAwesomeIcons.instagram, Colors.black, () {
                print("Klik Instagram");
              }),
              _socialIcon(FontAwesomeIcons.linkedinIn, Colors.black, () {
                print("Klik LinkedIn");
              }),
              _socialIcon(FontAwesomeIcons.facebookF, Colors.black, () {
                print("Klik Facebook");
              }),
              _socialIcon(FontAwesomeIcons.whatsapp, Colors.black, () {
                print("Klik WhatsApp");
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(String? source) {
    final value = source?.trim() ?? '';
    if (value.isEmpty) {
      return const Icon(Icons.person, color: Colors.white, size: 40);
    }

    if (value.startsWith('data:')) {
      try {
        final parts = value.split(',');
        final b64 = parts.length > 1 ? parts[1] : '';
        final bytes = base64Decode(b64);
        return ClipOval(
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 70,
            height: 70,
          ),
        );
      } catch (_) {}
    }

    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      try {
        final bytes = base64Decode(value);
        return ClipOval(
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 70,
            height: 70,
          ),
        );
      } catch (_) {}
    }

    return ClipOval(
      child: Image.network(
        value,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 40),
      ),
    );
  }

  // Fungsi helper untuk Ikon Sosmed dengan InkWell
  Widget _socialIcon(dynamic icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            10,
          ),
            splashColor: Colors.blue.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FaIcon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
