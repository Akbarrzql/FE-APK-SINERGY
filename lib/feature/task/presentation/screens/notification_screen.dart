import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Melacak indeks kartu yang dipilih
  final Set<int> selectedIndices = {};

  // Hanya data "Inbox" (Selamat!)
  final List<Map<String, String>> inboxNotifications = [
    {'title': 'Selamat!', 'desc': 'Kamu mendapatkan 10 Poin Star'},
    {'title': 'Selamat!', 'desc': 'Kamu mendapatkan 10 Poin Star'},
    {'title': 'Selamat!', 'desc': 'Kamu mendapatkan 10 Poin Star'},
    {'title': 'Selamat!', 'desc': 'Kamu mendapatkan 10 Poin Star'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: inboxNotifications.length,
        itemBuilder: (context, index) {
          final item = inboxNotifications[index];
          bool isSelected = selectedIndices.contains(index);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedIndices.remove(index);
                } else {
                  selectedIndices.add(index);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE3F0FF) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFABC9F8)
                      : Colors.grey.shade300,
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Ikon Bintang Poin Star
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.stars,
                        color: Color(0xFFE9C46A),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Teks Notifikasi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['desc']!,
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
