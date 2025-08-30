import '../entities/progress_entity.dart';

abstract class ProgressRepository {
  Future<ProgressEntity> getProgress(String level);
  Future<void> saveProgress(ProgressEntity progress);
  Future<int> getTotalVocabs(String level);
  Future<int> calculateStreak();
}