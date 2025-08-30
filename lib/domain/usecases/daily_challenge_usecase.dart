import 'dart:math';
import '../../domain/entities/vocab_entity.dart';
import '../../domain/repositories/vocab_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/entities/progress_entity.dart';

class DailyChallengeUseCase {
  final VocabRepository vocabRepository;
  final ProgressRepository progressRepository;

  DailyChallengeUseCase(this.vocabRepository, this.progressRepository);

  Future<List<VocabEntity>> getDailyChallenge(String level) async {
    final vocabs = await vocabRepository.getVocabsByLevel(level);
    final random = Random();
    return (vocabs..shuffle(random)).take(10).toList();
  }

  Future<void> completeChallenge(String level, int learnedCount, double retention) async {
    final progress = await progressRepository.getProgress(level);
    final newProgress = ProgressEntity(
      level: level,
      learnedCount: progress.learnedCount + learnedCount,
      totalCount: progress.totalCount,
      retentionPercentage: retention,
      lastReviewDate: DateTime.now(),
      streak: progress.streak + 1,
    );
    await progressRepository.saveProgress(newProgress);
  }
}