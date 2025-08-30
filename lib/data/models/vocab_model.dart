import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/vocab_entity.dart';

part 'vocab_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class VocabModel extends VocabEntity {
  @HiveField(0)
  final String word;

  @HiveField(1)
  final String pronunciation;

  @HiveField(2)
  final String definition;

  @HiveField(3)
  final String example;

  @HiveField(4)
  final String persian;

  @HiveField(5)
  final String level;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final DateTime? lastReviewed;

  @HiveField(8)
  final int interval;

  @HiveField(9)
  final double easeFactor;

  @HiveField(10)
  final int repetitions;

  VocabModel({
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
  }) : super(
    word: word,
    pronunciation: pronunciation,
    definition: definition,
    example: example,
    persian: persian,
    level: level,
    category: category,
    lastReviewed: lastReviewed,
    interval: interval,
    easeFactor: easeFactor,
    repetitions: repetitions,
  );

  factory VocabModel.fromJson(Map<String, dynamic> json) => _$VocabModelFromJson(json);
  Map<String, dynamic> toJson() => _$VocabModelToJson(this);
}