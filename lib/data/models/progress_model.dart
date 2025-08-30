import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/progress_entity.dart';

part 'progress_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class ProgressModel extends ProgressEntity {
  @HiveField(0)
  final String level;

  @HiveField(1)
  final int learnedCount;

  @HiveField(2)
  final int totalCount;

  @HiveField(3)
  final double retentionPercentage;

  @HiveField(4)
  final DateTime lastReviewDate;

  @HiveField(5)
  final int streak;

  ProgressModel({
    required this.level,
    required this.learnedCount,
    required this.totalCount,
    required this.retentionPercentage,
    required this.lastReviewDate,
    required this.streak,
  }) : super(
    level: level,
    learnedCount: learnedCount,
    totalCount: totalCount,
    retentionPercentage: retentionPercentage,
    lastReviewDate: lastReviewDate,
    streak: streak,
  );

  factory ProgressModel.fromJson(Map<String, dynamic> json) => _$ProgressModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressModelToJson(this);
}