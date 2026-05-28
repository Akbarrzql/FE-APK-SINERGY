import '../data/models/portofolio_model.dart';

abstract class PortofolioState {}

class PortofolioInitial extends PortofolioState {}

class PortofolioLoading extends PortofolioState {}

class PortofolioLoaded extends PortofolioState {
  final List<PortofolioModel> allPortofolio;
  final List<PortofolioModel> filteredPortofolio;

  PortofolioLoaded({
    required this.allPortofolio,
    required this.filteredPortofolio,
  });
}

class PortofolioError extends PortofolioState {
  final String message;
  PortofolioError(this.message);
}