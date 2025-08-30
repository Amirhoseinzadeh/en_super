// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressModelAdapter extends TypeAdapter<ProgressModel> {
  @override
  final int typeId = 1;

  @override
  ProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressModel(
      level: fields[0] as String,
      learnedCount: fields[1] as int,
      totalCount: fields[2] as int,
      retentionPercentage: fields[3] as double,
      lastReviewDate: fields[4] as DateTime,
      streak: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.level)
      ..writeByte(1)
      ..write(obj.learnedCount)
      ..writeByte(2)
      ..write(obj.totalCount)
      ..writeByte(3)
      ..write(obj.retentionPercentage)
      ..writeByte(4)
      ..write(obj.lastReviewDate)
      ..writeByte(5)
      ..write(obj.streak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) =>
    ProgressModel(
      level: json['level'] as String,
      learnedCount: (json['learnedCount'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      retentionPercentage: (json['retentionPercentage'] as num).toDouble(),
      lastReviewDate: DateTime.parse(json['lastReviewDate'] as String),
      streak: (json['streak'] as num).toInt(),
    );

Map<String, dynamic> _$ProgressModelToJson(ProgressModel instance) =>
    <String, dynamic>{
      'level': instance.level,
      'learnedCount': instance.learnedCount,
      'totalCount': instance.totalCount,
      'retentionPercentage': instance.retentionPercentage,
      'lastReviewDate': instance.lastReviewDate.toIso8601String(),
      'streak': instance.streak,
    };
