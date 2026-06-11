import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/core/common/auth_ui_helper.dart';
import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import '../../../../core/common/color_value.dart';
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';
import 'package:gabungyuk/feature/rating/bloc/rating_bloc.dart';
import 'package:gabungyuk/feature/rating/repository/rating_repository.dart';
import 'package:gabungyuk/feature/rating/presentation/rating_collaborators_dialog.dart';

// Model data kolaborasi yang akan diedit
class CollaborationData {
  final String? id;
  final String title;
  final String description;
  final List<String> category;
  final String status;
  final String repositoryLink;
  final String? imageUrl;
  final DateTime? deadline;

  const CollaborationData({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    this.imageUrl,
    this.deadline,
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
  final FocusNode _categoryFocusNode = FocusNode();
  final List<String> _selectedCategories = [];

  late String _selectedStatus;
  String? _newImagePath; // path lokal jika user ganti gambar
  late String? _existingImageUrl;
  DateTime? _selectedDeadline;

  final List<String> _statusOptions = [
    'Belum Dimulai',
    'Sedang Berjalan',
    'Selesai',
    'Project Berakhir',
    'Ditunda',
  ];

  // Dummy data untuk preview
  static const _dummy = CollaborationData(
    title: 'Moneyger Application Project',
    description:
    'Moneyger adalah sebuah platform aplikasi untuk mengelola keuangan dengan mudah. Aplikasi ini juga menawarkan berbagai fitur yang dapat membantu masyarakat mempermudah produktivitas mereka.',
    category: ['Portofolio project'],
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
    _categoryController = TextEditingController();
    _selectedCategories.addAll(data.category);
    _repoController = TextEditingController(text: data.repositoryLink);
    _selectedStatus = _mapBackendStatus(data.status);
    _existingImageUrl = data.imageUrl;
      _selectedDeadline = data.deadline;
    
    _categoryFocusNode.addListener(_handleCategoryFocusChange);
  }

  void _handleCategoryFocusChange() {
    if (!_categoryFocusNode.hasFocus) {
      _addCategory(_categoryController.text);
    }
  }

  String _mapBackendStatus(String? status) {
    if (status == null) return 'Belum Dimulai';
    if (_statusOptions.contains(status)) return status;

    switch (status.toUpperCase()) {
      case 'OPEN':
        return 'Sedang Berjalan';
      case 'COMPLETED':
        return 'Project Berakhir';
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
    _categoryFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 10) {
        if (mounted) {
          AuthUiHelper.showError(context, 'Ukuran gambar maksimal adalah 10MB');
        }
        return;
      }
      setState(() => _newImagePath = picked.path);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_categoryController.text.trim().isNotEmpty) {
      _addCategory(_categoryController.text);
    }

    if (_selectedCategories.isEmpty) {
      AuthUiHelper.showError(context, 'Kategori wajib diisi.');
      return;
    }

    final id = widget.initialData?.id;
    if (id == null) {
      // If no id provided, inform user and abort.
      AuthUiHelper.showError(context, 'ID kolaborasi tidak tersedia.');
      return;
    }

    final backendStatus = _mapToBackendStatus(_selectedStatus);

    // Determine previous backend status robustly: if initialData.status is
    // already a backend code (e.g. "COMPLETED") use it, otherwise map it.
    final prevStatusRaw = widget.initialData?.status ?? '';
    final prevBackendStatus = (prevStatusRaw.toUpperCase() == 'OPEN' ||
            prevStatusRaw.toUpperCase() == 'COMPLETED' ||
            prevStatusRaw.toUpperCase() == 'DONE' ||
            prevStatusRaw.toUpperCase() == 'HOLD' ||
            prevStatusRaw.toUpperCase() == 'NOT OPEN')
        ? prevStatusRaw.toUpperCase()
        : _mapToBackendStatus(prevStatusRaw);

    final isChangingToCompleted = (backendStatus == 'COMPLETED' || backendStatus == 'DONE') &&
        (prevBackendStatus != 'COMPLETED' && prevBackendStatus != 'DONE');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: ColorValue.primaryColor,
        ),
      ),
    );

    try {
      await CollaborationService().updateCollaboration(
        id: id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategories,
        status: backendStatus,
        oldStatus: prevBackendStatus,
        repositoryLink: _repoController.text.trim(),
        imagePath: _newImagePath,
        deadline: _selectedDeadline,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // remove loading

      // If status changed to COMPLETED, show rating dialog
      if (isChangingToCompleted) {
        // Fetch project details to get collaborators
        try {
          final projectDetail = await CollaborationService().getProjectDetail(int.parse(id));
          final collaborators = projectDetail.data.collaborators;

          if (!mounted) return;

          if (collaborators.isEmpty) {
            AuthUiHelper.showSuccess(context, 'Project berhasil selesaikan.');
            Navigator.of(context).pop(true);
          } else {
            // Convert collaborators to CollaboratorInfo
            final collaboratorInfos = collaborators
                .map((c) => CollaboratorInfo(
                  userId: c.idPengguna,
                  userName: c.namaLengkap,
                  profilePicture: c.profilePicture,
                  role: c.role,
                ))
                .toList();

            // Show rating dialog
            _showRatingDialog(collaboratorInfos, int.parse(id));
          }
        } catch (e) {
          if (!mounted) return;
          AuthUiHelper.showSuccess(context, 'Project berhasil selesaikan.');
          Navigator.of(context).pop(true);
        }
      } else {
        AuthUiHelper.showSuccess(context, 'Perubahan berhasil disimpan.');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      AuthUiHelper.showError(context, AuthUiHelper.readableError(e));
    }
  }

  void _showRatingDialog(
    List<CollaboratorInfo> collaborators,
    int projectId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider<RatingBloc>(
        create: (context) => RatingBloc(
          ratingRepository: RatingRepositoryImpl(),
        ),
        child: RatingCollaboratorsDialog(
          projectId: projectId,
          collaborators: collaborators,
          onComplete: () {
            AuthUiHelper.showSuccess(context, 'Project berhasil selesaikan.');
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }

  String _mapToBackendStatus(String label) {
    switch (label) {
      case 'Sedang Berjalan':
        return 'OPEN';
      case 'Selesai':
        // 'Selesai' corresponds to backend 'DONE'
        return 'DONE';
      case 'Project Berakhir':
        // 'Project Berakhir' is the state when project is completed by owner
        return 'COMPLETED';
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
      case 'Project Berakhir':
        return Colors.purple;
      case 'Ditunda':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  bool get _isStatusLocked => _selectedStatus == 'Project Berakhir';

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
                                  return const LoadingShimmer(
                                    width: double.infinity,
                                    height: double.infinity,
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
                                  color: Colors.black.withValues(alpha: 0.55),
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

                      const SizedBox(height: 16),

                       // Kategori
                       _buildLabel('Kategori'),
                      const SizedBox(height: 6),
                       _buildCategoryInput(),

                       const SizedBox(height: 16),

                       // Deadline
                       _buildLabel('Deadline (Opsional)'),
                       const SizedBox(height: 6),
                       _buildDeadlineField(),

                       const SizedBox(height: 16),

                       // Status
                       _buildLabel('Status'),
                       const SizedBox(height: 6),
                       _buildStatusDropdown(),

                       const SizedBox(height: 16),

                       // Repository Link (moved)

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

  Widget _buildCategoryInput() {
    final categories = SharedCode.itScopeCategories.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ..._selectedCategories.map(
                (cat) => Chip(
                  label: Text(cat),
                  onDeleted: () => setState(() => _selectedCategories.remove(cat)),
                  backgroundColor: ColorValue.primaryColor.withValues(alpha: 0.1),
                  deleteIcon: Icon(Icons.cancel, size: 16, color: ColorValue.primaryColor.withValues(alpha: 0.7)),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorValue.primaryColor,
                  ),
                ),
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: _categoryController,
                  focusNode: _categoryFocusNode,
                  style: const TextStyle(fontSize: 14, color: ColorValue.textPrimary),
                  decoration: InputDecoration(
                    hintText: _selectedCategories.isEmpty ? 'Ketik lalu tekan enter' : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && value.endsWith(',')) {
                      _addCategory(value.substring(0, value.length - 1));
                    }
                  },
                  onSubmitted: (value) {
                    _addCategory(value);
                    _categoryFocusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (!_selectedCategories.contains(cat)) _selectedCategories.add(cat);
                  } else {
                    _selectedCategories.remove(cat);
                  }
                });
              },
              selectedColor: ColorValue.primaryColor.withValues(alpha: 0.1),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? ColorValue.primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? ColorValue.primaryColor : Colors.grey[300]!,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addCategory(String value) {
    if (value.isEmpty) {
      _categoryController.clear();
      return;
    }

    // Mendukung input multiple via koma
    final parts = value.split(',');

    for (var part in parts) {
      final clean = part.trim();
      if (clean.isEmpty) continue;

      if (!SharedCode.isITSector(clean)) {
        AuthUiHelper.showError(context, 'Kategori "$clean" harus dalam lingkup IT');
        continue;
      }

      if (!_selectedCategories.contains(clean)) {
        setState(() => _selectedCategories.add(clean));
      }
    }
    _categoryController.clear();
  }

  Widget _buildStatusDropdown() {
    if (_isStatusLocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor(_selectedStatus),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedStatus,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorValue.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.lock_rounded, size: 18, color: Colors.grey),
          ],
        ),
      );
    }

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
              builder: (_) => const Center(
                child: CircularProgressIndicator(
                  color: ColorValue.primaryColor,
                ),
              ),
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

  Widget _buildDeadlineField() {
    return GestureDetector(
      onTap: _pickDeadline,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: ColorValue.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDeadline != null
                    ? 'Deadline: ${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                    : 'Pilih tanggal deadline',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedDeadline != null
                      ? ColorValue.textPrimary
                      : Colors.grey[500],
                ),
              ),
            ),
            if (_selectedDeadline != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDeadline = null),
                child: Icon(Icons.close_rounded, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }
}
