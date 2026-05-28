import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gabungyuk/feature/task/bloc/recap_bloc.dart';
import 'package:gabungyuk/feature/task/bloc/recap_event.dart';
import 'package:gabungyuk/feature/task/bloc/recap_state.dart';
import 'package:gabungyuk/feature/task/data/repositories/recap_repository.dart';
import '../widgets/recap_chart_widget.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecapBloc(
        recapRepository: RecapRepositoryImpl(), // ← inject repository
      )..add(FetchRecapData(filterWaktu: 'mingguan')),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Recap Aktivitas',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            BlocBuilder<RecapBloc, RecapState>(
              builder: (context, state) {
                String selectedFilter = 'mingguan';
                if (state is RecapLoaded) {
                  selectedFilter = state.activeFilter;
                }

                return Container(
                  margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.blue,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'mingguan',
                          child: Text(
                            'Mingguan',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'bulanan',
                          child: Text(
                            'Bulanan',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                      onChanged: (newValue) {
                        if (newValue != null) {
                          context.read<RecapBloc>().add(
                            FetchRecapData(filterWaktu: newValue),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<RecapBloc, RecapState>(
          builder: (context, state) {
            if (state is RecapLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecapLoaded) {
              final data = state.dataRecap;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RecapChartWidget(
                      totalDurasi: data.totalKontribusi.toString(),
                      activeFilter: state.activeFilter,
                      grafikList: data.chartData
                          .map((e) => {'label': e.label, 'value': e.value})
                          .toList(),
                    ),
                  ],
                ),
              );
            }

            if (state is RecapError) {
              return Center(
                child: Text('Gagal mengambil data: ${state.message}'),
              );
            }

            return const Center(child: Text('Tidak ada aktivitas ditemukan.'));
          },
        ),
      ),
    );
  }
}
