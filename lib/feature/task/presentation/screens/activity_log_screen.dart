import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10, // Contoh jumlah log
        itemBuilder: (context, index) {
          return _buildLogItem();
        },
      ),
    );
  }

  Widget _buildLogItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Color(0xFF1E6AF9)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Update Task #30",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Kamu baru saja menyelesaikan tugas ini",
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "10:00",
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
