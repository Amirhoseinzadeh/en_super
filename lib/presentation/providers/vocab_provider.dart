import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/vocab_repository_impl.dart';
import '../../domain/entities/vocab_entity.dart';
import '../../domain/usecases/get_vocabs_by_level_usecase.dart';
import '../../domain/usecases/update_srs_usecase.dart';
import '../../domain/repositories/vocab_repository.dart';

final vocabRepositoryProvider = Provider<VocabRepository>((ref) => VocabRepositoryImpl(LocalDatasource()));

final getVocabsUseCaseProvider = Provider<GetVocabsByLevelUseCase>((ref) {
  return GetVocabsByLevelUseCase(ref.watch(vocabRepositoryProvider));
});

final updateSRSUseCaseProvider = Provider<UpdateSRSUseCase>((ref) {
  return UpdateSRSUseCase(ref.watch(vocabRepositoryProvider));
});

final vocabsProvider = FutureProvider.family<List<VocabEntity>, String>((ref, level) async {
  final vocabs = await ref.watch(getVocabsUseCaseProvider).execute(level, page: 0, pageSize: 50);
  return vocabs.where((vocab) {
    if (vocab.lastReviewed == null) return true;
    final nextReview = vocab.lastReviewed!.add(Duration(days: vocab.interval));
    return DateTime.now().isAfter(nextReview);
  }).toList();
});