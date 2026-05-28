import 'package:flutter/material.dart';

class PortofolioAddScreen extends StatefulWidget {
  const PortofolioAddScreen({super.key});

  @override
  State<PortofolioAddScreen> createState() => _PortofolioAddScreenState();
}

class _PortofolioAddScreenState extends State<PortofolioAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fileUrlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menambahkan portofolio baru!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Portofolio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            // 👈 FIX: Typo 'cross CrossAxisAlignment' sudah diperbaiki di sini
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Area Banner Kosong + Stack Badge Profil Icon Orang
              Center(
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                      // Komponen Icon Orang Kosong
                      Positioned(
                        left: 20,
                        bottom: 15,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildInputLabel("Judul"),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: _buildInputDecoration("Masukkan judul portofolio"),
                validator: (value) => value == null || value.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              _buildInputLabel("Deksripsi"),
              TextFormField(
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: Color(0xFF555555), height: 1.5, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Tuliskan deskripsi proyek baru...',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              _buildInputLabel("Tautan Eksternal"),
              TextFormField(
                controller: _fileUrlController,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: _buildInputDecoration("https://github.com/..."),
                validator: (value) => value == null || value.isEmpty ? 'Tautan eksternal wajib diisi' : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // 👈 FIX: Blok 'bottomNavigationBar' sudah dihapus total agar bagian bawah bersih bersih bersih
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 2.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}