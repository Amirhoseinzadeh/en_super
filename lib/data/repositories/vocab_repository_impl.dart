import '../../domain/entities/vocab_entity.dart';
import '../../domain/repositories/vocab_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/vocab_model.dart';

class VocabRepositoryImpl implements VocabRepository {
  final LocalDatasource datasource;

  VocabRepositoryImpl(this.datasource);

  @override
  Future<List<VocabEntity>> getVocabsByLevel(String level, {int page = 0, int pageSize = 50}) async {
    final allVocabs = await datasource.loadVocabs(page: page, pageSize: pageSize);
    return allVocabs.where((vocab) => vocab.level == level).toList();
  }

  @override
  Future<void> updateVocab(VocabEntity vocab) async {
    await datasource.updateVocab(VocabModel(
      word: vocab.word,
      pronunciation: vocab.pronunciation,
      definition: vocab.definition,
      example: vocab.example,
      persian: vocab.persian,
      level: vocab.level,
      category: vocab.category,
      lastReviewed: vocab.lastReviewed,
      interval: vocab.interval,
      easeFactor: vocab.easeFactor,
      repetitions: vocab.repetitions,
    ));
  }
}