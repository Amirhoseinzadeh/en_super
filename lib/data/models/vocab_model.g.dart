// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabModelAdapter extends TypeAdapter<VocabModel> {
  @override
  final int typeId = 0;

  @override
  VocabModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabModel(
      word: fields[0] as String,
      pronunciation: fields[1] as String,
      definition: fields[2] as String,
      example: fields[3] as String,
      persian: fields[4] as String,
      level: fields[5] as String,
      category: fields[6] as String,
      lastReviewed: fields[7] as DateTime?,
      interval: fields[8] as int,
      easeFactor: fields[9] as double,
      repetitions: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VocabModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.pronunciation)
      ..writeByte(2)
      ..write(obj.definition)
      ..writeByte(3)
      ..write(obj.example)
      ..writeByte(4)
      ..write(obj.persian)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.lastReviewed)
      ..writeByte(8)
      ..write(obj.interval)
      ..writeByte(9)
      ..write(obj.easeFactor)
      ..writeByte(10)
      ..write(obj.repetitions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocabModel _$VocabModelFromJson(Map<String, dynamic> json) => VocabModel(
      word: json['word'] as String,
      pronunciation: json['pronunciation'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      persian: json['persian'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      lastReviewed: json['lastReviewed'] == null
          ? null
          : DateTime.parse(json['lastReviewed'] as String),
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VocabModelToJson(VocabModel instance) =>
    <String, dynamic>{
      'word': instance.word,
      'pronunciation': instance.pronunciation,
      'definition': instance.definition,
      'example': instance.example,
      'persian': instance.persian,
      'level': instance.level,
      'category': instance.category,
      'lastReviewed': instance.lastReviewed?.toIso8601String(),
      'interval': instance.interval,
      'easeFactor': instance.easeFactor,
      'repetitions': instance.repetitions,
    };
