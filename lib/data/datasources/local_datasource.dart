import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import '../models/vocab_model.dart';
import '../models/progress_model.dart';
import '../models/leaderboard_entry.dart';

class LocalDatasource {
  Future<List<VocabModel>> loadVocabs({int page = 0, int pageSize = 50}) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/vocab.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, jsonList.length);
      final paginatedList = jsonList.sublist(startIndex, endIndex);
      final vocabs = paginatedList.map((json) => VocabModel.fromJson(json)).toList();
      final box = await Hive.openBox('vocabs');
      for (var vocab in vocabs) {
        if (!box.containsKey(vocab.word)) {
          await box.put(vocab.word, vocab);
        }
      }
      return vocabs;
    } catch (e) {
      print('Error loading vocabs: $e');
      return [];
    }
  }

  Future<void> saveProgress(ProgressModel progress) async {
    try {
      final box = await Hive.openBox('progress');
      await box.put(progress.level, progress);
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  Future<ProgressModel?> getProgress(String level) async {
    try {
      final box = await Hive.openBox('progress');
      return box.get(level);
    } catch (e) {
      print('Error getting progress: $e');
      return null;
    }
  }

  Future<void> updateVocab(VocabModel vocab) async {
    try {
      final box = await Hive.openBox('vocabs');
      await box.put(vocab.word, vocab);
    } catch (e) {
      print('Error updating vocab: $e');
    }
  }

  Future<void> updateLeaderboard(LeaderboardEntry entry) async {
    try {
      final box = await Hive.openBox('leaderboard');
      await box.put(entry.userId, entry);
    } catch (e) {
      print('Error updating leaderboard: $e');
    }
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final box = await Hive.openBox('leaderboard');
      return box.values.cast<LeaderboardEntry>().toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }
}