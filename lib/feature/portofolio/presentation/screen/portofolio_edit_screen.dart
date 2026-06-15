import 'dart:io';

import 'package:gabungyuk/core/common/shared_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/portofolio_model.dart';
import '../../bloc/portofolio_bloc.dart';
import '../../bloc/portofolio_event.dart';
import '../../bloc/portofolio_state.dart';

class PortofolioEditScreen extends StatefulWidget {
  final Data portofolio;

  const PortofolioEditScreen({super.key, required this.portofolio});

  @override
  State<PortofolioEditScreen> createState() => _PortofolioEditScreenState();
}

class _PortofolioEditScreenState extends State<PortofolioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final SharedCode _sharedCode = SharedCode();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _fileUrlController;

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran gambar maksimal adalah 10MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.portofolio.title);
    _descriptionController = TextEditingController(text: widget.portofolio.description);
    _fileUrlController = TextEditingController(text: widget.portofolio.fileUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PortofolioBloc, PortofolioState>(
      listener: (context, state) {
        if (state is PortofolioActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is PortofolioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
            'Edit Portofolio',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<PortofolioBloc>().add(UpdatePortofolioEvent(
                        portfolioId: widget.portofolio.portfolioId!,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        fileUrl: _fileUrlController.text,
                        imagePath: _imagePath,
                      ));
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Simpan',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      image: _imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : (widget.portofolio.image != null && widget.portofolio.image!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.portofolio.image!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: _imagePath == null && (widget.portofolio.image == null || widget.portofolio.image!.isEmpty)
                        ? Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400])
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputLabel("Judul"),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: _buildInputDecoration("Masukkan judul portofolio"),
                  validator: _sharedCode.titleValidator,
                ),
                const SizedBox(height: 24),
                _buildInputLabel("Deskripsi"),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 8,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: _buildInputDecoration("Tuliskan deskripsi proyek..."),
                  validator: _sharedCode.descriptionValidator,
                ),
                const SizedBox(height: 24),
                _buildInputLabel("Tautan Proyek"),
                TextFormField(
                  controller: _fileUrlController,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: _buildInputDecoration("https://github.com/..."),
                  validator: _sharedCode.urlValidator,
                ),
                const SizedBox(height: 32),
                
                // Tombol Delete
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text("Hapus Portofolio", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        title: const Text("Hapus Portofolio"),
        content: const Text("Apakah Anda yakin ingin menghapus portofolio ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(innerContext);
              context.read<PortofolioBloc>().add(DeletePortofolioEvent(widget.portofolio.portfolioId!));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}
