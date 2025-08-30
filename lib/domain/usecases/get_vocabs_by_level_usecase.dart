import '../entities/vocab_entity.dart';
import '../repositories/vocab_repository.dart';

class GetVocabsByLevelUseCase {
  final VocabRepository repository;

  GetVocabsByLevelUseCase(this.repository);

  Future<List<VocabEntity>> execute(String level, {int page = 0, int pageSize = 50}) async {
    return await repository.getVocabsByLevel(level, page: page, pageSize: pageSize);
  }
}