import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/portofolio_repository.dart';
import '../data/models/portofolio_model.dart';
import 'portofolio_event.dart';
import 'portofolio_state.dart';

class PortofolioBloc extends Bloc<PortofolioEvent, PortofolioState> {
  final PortofolioRepository repository;

  PortofolioBloc({required this.repository}) : super(PortofolioInitial()) {
    on<GetPortofolioData>((event, emit) async {
      emit(PortofolioLoading());
      try {
        final result = await repository.fetchPortofolio();
        final data = result.data ?? [];
        emit(PortofolioLoaded(allPortofolio: data, filteredPortofolio: data));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.contains('ApiException:')) {
          errorMessage = errorMessage.replaceAll('ApiException:', '');
        }
        emit(PortofolioError(errorMessage));
      }
    });

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
            final titleMatch = item.title?.toLowerCase().contains(event.query.toLowerCase()) ?? false;
            final descriptionMatch = item.description?.toLowerCase().contains(event.query.toLowerCase()) ?? false;
            return titleMatch || descriptionMatch;
          }).toList();

          emit(PortofolioLoaded(
            allPortofolio: currentState.allPortofolio,
            filteredPortofolio: results,
          ));
        }
      }
    });

    on<CreatePortofolioEvent>((event, emit) async {
      emit(PortofolioLoading());
      try {
        final response = await repository.createPortfolio(
          title: event.title,
          description: event.description,
          fileUrl: event.fileUrl,
          imagePath: event.imagePath,
        );
        emit(PortofolioActionSuccess(response.message ?? 'Portfolio berhasil ditambahkan'));
        add(GetPortofolioData());
      } catch (e) {
        emit(PortofolioError(e.toString()));
      }
    });

    on<UpdatePortofolioEvent>((event, emit) async {
      emit(PortofolioLoading());
      try {
        final response = await repository.editPortfolio(
          portfolioId: event.portfolioId,
          title: event.title,
          description: event.description,
          fileUrl: event.fileUrl,
          imagePath: event.imagePath,
        );
        emit(PortofolioActionSuccess(response.message ?? 'Portfolio berhasil diperbarui'));
        add(GetPortofolioData());
      } catch (e) {
        emit(PortofolioError(e.toString()));
      }
    });

    on<DeletePortofolioEvent>((event, emit) async {
      emit(PortofolioLoading());
      try {
        final response = await repository.deletePortfolio(event.id);
        emit(PortofolioActionSuccess(response.message ?? 'Portfolio berhasil dihapus'));
        add(GetPortofolioData());
      } catch (e) {
        emit(PortofolioError(e.toString()));
      }
    });
  }
}
