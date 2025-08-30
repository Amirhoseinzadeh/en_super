import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../domain/usecases/update_progress_usecase.dart';
import '../../domain/repositories/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) => ProgressRepositoryImpl(LocalDatasource()));

final progressNotifierProvider = AsyncNotifierProvider.family<ProgressNotifier, ProgressEntity, String>(
  ProgressNotifier.new,
);

class ProgressNotifier extends FamilyAsyncNotifier<ProgressEntity, String> {
  late ProgressRepository _repository;

  @override
  Future<ProgressEntity> build(String level) async {
    _repository = ref.watch(progressRepositoryProvider);
    final progress = await GetStatsUseCase(_repository).execute(level);
    print('Progress loaded for $level: $progress');
    return progress;
  }

  Future<void> updateProgress(int learned, double retention) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await UpdateProgressUseCase(_repository).execute(arg, learned, retention);
      return await GetStatsUseCase(_repository).execute(arg);
    });
  }
}