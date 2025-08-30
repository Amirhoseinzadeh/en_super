import '../entities/progress_entity.dart';
import '../repositories/progress_repository.dart';

class UpdateProgressUseCase {
  final ProgressRepository repository;

  UpdateProgressUseCase(this.repository);

  Future<void> execute(String level, int learnedCount, double retention) async {
    final newProgress = ProgressEntity(
      level: level,
      learnedCount: learnedCount,
      totalCount: await repository.getTotalVocabs(level),
      retentionPercentage: retention,
      lastReviewDate: DateTime.now(),
      streak: await repository.calculateStreak(),
    );
    await repository.saveProgress(newProgress);
  }
}