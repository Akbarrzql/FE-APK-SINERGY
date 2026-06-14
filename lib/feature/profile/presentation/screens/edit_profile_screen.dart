import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gabungyuk/core/common/app_ui_helper.dart';
import 'package:gabungyuk/core/widget/profile_avatar.dart';
import 'package:gabungyuk/feature/profile/model/profile_model.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/permission_handler.dart' as perm_helper;
import 'package:gabungyuk/feature/profile/bloc/profile_bloc.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/feature/profile/bloc/profile_state.dart';
import 'package:gabungyuk/core/common/color_value.dart';

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
  late final TextEditingController _instagramController;
  late final TextEditingController _facebookController;
  late final TextEditingController _linkedinController;
  final FocusNode _keahlianFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImageFile; // stores the picked image file
  bool _imageRemoved = false; // flag to indicate if user explicitly removed the image
  List<String> _keahlianList = [];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p?.namaLengkap ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _institusiController = TextEditingController(text: p?.institusi?.toString() ?? '');
    _bioController = TextEditingController(text: p?.bio?.toString() ?? '');
    _keahlianController = TextEditingController();
    _keahlianList = List<String>.from(p?.keahlian ?? []);
    _lokasiController = TextEditingController(text: p?.lokasi?.toString() ?? '');
    _whatsappController = TextEditingController(text: p?.whatsapp?.toString() ?? '');
    _instagramController = TextEditingController(text: p?.instagram?.toString() ?? '');
    _facebookController = TextEditingController(text: p?.facebook?.toString() ?? '');
    _linkedinController = TextEditingController(text: p?.linkedin?.toString() ?? '');
    
    _keahlianFocusNode.addListener(_handleKeahlianFocusChange);
  }

  void _handleKeahlianFocusChange() {
    if (!_keahlianFocusNode.hasFocus) {
      _addKeahlian(_keahlianController.text);
    }
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
    _instagramController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    _keahlianFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    // Tambahkan teks yang tersisa di input keahlian jika ada
    if (_keahlianController.text.trim().isNotEmpty) {
      _addKeahlian(_keahlianController.text);
    }

    if (!_formKey.currentState!.validate()) return;

    final body = <String, dynamic>{};
    final p = widget.profile;
    
    final nameVal = _nameController.text.trim();
    if (nameVal != (p?.namaLengkap ?? '')) body['namaLengkap'] = nameVal;

    final emailVal = _emailController.text.trim();
    if (emailVal != (p?.email ?? '')) body['email'] = emailVal;

    final institusiVal = _institusiController.text.trim();
    if (institusiVal != (p?.institusi?.toString() ?? '')) body['institusi'] = institusiVal;

    final bioVal = _bioController.text.trim();
    if (bioVal != (p?.bio ?? '')) body['bio'] = bioVal;

    // Keahlian logic using list
    final currentKeahlian = p?.keahlian ?? [];
    bool listChanged = _keahlianList.length != currentKeahlian.length;
    if (!listChanged) {
      for (int i = 0; i < _keahlianList.length; i++) {
        if (_keahlianList[i] != currentKeahlian[i]) {
          listChanged = true;
          break;
        }
      }
    }
    if (listChanged) {
      body['keahlian'] = _keahlianList;
    }

    final lokasiVal = _lokasiController.text.trim();
    if (lokasiVal != (p?.lokasi?.toString() ?? '')) body['lokasi'] = lokasiVal;

    final whatsappVal = _whatsappController.text.trim();
    if (whatsappVal != (p?.whatsapp?.toString() ?? '')) body['whatsapp'] = whatsappVal;

    final instagramVal = _instagramController.text.trim();
    if (instagramVal != (p?.instagram?.toString() ?? '')) body['instagram'] = instagramVal;

    final facebookVal = _facebookController.text.trim();
    if (facebookVal != (p?.facebook?.toString() ?? '')) body['facebook'] = facebookVal;

    final linkedinVal = _linkedinController.text.trim();
    if (linkedinVal != (p?.linkedin?.toString() ?? '')) body['linkedin'] = linkedinVal;

    if (_imageRemoved) {
      body['profilePicture'] = '';
    }

    File? imageFileToUpload;
    if (_pickedImageFile != null) {
      imageFileToUpload = File(_pickedImageFile!.path);
    }

    context.read<ProfileBloc>().add(
          UpdateProfile(body: body, profileImageFile: imageFileToUpload),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          AppUiHelper.showSuccess(context, state.message);
          Navigator.of(context).pop(true);
        } else if (state is ProfileError) {
          AppUiHelper.showError(context, state.message);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (context.read<ProfileBloc>().state is ProfileUpdateSuccess) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Jika state terakhir adalah sukses, beri tahu layar sebelumnya untuk refresh
              if (context.read<ProfileBloc>().state is ProfileUpdateSuccess) {
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context);
              }
            },
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
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileUpdating) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorValue.primaryColor),
                        ),
                      ),
                    ),
                  );
                }
                return TextButton(
                  onPressed: _onSave,
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.poppins(
                      color: ColorValue.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
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
                _buildKeahlianInput(),
                const SizedBox(height: 20),
                _buildLabel('Lokasi'),
                _buildTextField(_lokasiController, 'Lokasi'),
                const SizedBox(height: 12),
                _buildLabel('WhatsApp'),
                _buildTextField(_whatsappController, 'WhatsApp'),
                _buildLabel('Instagram'),
                _buildTextField(_instagramController, 'Instagram'),
                _buildLabel('Facebook'),
                _buildTextField(_facebookController, 'Facebook'),
                _buildLabel('LinkedIn'),
                _buildTextField(_linkedinController, 'LinkedIn'),
                const SizedBox(height: 30),
              ],
            ),
          ),
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

    // If user removed image, show placeholder with initials
    if (_imageRemoved || widget.profile == null || widget.profile!.profilePicture.isEmpty) {
      return ProfileAvatar(
        fullName: widget.profile?.namaLengkap,
        size: 110,
        fontSize: 32,
      );
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
    AppUiHelper.showAppBottomSheet(
      context: context,
      title: 'Pilih Foto Profil',
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // Perkecil ukuran gambar dan kualitas agar Base64 tidak terlalu besar (Penyebab umum Error 500)
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, 
        maxWidth: 800,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 10) {
        if (mounted) {
          AppUiHelper.showError(context, 'Ukuran gambar maksimal adalah 10MB');
        }
        return;
      }

      setState(() {
        _pickedImageFile = picked;
        _imageRemoved = false;
      });
    } catch (e) {
      AppUiHelper.showError(
        context,
        AppUiHelper.readableError(
          e,
          fallback: 'Gagal memilih gambar. Silakan coba lagi.',
        ),
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

      // Pick image from camera dengan optimasi ukuran
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 800,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 10) {
        if (mounted) {
          AppUiHelper.showError(context, 'Ukuran gambar maksimal adalah 10MB');
        }
        return;
      }

      setState(() {
        _pickedImageFile = picked;
        _imageRemoved = false;
      });
    } catch (e) {
      AppUiHelper.showError(
        context,
        AppUiHelper.readableError(
          e,
          fallback: 'Gagal mengambil gambar. Silakan coba lagi.',
        ),
      );
    }
  }

  void _showPermissionDeniedDialog(String permissionName, String message) {
    AppUiHelper.showAppDialog(
      context: context,
      title: 'Izin Diperlukan',
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Color(0xFF555555),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  void _showPermissionPermanentlyDeniedDialog(String permissionName) {
    AppUiHelper.showAppDialog(
      context: context,
      title: 'Izin Ditolak Secara Permanen',
      content: Text(
        'Izin akses $permissionName ditolak secara permanen. Silakan buka Pengaturan untuk mengubahnya.',
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Color(0xFF555555),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            perm_helper.PermissionHandlerHelper.openAppSettings();
          },
          child: const Text('Buka Pengaturan'),
        ),
      ],
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

  Widget _buildKeahlianInput() {
    return GestureDetector(
      onTap: () => _keahlianFocusNode.requestFocus(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ..._keahlianList.map((skill) => Chip(
                  label: Text(
                    skill,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  onDeleted: () {
                    setState(() {
                      _keahlianList.remove(skill);
                    });
                  },
                  backgroundColor: Colors.blue.shade50,
                  deleteIcon: Icon(Icons.cancel, size: 16, color: Colors.blue.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    // borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )),
            IntrinsicWidth(
              child: TextField(
                controller: _keahlianController,
                focusNode: _keahlianFocusNode,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _keahlianList.isEmpty ? 'Contoh: Flutter, UI/UX' : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && val.endsWith(',')) {
                    _addKeahlian(val.substring(0, val.length - 1));
                  }
                },
                onSubmitted: (val) {
                  _addKeahlian(val);
                  _keahlianFocusNode.requestFocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addKeahlian(String val) {
    if (val.isEmpty) {
      _keahlianController.clear();
      return;
    }

    // Mendukung input multiple via koma
    final parts = val.split(',');

    for (var part in parts) {
      final clean = part.trim();
      if (clean.isEmpty) continue;

      if (!SharedCode.isITSector(clean)) {
        AppUiHelper.showError(context, 'Keahlian "$clean" harus dalam lingkup IT');
        continue;
      }

      if (!_keahlianList.contains(clean)) {
        setState(() {
          _keahlianList.add(clean);
        });
      }
    }
    _keahlianController.clear();
  }

  // Helper untuk TextField agar bentuknya rapi dan konsisten
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isBio = false, bool enabled = true}) {
    final sharedCode = SharedCode();
    return TextFormField(
      controller: controller,
      maxLines: isBio ? 4 : 1,
      enabled: enabled,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
      validator: (v) {
        if (label == 'Nama Lengkap') {
          return sharedCode.nameValidator(v);
        }
        if (['WhatsApp', 'Instagram', 'Facebook', 'LinkedIn'].contains(label) &&
            v != null &&
            v.isNotEmpty) {
          return sharedCode.urlValidator(v);
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


