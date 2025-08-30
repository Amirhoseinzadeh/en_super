class VocabEntity {
  final String word;
  final String pronunciation;
  final String definition;
  final String example;
  final String persian;
  final String level;
  final String category;
  final DateTime? lastReviewed;
  final int interval;
  final double easeFactor;
  final int repetitions;

  VocabEntity({
    required this.word,
    required this.pronunciation,
    required this.definition,
    required this.example,
    required this.persian,
    required this.level,
    required this.category,
    this.lastReviewed,
    this.interval = 1,
    this.easeFactor = 2.5,
    this.repetitions = 0,
  });
}