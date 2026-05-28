import '../data/models/portofolio_model.dart';

abstract class PortofolioEvent {}

// Event untuk mengambil data awal dari repository
class GetPortofolioData extends PortofolioEvent {}

// Event untuk pencarian/filtering portofolio
class FilterPortofolioSearch extends PortofolioEvent {
  final String query;
  FilterPortofolioSearch(this.query);
}

// 👈 Event untuk menambah data baru secara lokal
class AddPortofolioManual extends PortofolioEvent {
  final PortofolioModel portofolio;
  AddPortofolioManual(this.portofolio);
}

// 👈 Event untuk mengedit data berdasarkan ID
class EditPortofolioManual extends PortofolioEvent {
  final PortofolioModel portofolio;
  EditPortofolioManual(this.portofolio);
}

// 👈 Event untuk menghapus data berdasarkan ID
class DeletePortofolioManual extends PortofolioEvent {
  final dynamic id;
  DeletePortofolioManual(this.id);
}