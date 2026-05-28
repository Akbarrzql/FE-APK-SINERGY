import 'dart:convert';
import '../models/portofolio_model.dart';

abstract class PortofolioRepository {
  Future<List<PortofolioModel>> fetchPortofolio();
}

class PortofolioRepositoryImpl implements PortofolioRepository {
  @override
  Future<List<PortofolioModel>> fetchPortofolio() async {
    // 1. Kita buat efek animasi loading palsu selama 1.5 detik biar realistis
    await Future.delayed(const Duration(milliseconds: 1500));

    // 2. Ini dia STRING JSON DUMMY yang kita sesuaikan 100% dengan skema Apidog kamu
    const String jsonDummyRaw = '''
    [
      {
        "id": "1",
        "title": "APK SYNERGY",
        "description": "Aplikasi Kolaborasi antar mahasiswa berbasis mobile untuk mempermudah pengerjaan proyek tim dan integrasi tugas.",
        "fileUrl": "https://github.com/contoh/APKSYNERGY",
        "image": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=500"
      },
      {
        "id": "2",
        "title": "MountOne Ecosystem",
        "description": "Platform ekosistem terintegrasi untuk layanan pemanduan, penyewaan alat, dan informasi pendakian gunung di Jawa Barat.",
        "fileUrl": "https://github.com/contoh/MountOne",
        "image": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=500"
      },
      {
        "id": "3",
        "title": "KampusNav Navigation",
        "description": "Sistem navigasi interaktif denah ruangan dalam kampus menggunakan pemetaan tata letak gedung secara real-time.",
        "fileUrl": "https://github.com/contoh/KampusNav",
        "image": "https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=500"
      },
      {
        "id": "4",
        "title": "Kashier Mobile App",
        "description": "Aplikasi kasir digital berbasis Kotlin untuk pencatatan transaksi UMKM dengan sinkronisasi database lokal.",
        "fileUrl": "https://github.com/contoh/Kashier",
        "image": "https://images.unsplash.com/photo-1556742044-3c52d6e88c62?q=80&w=500"
      }
    ]
    ''';

    // 3. Masukkan string jsonDummy ke fungsi parser model yang kemarin sudah kita buat
    return portofolioModelFromJson(jsonDummyRaw);
  }
}