import '../entities/vocab_entity.dart';
import '../repositories/vocab_repository.dart';

class UpdateSRSUseCase {
  final VocabRepository repository;

  UpdateSRSUseCase(this.repository);

  Future<void> execute(VocabEntity vocab, int quality) async {
    // کیفیت: 0 (غلط) تا 5 (کاملاً درست)
    double newEaseFactor = vocab.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = newEaseFactor.clamp(1.3, 2.5);

    int newInterval;
    if (quality < 3) {
      newInterval = 1;
    } else {
      newInterval = (vocab.repetitions == 0)
          ? 1
          : (vocab.repetitions == 1)
          ? 6
          : (vocab.interval * newEaseFactor).round();
    }

    final updatedVocab = VocabEntity(
      word: vocab.word,
      pronunciation: vocab.pronunciation,
      definition: vocab.definition,
      example: vocab.example,
      persian: vocab.persian,
      level: vocab.level,
      category: vocab.category,
      lastReviewed: DateTime.now(),
      interval: newInterval,
      easeFactor: newEaseFactor,
      repetitions: quality >= 3 ? vocab.repetitions + 1 : 0,
    );

    await repository.updateVocab(updatedVocab);
  }
}