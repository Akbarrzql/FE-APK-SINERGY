import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import '../../../../core/common/color_value.dart';
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';

// Model data kolaborasi yang akan diedit
class CollaborationData {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String repositoryLink;
  final String? imageUrl;

  const CollaborationData({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    this.imageUrl,
  });
}

class EditCollaborationPage extends StatefulWidget {
  final CollaborationData? initialData; // null = dummy data

  const EditCollaborationPage({super.key, this.initialData});

  @override
  State<EditCollaborationPage> createState() => _EditCollaborationPageState();
}

class _EditCollaborationPageState extends State<EditCollaborationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _categoryController;
  late final TextEditingController _repoController;

  late String _selectedStatus;
  String? _newImagePath; // path lokal jika user ganti gambar
  late String? _existingImageUrl;

  final List<String> _statusOptions = [
    'Belum Dimulai',
    'Sedang Berjalan',
    'Selesai',
    'Ditunda',
  ];

  // Dummy data untuk preview
  static const _dummy = CollaborationData(
    title: 'Moneyger Application Project',
    description:
    'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah. Aplikasi ini juga menawarkan berbagai fitur yang dapat membantu masyarakat mempermudah produktivitas mereka.',
    category: 'Portofolio project',
    status: 'Sedang Berjalan',
    repositoryLink: 'https://github.com/example/moneyger',
    imageUrl:
    'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80',
  );

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? _dummy;
    _titleController = TextEditingController(text: data.title);
    _descController = TextEditingController(text: data.description);
    _categoryController = TextEditingController(text: data.category);
    _repoController = TextEditingController(text: data.repositoryLink);
    _selectedStatus = _mapBackendStatus(data.status);
    _existingImageUrl = data.imageUrl;
  }

  String _mapBackendStatus(String? status) {
    if (status == null) return 'Belum Dimulai';
    if (_statusOptions.contains(status)) return status;

    switch (status.toUpperCase()) {
      case 'OPEN':
        return 'Sedang Berjalan';
      case 'DONE':
        return 'Selesai';
      case 'HOLD':
        return 'Ditunda';
      case 'NOT OPEN':
        return 'Belum Dimulai';
      default:
        return 'Belum Dimulai';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _repoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newImagePath = picked.path);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final id = widget.initialData?.id;
    if (id == null) {
      // If no id provided, inform user and abort.
      AuthUiHelper.showError(context, 'ID kolaborasi tidak tersedia.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await CollaborationService().updateCollaboration(
        id: id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _categoryController.text.trim(),
        status: _mapToBackendStatus(_selectedStatus),
        repositoryLink: _repoController.text.trim(),
        imagePath: _newImagePath,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // remove loading
      AuthUiHelper.showSuccess(context, 'Perubahan berhasil disimpan.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      AuthUiHelper.showError(context, AuthUiHelper.readableError(e));
    }
  }

  String _mapToBackendStatus(String label) {
    switch (label) {
      case 'Sedang Berjalan':
        return 'OPEN';
      case 'Selesai':
        return 'DONE';
      case 'Ditunda':
        return 'HOLD';
      case 'Belum Dimulai':
        return 'NOT OPEN';
      default:
        return 'NOT OPEN';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Sedang Berjalan':
        return Colors.green;
      case 'Selesai':
        return Colors.blue;
      case 'Ditunda':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValue.backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: ColorValue.textPrimary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Edit Kolaborasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorValue.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Cover Image ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_newImagePath != null)
                              Image.file(
                                File(_newImagePath!),
                                fit: BoxFit.cover,
                              )
                            else if (_existingImageUrl != null &&
                                _existingImageUrl!.isNotEmpty &&
                                _existingImageUrl!.startsWith('http'))
                              Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: ColorValue.primaryColor,
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => _buildPlaceholderContent(),
                              )
                            else
                              _buildPlaceholderContent(),

                            // Edit overlay
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        size: 14, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Ganti Foto',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Form Fields ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      _buildLabel('Judul'),
                      const SizedBox(height: 6),
                      _buildBorderlessField(
                        controller: _titleController,
                        hint: 'Judul Kolaborasi',
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Judul wajib diisi'
                            : null,
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 20),

                      // Deskripsi
                      _buildLabel('Deskripsi'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _descController,
                        hint: 'Tambahkan Deskripsi',
                        maxLines: 4,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Deskripsi wajib diisi'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Kategori
                      _buildLabel('Kategori'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _categoryController,
                        hint: 'Tambahkan Kategori',
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Kategori wajib diisi'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Status
                      _buildLabel('Status'),
                      const SizedBox(height: 6),
                      _buildStatusDropdown(),

                      const SizedBox(height: 16),

                      // Repository Link
                      _buildLabel('Repository Link'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _repoController,
                        hint: 'https://github.com/...',
                        keyboardType: TextInputType.url,
                        prefixIcon: Icons.code_rounded,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Link repository wajib diisi'
                            : null,
                      ),

                      const SizedBox(height: 32),

                      // Simpan button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorValue.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Hapus button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => _showDeleteDialog(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(
                                color: Color(0xFFFFDDDD), width: 1.5),
                            backgroundColor: const Color(0xFFFFF5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Hapus Kolaborasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: ColorValue.textSecondary,
    ),
  );

  Widget _buildBorderlessField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ColorValue.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.grey[300],
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: ColorValue.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: Colors.grey[400])
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: ColorValue.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: ColorValue.primaryColor),
          style: const TextStyle(fontSize: 14, color: ColorValue.textPrimary),
          items: _statusOptions.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor(s),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(s),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedStatus = v);
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    AuthUiHelper.showAppDialog(
      context: context,
      title: 'Hapus Kolaborasi?',
      barrierDismissible: false,
      content: const Text(
        'Kolaborasi ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
        style: TextStyle(
          fontSize: 14,
          color: ColorValue.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Batal',
            style: TextStyle(
              color: ColorValue.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final id = widget.initialData?.id;
            if (id == null) {
              AuthUiHelper.showError(context, 'ID kolaborasi tidak tersedia.');
              return;
            }

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              await CollaborationService().deleteCollaboration(id: id);
              if (!mounted) return;
              Navigator.of(context).pop(); // remove loading
              Navigator.of(context).pop(true); // close editor and signal deletion
              AuthUiHelper.showSuccess(context, 'Kolaborasi berhasil dihapus.');
            } catch (e) {
              if (!mounted) return;
              Navigator.of(context).pop();
              AuthUiHelper.showError(context, AuthUiHelper.readableError(e));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            'Hapus',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderContent() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Pilih Foto Sampul',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
