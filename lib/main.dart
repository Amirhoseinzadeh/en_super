import 'package:en_super/data/datasources/local_datasource.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app.dart';
import 'data/models/vocab_model.dart';
import 'data/models/progress_model.dart';
import 'data/models/leaderboard_entry.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await scheduleDailyNotification();
}

Future<void> scheduleDailyNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'daily_challenge',
    'Daily Challenge',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.periodicallyShow(
    0,
    'چالش روزانه',
    'وقت یادگیری 10 لغت جدیده!',
    RepeatInterval.daily,
    platformChannelSpecifics,
  );
}

Future<void> initializeProgress() async {
  final box = await Hive.openBox('progress');
  if (box.isEmpty) {
    for (var level in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
      await box.put(
        level,
        ProgressModel(
          level: level,
          learnedCount: 0,
          totalCount: 0,
          retentionPercentage: 0.0,
          lastReviewDate: DateTime.now(),
          streak: 0,
        ),
      );
    }
  }
}


Future<void> initializeVocabs() async {
  final box = await Hive.openBox('vocabs');
  if (box.isEmpty) {
    final datasource = LocalDatasource();
    await datasource.loadVocabs(page: 0, pageSize: 50); // لود اولیه 50 لغت
  }
}

Future<void> initializeLeaderboard() async {
  final box = await Hive.openBox('leaderboard');
  if (box.isEmpty) {
    await box.put(
      'user1',
      LeaderboardEntry(
        userId: 'user1',
        username: 'کاربر نمونه',
        score: 0,
        streak: 0,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VocabModelAdapter());
  Hive.registerAdapter(ProgressModelAdapter());
  Hive.registerAdapter(LeaderboardEntryAdapter());
  await Hive.openBox('progress');
  await Hive.openBox('vocabs');
  await Hive.openBox('leaderboard');
  await initializeProgress();
  await initializeVocabs();
  await initializeLeaderboard();
  await initializeNotifications();
  runApp(ProviderScope(child: VocabLearnerApp()));
}