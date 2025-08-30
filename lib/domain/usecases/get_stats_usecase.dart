import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class GetStatsUseCase {
  final ProgressRepository repository;

  GetStatsUseCase(this.repository);

  Future<ProgressEntity> execute(String level) async {
    return await repository.getProgress(level);
  }
}