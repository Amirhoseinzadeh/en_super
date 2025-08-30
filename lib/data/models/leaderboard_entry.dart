import 'package:hive/hive.dart';

part 'leaderboard_entry.g.dart';

@HiveType(typeId: 2)
class LeaderboardEntry {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final int score;

  @HiveField(3)
  final int streak;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.score,
    required this.streak,
  });
}