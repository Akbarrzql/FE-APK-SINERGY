import 'package:flutter/material.dart';
import 'package:gabungyuk/core/common/api_exception.dart';
import 'package:gabungyuk/core/common/color_value.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:gabungyuk/feature/portofolio/data/models/portofolio_model.dart';
import 'package:gabungyuk/feature/portofolio/repositories/portofolio_repository.dart';
import 'package:gabungyuk/feature/portofolio/presentation/widget/portofolio_card.dart';
import 'package:gabungyuk/feature/portofolio/presentation/screen/portofolio_detail_screen.dart';

class UserDetailPortofolioSection extends StatefulWidget {
  final int userId;

  const UserDetailPortofolioSection({super.key, required this.userId});

  @override
  State<UserDetailPortofolioSection> createState() => _UserDetailPortofolioSectionState();
}

class _UserDetailPortofolioSectionState extends State<UserDetailPortofolioSection> {
  final PortofolioRepository _repository = PortofolioRepositoryImpl();
  late Future<PortofolioModel> _portofolioFuture;

  @override
  void initState() {
    super.initState();
    _portofolioFuture = _repository.fetchPortofolioByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Portofolio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorValue.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<PortofolioModel>(
          future: _portofolioFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmer();
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error);
            }

            final portfolios = snapshot.data?.data ?? [];

            if (portfolios.isEmpty) {
              return _buildEmpty();
            }

            return SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: portfolios.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = portfolios[index];
                  return SizedBox(
                    width: 160,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PortofolioDetailScreen(portofolio: item),
                          ),
                        );
                      },
                      child: PortofolioCard(portofolio: item),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => LoadingShimmer(
          height: 220,
          width: 160,
          borderRadius: 16,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'Belum ada portofolio',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object? error) {
    final message = error is ApiException ? error.message : 'Gagal memuat portofolio';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
