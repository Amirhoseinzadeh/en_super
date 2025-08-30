import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/models/leaderboard_entry.dart';

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final datasource = LocalDatasource();
  return await datasource.getLeaderboard();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'جدول امتیازات',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
      body: leaderboardAsync.when(
        data: (entries) => ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}', style: const TextStyle(fontFamily: 'Vazir')),
                ),
                title: Text(entry.username, style: const TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'امتیاز: ${entry.score} | روزهای متوالی: ${entry.streak}',
                  style: const TextStyle(fontFamily: 'Vazir'),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطا: $error', style: const TextStyle(fontFamily: 'Vazir'))),
      ),
    );
  }
}