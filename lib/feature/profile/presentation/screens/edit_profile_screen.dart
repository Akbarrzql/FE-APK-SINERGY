import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/permission_handler.dart' as perm_helper;
import 'package:gabungyuk/feature/profile/bloc/profile_bloc.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel? profile;
  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _institusiController;
  late final TextEditingController _bioController;
  late final TextEditingController _keahlianController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _whatsappController;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImageFile; // stores the picked image file
  bool _imageRemoved = false; // flag to indicate if user explicitly removed the image

  final ProfileRepositoryImpl _repo = ProfileRepositoryImpl();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p?.namaLengkap ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _institusiController = TextEditingController(text: p?.institusi?.toString() ?? '');
    _bioController = TextEditingController(text: p?.bio?.toString() ?? '');
    _keahlianController = TextEditingController(text: p?.keahlian?.toString() ?? '');
    _lokasiController = TextEditingController(text: p?.lokasi?.toString() ?? '');
    _whatsappController = TextEditingController(text: p?.whatsapp?.toString() ?? '');
    // If existing profile picture is a data URI, keep it available (do not decode now)
    // _pickedImageDataUri stays null unless user picks a new image or removes it
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _institusiController.dispose();
    _bioController.dispose();
    _keahlianController.dispose();
    _lokasiController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Build body with only changed fields to avoid sending empty/unnecessary values
    final body = <String, dynamic>{};
    final p = widget.profile;
    final nameVal = _nameController.text.trim();
    if (nameVal != (p?.namaLengkap ?? '')) body['namaLengkap'] = nameVal;

    final emailVal = _emailController.text.trim();
    if (emailVal != (p?.email ?? '')) body['email'] = emailVal;

    final institusiVal = _institusiController.text.trim();
    if (institusiVal != (p?.institusi?.toString() ?? '')) body['institusi'] = institusiVal;

    final bioVal = _bioController.text.trim();
    if (bioVal != (p?.bio?.toString() ?? '')) body['bio'] = bioVal;

    final keahlianVal = _keahlianController.text.trim();
    if (keahlianVal != (p?.keahlian?.toString() ?? '')) body['keahlian'] = keahlianVal;

    final lokasiVal = _lokasiController.text.trim();
    if (lokasiVal != (p?.lokasi?.toString() ?? '')) body['lokasi'] = lokasiVal;

    final whatsappVal = _whatsappController.text.trim();
    if (whatsappVal != (p?.whatsapp?.toString() ?? '')) body['whatsapp'] = whatsappVal;

    // If user explicitly removed image, send empty string to backend
    if (_imageRemoved) {
      body['profilePicture'] = '';
    }

    try {
      // Get File object if image was picked (or null if no image)
      File? imageFileToUpload;
      if (_pickedImageFile != null) {
        imageFileToUpload = File(_pickedImageFile!.path);
      }

      final res = await _repo.updateProfile(body, profileImageFile: imageFileToUpload);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 3),
        ),
      );

      // trigger reload of profile
      try {
        context.read<ProfileBloc>().add(LoadProfile());
      } catch (_) {}

      // Notify previous screen that update happened
      Navigator.of(context).pop(true);
    } catch (e) {
      String msg = 'Terjadi kesalahan. Silakan coba lagi.';
      if (e is ApiException) msg = e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

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
            onPressed: _onSave,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.blue.shade100,
                      child: _buildProfileAvatarContent(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceActionSheet,
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildLabel('Nama Lengkap'),
              _buildTextField(_nameController, 'Nama Lengkap'),

              _buildLabel('Email'),
              _buildTextField(_emailController, 'Email', enabled: false),

              _buildLabel('Institusi'),
              _buildTextField(_institusiController, 'Institusi'),

              _buildLabel('Bio'),
              _buildTextField(_bioController, 'Bio', isBio: true),

              _buildLabel('Keahlian'),
              _buildTextField(_keahlianController, 'Keahlian'),
              const SizedBox(height: 20),

              _buildLabel('Lokasi'),
              _buildTextField(_lokasiController, 'Lokasi'),
              const SizedBox(height: 12),

              _buildLabel('WhatsApp'),
              _buildTextField(_whatsappController, 'WhatsApp'),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatarContent() {
    // If user picked a new image file, show it from disk
    if (_pickedImageFile != null && !_imageRemoved) {
      try {
        final file = File(_pickedImageFile!.path);
        return ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: 110,
            height: 110,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 48),
          ),
        );
      } catch (_) {
        // fallthrough
      }
    }

    // If user removed image, show placeholder
    if (_imageRemoved || widget.profile == null || widget.profile!.profilePicture.isEmpty) {
      return const Icon(Icons.person, size: 48, color: Colors.white);
    }

    // Show existing profile picture from server
    final existing = widget.profile?.profilePicture;
    if (existing != null && existing.isNotEmpty) {
      final str = existing.toString();

      // If it's a data URI (data:image/...), decode and show from memory
      if (str.startsWith('data:')) {
        try {
          final parts = str.split(',');
          final b64 = parts.length > 1 ? parts[1] : '';
          final bytes = base64Decode(b64);
          return ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: 110,
              height: 110,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 48),
            ),
          );
        } catch (_) {
          // if decode fails, fall back to network below
        }
      }

      // If it's raw base64, try to decode and show from memory
      if (!str.startsWith('http://') && !str.startsWith('https://')) {
        try {
          final bytes = base64Decode(str);
          return ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: 110,
              height: 110,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 48),
            ),
          );
        } catch (_) {
          // fall through to network/placeholder
        }
      }

      // Otherwise assume it's a URL and load via network
      return ClipOval(
        child: Image.network(
          str,
          fit: BoxFit.cover,
          width: 110,
          height: 110,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 48),
        ),
      );
    }

    return const Icon(Icons.person, size: 48, color: Colors.white);
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              if (_pickedImageFile != null || widget.profile?.profilePicture != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _pickedImageFile = null;
                      _imageRemoved = true;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // iOS gallery can be opened directly via image_picker (no permission prompt needed)
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 1200);
      if (picked == null) return;

      setState(() {
        _pickedImageFile = picked;
        _imageRemoved = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // Request permission first
      final status = await perm_helper.PermissionHandlerHelper.requestCameraWithStatus();

      if (status.isDenied) {
        _showPermissionDeniedDialog('Kamera', 'Izin akses kamera ditolak.');
        return;
      } else if (status.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog('Kamera');
        return;
      }

      // Pick image from camera
      final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75, maxWidth: 1200);
      if (picked == null) return;

      setState(() {
        _pickedImageFile = picked;
        _imageRemoved = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _showPermissionDeniedDialog(String permissionName, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Izin Diperlukan'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionPermanentlyDeniedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Izin Ditolak Secara Permanen'),
          content: Text('Izin akses $permissionName ditolak secara permanen. Silakan buka Pengaturan untuk mengubahnya.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                perm_helper.PermissionHandlerHelper.openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
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
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isBio = false, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      maxLines: isBio ? 4 : 1,
      enabled: enabled,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
      validator: (v) {
        if (label == 'Nama Lengkap' && (v == null || v.trim().isEmpty)) {
          return 'Masukkan $label';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: controller.text.isEmpty ? 'Masukkan $label' : null,
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

  // Keahlian chip helper removed (not used)
}


