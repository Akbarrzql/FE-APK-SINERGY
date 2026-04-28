import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_card_widget.dart';
// 1. Tambahkan import file edit profile di sini
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const ProfileHeader(),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        StatCard(
                          title: 'Kolaborasi Anda',
                          icon: Icons.groups_rounded,
                          onTap: () {
                            debugPrint("Pindah ke halaman Kolaborasi");
                          },
                        ),
                        const SizedBox(width: 15),
                        StatCard(
                          title: 'Portofolio Anda',
                          icon: Icons.grid_view_rounded,
                          onTap: () {
                            debugPrint("Pindah ke halaman Portofolio");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(height: 8, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 2. Navigasi ke EditProfileScreen ditambahkan di sini
                    _menuItem(Icons.person_outline, 'Informasi pribadi', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 2),
                    _menuItem(Icons.lock_open_rounded, 'Reset Password', () {
                      debugPrint("Membuka Reset Password");
                    }),
                    const SizedBox(height: 2),
                    _menuItem(Icons.logout, 'Keluar', () {
                      debugPrint("Proses Logout...");
                    }, isLogout: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          debugPrint("Navigasi ke indeks: $index");
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            label: 'Collab',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers_outlined),
            label: 'Project',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    Color themeColor = isLogout ? Colors.red : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isLogout ? Colors.red.shade400 : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: themeColor, size: 22),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: themeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? Colors.red : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
