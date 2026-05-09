import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import halaman-halaman pendukung
import 'calendar_screen.dart';
import 'recap_screen.dart';
import 'activity_log_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Jumlah Tab: Date, Recap, Target
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(
                    0xFFDDEBFF,
                  ), // Warna biru muda sesuai desain
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: const Color.fromARGB(
                  255,
                  0,
                  0,
                  0,
                ), // Warna teks aktif
                unselectedLabelColor: Colors.black54,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Date'),
                  Tab(text: 'Recap'),
                  Tab(text: 'Activity Log'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            CalendarScreen(), // File calendar_screen.dart
            RecapScreen(), // File recap_screen.dart
            ActivityLogScreen(), // Placeholder
          ],
        ),
      ),
    );
  }
}
