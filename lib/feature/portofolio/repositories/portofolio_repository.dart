import '../data/models/portofolio_model.dart';
import '../data/models/add_portofolio_models.dart';
import '../data/models/edit_portofolio_model.dart';
import '../data/models/delete_portofolio_model.dart';
import '../data/service/portofolio_service.dart';

abstract class PortofolioRepository {
  Future<PortofolioModel> fetchPortofolio();
  Future<PortofolioModel> fetchPortofolioByUserId(int userId);
  Future<AddPortofolioModels> createPortfolio({
    required String title,
    required String description,
    required String fileUrl,
    String? imagePath,
  });
  Future<EditPortofolioModel> editPortfolio({
    required int portfolioId,
    required String title,
    required String description,
    required String fileUrl,
    String? imagePath,
  });
  Future<DeletePortofolioModel> deletePortfolio(int id);
}

class PortofolioRepositoryImpl implements PortofolioRepository {
  final PortofolioService _service = PortofolioService();

  @override
  Future<PortofolioModel> fetchPortofolio() async {
    return await _service.getPortfolios();
  }

  @override
  Future<PortofolioModel> fetchPortofolioByUserId(int userId) async {
    return await _service.getPortfoliosByUserId(userId);
  }

  @override
  Future<AddPortofolioModels> createPortfolio({
    required String title,
    required String description,
    required String fileUrl,
    String? imagePath,
  }) async {
    return await _service.createPortfolio(
      title: title,
      description: description,
      fileUrl: fileUrl,
      imagePath: imagePath,
    );
  }

  @override
  Future<EditPortofolioModel> editPortfolio({
    required int portfolioId,
    required String title,
    required String description,
    required String fileUrl,
    String? imagePath,
  }) async {
    return await _service.editPortfolio(
      portfolioId: portfolioId,
      title: title,
      description: description,
      fileUrl: fileUrl,
      imagePath: imagePath,
    );
  }

  @override
  Future<DeletePortofolioModel> deletePortfolio(int id) async {
    return await _service.deletePortfolio(id);
  }
}
