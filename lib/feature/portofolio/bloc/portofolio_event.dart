abstract class PortofolioEvent {}

class GetPortofolioData extends PortofolioEvent {}

class FilterPortofolioSearch extends PortofolioEvent {
  final String query;
  FilterPortofolioSearch(this.query);
}

class CreatePortofolioEvent extends PortofolioEvent {
  final String title;
  final String description;
  final String fileUrl;
  final String? imagePath;

  CreatePortofolioEvent({
    required this.title,
    required this.description,
    required this.fileUrl,
    this.imagePath,
  });
}

class UpdatePortofolioEvent extends PortofolioEvent {
  final int portfolioId;
  final String title;
  final String description;
  final String fileUrl;
  final String? imagePath;

  UpdatePortofolioEvent({
    required this.portfolioId,
    required this.title,
    required this.description,
    required this.fileUrl,
    this.imagePath,
  });
}

class DeletePortofolioEvent extends PortofolioEvent {
  final int id;
  DeletePortofolioEvent(this.id);
}
