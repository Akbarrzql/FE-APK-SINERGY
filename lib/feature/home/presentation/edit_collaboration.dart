import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/common/color_value.dart';

// Model data kolaborasi yang akan diedit
class CollaborationData {
  final String title;
  final String description;
  final String category;
  final String status;
  final String repositoryLink;
  final String url;
  final String? imageUrl;

  const CollaborationData({
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.repositoryLink,
    required this.url,
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
  late final TextEditingController _urlController;

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
    url: 'https://moneyger.app',
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
    _urlController = TextEditingController(text: data.url);
    _selectedStatus = data.status;
    _existingImageUrl = data.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _repoController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // TODO: implementasi image_picker
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newImagePath = picked.path);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: kirim data update ke backend
      Navigator.pop(context);
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
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _newImagePath != null
                              ? Image.asset(
                            _newImagePath!,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : _existingImageUrl != null
                              ? Image.network(
                            _existingImageUrl!,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null)
                                return child;
                              return Container(
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: ColorValue.primaryColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              height: 220,
                              color: Colors.grey[200],
                              child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 48),
                            ),
                          )
                              : Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(
                                    Icons
                                        .add_photo_alternate_outlined,
                                    size: 48,
                                    color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Tambah Gambar Cover',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ),

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
                      ),

                      const SizedBox(height: 16),

                      // Kategori
                      _buildLabel('Kategori'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _categoryController,
                        hint: 'Tambahkan Kategori',
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
                      ),

                      const SizedBox(height: 16),

                      // URL
                      _buildLabel('URL Project'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _urlController,
                        hint: 'https://...',
                        keyboardType: TextInputType.url,
                        prefixIcon: Icons.link_rounded,
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Kolaborasi?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ColorValue.textPrimary,
          ),
        ),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              // TODO: delete API call
              Navigator.pop(context); // kembali ke list
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}