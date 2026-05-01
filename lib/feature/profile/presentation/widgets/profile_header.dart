import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Magnus Carlsen',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Android Developer',
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
            'Saya adalah seorang Mobile Developer dengan pengalaman luas dalam berkolaborasi bersama tim pengembang aplikasi mobile. Selama karier saya, saya telah bekerja erat dengan tim front-end, desainer, serta manajer produk untuk membangun dan mengintegrasikan API yang efisien dan skalabel ke dalam aplikasi mobile.',
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

  // Fungsi helper untuk Ikon Sosmed dengan InkWell
  Widget _socialIcon(dynamic icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent, // Menjaga background tetap transparan
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            10,
          ), // Efek ripple mengikuti bentuk kotak
          splashColor: Colors.blue.withOpacity(
            0.1,
          ), // Opsional: warna saat ditekan
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FaIcon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
