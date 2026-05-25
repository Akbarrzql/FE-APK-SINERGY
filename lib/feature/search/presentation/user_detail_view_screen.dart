import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/feature/search/model/screen_model.dart';

class UserDetailViewScreen extends StatefulWidget {
  final User user;

  const UserDetailViewScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserDetailViewScreen> createState() => _UserDetailViewScreenState();
}

class _UserDetailViewScreenState extends State<UserDetailViewScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _institusiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.namaLengkap ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _institusiController = TextEditingController(text: widget.user.institusi ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _institusiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = widget.user.profilePicture?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: ColorValue.textPrimary,
          ),
        ),
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorValue.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorValue.borderColor,
                        width: 2,
                      ),
                    ),
                    child: profileImageUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          )
                        : ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Nama Lengkap Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                        hintStyle: const TextStyle(
                          color: ColorValue.textSecondary,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorValue.borderColor,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorValue.borderColor,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2F80ED),
                            width: 1.4,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Institusi Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Institusi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _institusiController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Masukkan institusi',
                        hintStyle: const TextStyle(
                          color: ColorValue.textSecondary,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorValue.borderColor,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorValue.borderColor,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2F80ED),
                            width: 1.4,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bio Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      readOnly: true,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Masukkan bio',
                        hintStyle: const TextStyle(
                          color: ColorValue.textSecondary,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorValue.borderColor,
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorValue.borderColor,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2F80ED),
                            width: 1.4,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorValue.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

