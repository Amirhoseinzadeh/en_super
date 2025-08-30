import '../entities/vocab_entity.dart';

abstract class VocabRepository {
  Future<List<VocabEntity>> getVocabsByLevel(String level, {int page = 0, int pageSize = 50});
  Future<void> updateVocab(VocabEntity vocab);
}