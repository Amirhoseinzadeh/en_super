import 'package:share_plus/share_plus.dart';
import '../repositories/progress_repository.dart';

class ShareProgressUseCase {
  final ProgressRepository repository;

  ShareProgressUseCase(this.repository);

  Future<void> execute(String level) async {
    final progress = await repository.getProgress(level);
    final text = 'پیشرفت من در سطح $level: ${progress.retentionPercentage}% حفظ شده!';
    await Share.share(text);
  }
}