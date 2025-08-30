import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final LocalDatasource datasource;

  ProgressRepositoryImpl(this.datasource);

  @override
  Future<ProgressEntity> getProgress(String level) async {
    final progress = await datasource.getProgress(level);
    return progress ?? ProgressEntity(
      level: level,
      learnedCount: 0,
      totalCount: 0,
      retentionPercentage: 0.0,
      lastReviewDate: DateTime.now(),
      streak: 0,
    );
  }

  @override
  Future<void> saveProgress(ProgressEntity progress) async {
    await datasource.saveProgress(ProgressModel(
      level: progress.level,
      learnedCount: progress.learnedCount,
      totalCount: progress.totalCount,
      retentionPercentage: progress.retentionPercentage,
      lastReviewDate: progress.lastReviewDate,
      streak: progress.streak,
    ));
  }

  @override
  Future<int> getTotalVocabs(String level) async {
    final vocabs = await datasource.loadVocabs();
    return vocabs.where((vocab) => vocab.level == level).length;
  }

  @override
  Future<int> calculateStreak() async {
    return 1;
  }
}