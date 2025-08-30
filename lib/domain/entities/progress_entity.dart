class ProgressEntity {
  final String level;
  final int learnedCount;
  final int totalCount;
  final double retentionPercentage;
  final DateTime lastReviewDate;
  final int streak;

  ProgressEntity({
    required this.level,
    required this.learnedCount,
    required this.totalCount,
    required this.retentionPercentage,
    required this.lastReviewDate,
    required this.streak,
  });
}