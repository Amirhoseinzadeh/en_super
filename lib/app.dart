import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_screen.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class VocabLearnerApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Vocab Learner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Vazir',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Vazir'),
        ),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Vazir',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Vazir', color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}