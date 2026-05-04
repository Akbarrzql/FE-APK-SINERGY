import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/common/color_value.dart';

class CreateCollaborationPage extends StatefulWidget {
  const CreateCollaborationPage({super.key});

  @override
  State<CreateCollaborationPage> createState() =>
      _CreateCollaborationPageState();
}

class _CreateCollaborationPageState extends State<CreateCollaborationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _repoController = TextEditingController();
  final _urlController = TextEditingController();

  String _selectedStatus = 'Belum Dimulai';
  String? _imagePath; // ganti dengan File jika pakai image_picker

  final List<String> _statusOptions = [
    'Belum Dimulai',
    'Sedang Berjalan',
    'Selesai',
    'Ditunda',
  ];

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
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: kirim data ke backend
      Navigator.pop(context);
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
                          'Buat Kolaborasi',
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

              // ── Cover Image Picker ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _imagePath != null
                          ? Image.asset(
                        _imagePath!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Tambah Gambar Cover',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
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
                      _buildTextField(
                        controller: _titleController,
                        hint: 'Judul Kolaborasi',
                        validator: (v) =>
                        (v == null || v.isEmpty) ? 'Judul wajib diisi' : null,
                        isBorderless: true,
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 20),

                      // Deskripsi
                      _buildLabel('Deksripsi'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _descController,
                        hint: 'Tambahkan Deksripsi',
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

                      // Submit button
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
                            'Buat Kolaborasi',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ColorValue.textSecondary,
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
    bool isBorderless = false,
  }) {
    if (isBorderless) {
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

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: ColorValue.textPrimary,
      ),
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
          style: const TextStyle(
            fontSize: 14,
            color: ColorValue.textPrimary,
          ),
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