import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/feature/portofolio/bloc/portofolio_bloc.dart';
import 'package:gabungyuk/feature/portofolio/bloc/portofolio_event.dart';
import 'package:gabungyuk/feature/portofolio/bloc/portofolio_state.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import '../../repositories/portofolio_repository.dart';
import '../widget/portofolio_card.dart';
import 'package:gabungyuk/feature/portofolio/presentation/screen/portofolio_add_screen.dart';
import 'package:gabungyuk/feature/portofolio/presentation/screen/portofolio_detail_screen.dart';

class PortofolioScreen extends StatelessWidget {
  const PortofolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortofolioBloc(
        repository: PortofolioRepositoryImpl(),
      )..add(GetPortofolioData()),
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
            'Portofolio Saya',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  return TextField(
                    onChanged: (query) {
                      context.read<PortofolioBloc>().add(FilterPortofolioSearch(query));
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Portofolio',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                    ),
                  );
                }
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<PortofolioBloc, PortofolioState>(
                  builder: (context, state) {
                    if (state is PortofolioLoading) {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) => const LoadingShimmer(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 16,
                        ),
                      );
                    }

                    if (state is PortofolioLoaded) {
                      if (state.filteredPortofolio.isEmpty) {
                        return const Center(child: Text('Portofolio tidak ditemukan.'));
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: state.filteredPortofolio.length,
                        itemBuilder: (context, index) {
                          final item = state.filteredPortofolio[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (innerContext) => BlocProvider.value(
                                    value: context.read<PortofolioBloc>(),
                                    child: PortofolioDetailScreen(portofolio: item),
                                  ),
                                ),
                              );
                            },
                            child: PortofolioCard(portofolio: item),
                          );
                        },
                      );
                    }

                    if (state is PortofolioError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<PortofolioBloc>().add(GetPortofolioData());
                              },
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (innerContext) => BlocProvider.value(
                      value: context.read<PortofolioBloc>(),
                      child: const PortofolioAddScreen(),
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF4285F4),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
      ),
    );
  }
}
