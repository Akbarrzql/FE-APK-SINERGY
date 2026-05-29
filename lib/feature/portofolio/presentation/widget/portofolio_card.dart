import 'package:flutter/material.dart';
import '../../data/models/portofolio_model.dart';

class PortofolioCard extends StatelessWidget {
  final Data portofolio;

  const PortofolioCard({super.key, required this.portofolio});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render Gambar Thumbnail Cover Proyek
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: portofolio.image != null && portofolio.image!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(portofolio.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: portofolio.image == null || portofolio.image!.isEmpty
                  ? const Center(child: Icon(Icons.image, color: Colors.grey))
                  : null,
            ),
          ),
          // Render Teks Konten Proyek
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portofolio.title ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  portofolio.description ?? '-',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
