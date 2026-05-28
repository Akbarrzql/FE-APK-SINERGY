import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/portofolio_repository.dart';
import '../data/models/portofolio_model.dart';
import 'portofolio_event.dart';
import 'portofolio_state.dart';

class PortofolioBloc extends Bloc<PortofolioEvent, PortofolioState> {
  final PortofolioRepository repository;

  PortofolioBloc({required this.repository}) : super(PortofolioInitial()) {

    // 1. Ambil Data Portofolio
    on<GetPortofolioData>((event, emit) async {
      emit(PortofolioLoading());
      try {
        final data = await repository.fetchPortofolio();
        emit(PortofolioLoaded(allPortofolio: data, filteredPortofolio: data));
      } catch (e) {
        debugPrint("=== ERROR FETCH PORTOFOLIO ===");
        debugPrint(e.toString());
        debugPrint("==============================");

        String errorMessage = e.toString();
        if (errorMessage.contains('ApiException:')) {
          errorMessage = errorMessage.replaceAll('ApiException:', '');
        }
        emit(PortofolioError(errorMessage));
      }
    });

    // 2. Pencarian / Live Search
    on<FilterPortofolioSearch>((event, emit) {
      if (state is PortofolioLoaded) {
        final currentState = state as PortofolioLoaded;
        if (event.query.isEmpty) {
          emit(PortofolioLoaded(
            allPortofolio: currentState.allPortofolio,
            filteredPortofolio: currentState.allPortofolio,
          ));
        } else {
          final results = currentState.allPortofolio.where((item) {
            return item.title.toLowerCase().contains(event.query.toLowerCase()) ||
                item.description.toLowerCase().contains(event.query.toLowerCase()) ||
                item.description.toLowerCase().contains(event.query.toLowerCase());
          }).toList();

          emit(PortofolioLoaded(
            allPortofolio: currentState.allPortofolio,
            filteredPortofolio: results,
          ));
        }
      }
    });

    // 3. Tambah Portofolio Baru (Manual ke List Dummy)
    on<AddPortofolioManual>((event, emit) {
      if (state is PortofolioLoaded) {
        final currentState = state as PortofolioLoaded;

        final updatedList = List<PortofolioModel>.from(currentState.allPortofolio)
          ..insert(0, event.portofolio); // Masuk ke urutan paling atas list

        emit(PortofolioLoaded(allPortofolio: updatedList, filteredPortofolio: updatedList));
      }
    });

    // 4. Edit Portofolio (Manual ke List Dummy)
    on<EditPortofolioManual>((event, emit) {
      if (state is PortofolioLoaded) {
        final currentState = state as PortofolioLoaded;

        final updatedList = currentState.allPortofolio.map((item) {
          return item.id == event.portofolio.id ? event.portofolio : item;
        }).toList();

        emit(PortofolioLoaded(allPortofolio: updatedList, filteredPortofolio: updatedList));
      }
    });

    // 5. Hapus Portofolio (Manual dari List Dummy)
    on<DeletePortofolioManual>((event, emit) {
      if (state is PortofolioLoaded) {
        final currentState = state as PortofolioLoaded;

        final updatedList = currentState.allPortofolio
            .where((item) => item.id != event.id)
            .toList();

        emit(PortofolioLoaded(allPortofolio: updatedList, filteredPortofolio: updatedList));
      }
    });
  }
}