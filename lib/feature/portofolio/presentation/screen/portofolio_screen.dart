import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/feature/portofolio/bloc/portofolio_bloc.dart';
import 'package:gabungyuk/feature/portofolio/bloc/portofolio_event.dart';
import 'package:gabungyuk/feature/portofolio/bloc/portofolio_state.dart';
import 'package:gabungyuk/feature/portofolio/data/repositories/portofolio_repository.dart';
import '../widget/portofolio_card.dart';
import 'package:gabungyuk/feature/portofolio/presentation/screen/portofolio_add_screen.dart';
import 'package:gabungyuk/feature/portofolio/presentation/screen/portofolio_edit_screen.dart';

class PortofolioScreen extends StatelessWidget {
  const PortofolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortofolioBloc(
        repository: PortofolioRepositoryImpl(),
      )..add(GetPortofolioData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 1. Search Bar Input
              Builder(
                  builder: (context) {
                    return TextField(
                      onChanged: (query) {
                        context.read<PortofolioBloc>().add(FilterPortofolioSearch(query));
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari Kolaborasi',
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
              const SizedBox(height: 20),

              // 2. Area Grid List yang Dikontrol BLoC Builder
              Expanded(
                child: BlocBuilder<PortofolioBloc, PortofolioState>(
                  builder: (context, state) {
                    if (state is PortofolioLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is PortofolioLoaded) {
                      if (state.filteredPortofolio.isEmpty) {
                        return const Center(child: Text('Portofolio tidak ditemukan.'));
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: state.filteredPortofolio.length,
                        itemBuilder: (context, index) {
                          final item = state.filteredPortofolio[index];

                          // Membungkus card dengan GestureDetector agar beneran bisa diklik ke detail
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PortofolioEditScreen(portofolio: item),
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
        // 3. Tombol Floating Action Button (+) Diarahkan ke Halaman TAMBAH BARU
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PortofolioAddScreen(),
              ),
            );
          },
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}