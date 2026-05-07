import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
              Expanded(
                child: Column(
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
                    if (profile?.keahlian != null && profile!.keahlian.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: profile!.keahlian.map((skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Text(
                            skill,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        )).toList(),
                      )
                    else
                      Text(
                        '-',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
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
                _launchUrl(profile?.instagram, prefix: 'https://instagram.com/');
              }),
              _socialIcon(FontAwesomeIcons.linkedinIn, Colors.black, () {
                _launchUrl(profile?.linkedin, prefix: 'https://linkedin.com/in/');
              }),
              _socialIcon(FontAwesomeIcons.facebookF, Colors.black, () {
                _launchUrl(profile?.facebook, prefix: 'https://facebook.com/');
              }),
              _socialIcon(FontAwesomeIcons.whatsapp, Colors.black, () {
                _launchUrl(profile?.whatsapp, prefix: 'https://wa.me/');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String? value, {String prefix = ''}) async {
    if (value == null || value.isEmpty) return;
    
    Uri uri;
    if (value.startsWith('http')) {
      uri = Uri.parse(value);
    } else {
      // Remove @ if present (common for social handles)
      final cleanValue = value.startsWith('@') ? value.substring(1) : value;
      uri = Uri.parse('$prefix$cleanValue');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildProfileAvatar(String? source) {
    final imageUrl = source?.trim() ?? '';
    if (imageUrl.isEmpty) {
      return const Icon(Icons.person, color: Colors.white, size: 40);
    }

    if (imageUrl.startsWith('data:')) {
      try {
        final parts = imageUrl.split(',');
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

    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      try {
        final bytes = base64Decode(imageUrl);
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
        imageUrl,
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
      width: 40,
      height: 40,
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
          child: Center(child: FaIcon(icon, color: color, size: 20)),
        ),
      ),
    );
  }
}
