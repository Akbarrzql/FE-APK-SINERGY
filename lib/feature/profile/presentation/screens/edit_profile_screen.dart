import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Kembali ke Profile
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Munculkan Snack Bar seperti di gambar kamu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile Berhasil Diperbarui'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // --- BAGIAN FOTO PROFIL ---
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage('https://pravatar.cc'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- INPUT FIELDS ---
            _buildLabel('Nama Lengkap'),
            _buildTextField('Magnus Carlsen'),

            _buildLabel('Email'),
            _buildTextField('magnuscarlsen@gmail.com'),

            _buildLabel('Institusi'),
            _buildTextField('Telkom University'),

            _buildLabel('Bio'),
            _buildTextField(
              'Saya adalah seorang Mobile Dev dengan pengalaman berkolaborasi selama ini',
              isBio: true,
            ),

            // --- BAGIAN KEAHLIAN ---
            _buildLabel('Keahlian'),
            Row(
              children: [
                _buildChip('Mobile Front End'),
                const SizedBox(width: 10),
                _buildChip('Back End'),
              ],
            ),
            const SizedBox(height: 20),

            _buildLabel('Posisi Saat Ini'),
            _buildTextField('Telkom University'),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  // Helper untuk TextField agar bentuknya rapi dan konsisten
  Widget _buildTextField(String initialValue, {bool isBio = false}) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: isBio ? 4 : 1,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  // Helper untuk Chip Keahlian
  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.blue.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
