import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/color_value.dart';
import '../../data/models/portofolio_model.dart';
import '../../bloc/portofolio_bloc.dart';
import 'portofolio_edit_screen.dart';

class PortofolioDetailScreen extends StatelessWidget {
  final Data portofolio;

  const PortofolioDetailScreen({super.key, required this.portofolio});

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
          'Detail Portofolio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Builder(builder: (context) {
            try {
              final bloc = context.read<PortofolioBloc>();
              return TextButton(
                child: const Text(
                  "Ubah", style: TextStyle(color: ColorValue.primaryColor)
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (innerContext) => BlocProvider.value(
                        value: bloc,
                        child: PortofolioEditScreen(portofolio: portofolio),
                      ),
                    ),
                  );
                },
              );
            } catch (_) {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                image: portofolio.image != null && portofolio.image!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(portofolio.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: portofolio.image == null || portofolio.image!.isEmpty
                  ? Icon(Icons.image, size: 50, color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              portofolio.title ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              "Deskripsi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              portofolio.description ?? '-',
              style: const TextStyle(fontSize: 15, color: Color(0xFF555555), height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              "Tautan Proyek",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Implement open URL if needed (url_launcher)
              },
              child: Text(
                portofolio.fileUrl ?? '-',
                style: const TextStyle(fontSize: 15, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
