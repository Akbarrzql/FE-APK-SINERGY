import '../data/models/portofolio_model.dart';

abstract class PortofolioState {}

class PortofolioInitial extends PortofolioState {}

class PortofolioLoading extends PortofolioState {}

class PortofolioLoaded extends PortofolioState {
  final List<Data> allPortofolio;
  final List<Data> filteredPortofolio;

  PortofolioLoaded({
    required this.allPortofolio,
    required this.filteredPortofolio,
  });
}

class PortofolioActionSuccess extends PortofolioState {
  final String message;
  PortofolioActionSuccess(this.message);
}

class PortofolioError extends PortofolioState {
  final String message;
  PortofolioError(this.message);
}
