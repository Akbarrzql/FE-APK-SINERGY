import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // MENGATASI OVERFLOW: Gunakan SingleChildScrollView agar layar bisa di-scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMainStatsCard(),
            const SizedBox(height: 20),
            _buildBottomSummaryRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Durasi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "2h 20m",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_downward, color: Colors.blue, size: 24),
            ],
          ),
          Text(
            "Durasi waktu kerja kamu selama seminggu",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 30),

          // Grafik Batang (Chart)
          // Menggunakan FittedBox agar grafik mengecil otomatis jika layar sempit
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(40, "S"),
                _buildBar(70, "S"),
                _buildBar(30, "R"),
                _buildBar(80, "K"),
                _buildBar(75, "J"),
                _buildBar(50, "S"),
                _buildBar(65, "Today", isToday: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label, {bool isToday = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            height: height,
            width: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF1E6AF9),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallInfoCard(
            "Tugas Selesai",
            "20",
            Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSmallInfoCard("Tugas Saat ini", "8", Icons.assignment),
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E6AF9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Flexible(
            // Mencegah teks meluap (overflow) dalam row kecil
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
