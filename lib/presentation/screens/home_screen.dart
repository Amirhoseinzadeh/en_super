import 'package:en_super/app.dart';
import 'package:en_super/presentation/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/progress_entity.dart';
import '../providers/progress_provider.dart';
import '../providers/vocab_provider.dart';
import 'level_screen.dart';
import 'statistics_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import '../../domain/usecases/daily_challenge_usecase.dart';

final dailyChallengeUseCaseProvider = Provider<DailyChallengeUseCase>((ref) {
  return DailyChallengeUseCase(
    ref.watch(vocabRepositoryProvider),
    ref.watch(progressRepositoryProvider),
  );
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool showReward = false;

  void startDailyChallenge(BuildContext context, String level) async {
    final vocabs = await ref.read(dailyChallengeUseCaseProvider).getDailyChallenge(level);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuizScreen(vocabs: vocabs),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    ).then((_) {
      setState(() {
        showReward = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          showReward = false;
        });
      });
      ref.read(dailyChallengeUseCaseProvider).completeChallenge(level, vocabs.length, 100.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'آموزش لغات انگلیسی',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const StatisticsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LeaderboardScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(ref.watch(themeModeProvider) == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
              ref.watch(themeModeProvider) == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyChallenge(context, levels[0]),
                const SizedBox(height: 20),
                const Text(
                  'سطوح یادگیری',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      return Consumer(
                        builder: (context, ref, _) {
                          final progressAsync = ref.watch(progressNotifierProvider(level));
                          return progressAsync.when(
                            data: (progress) => _buildLevelCard(context, level, progress),
                            loading: () => const Card(
                              elevation: 4,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, _) => Card(
                              elevation: 4,
                              child: Center(child: Text('خطا: $error', style: const TextStyle(fontFamily: 'Vazir'))),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (showReward)
            Center(
              child: Lottie.asset('assets/animations/reward.json', width: 200, height: 200, repeat: false),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenge(BuildContext context, String level) {
    return Consumer(
      builder: (context, ref, _) {
        final progressAsync = ref.watch(progressNotifierProvider(level));
        return progressAsync.when(
          data: (progress) => Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Lottie.asset('assets/animations/star.json', width: 50, height: 50, repeat: false),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'چالش روزانه',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                        const Text(
                          'امروز 10 لغت جدید یاد بگیر و جایزه بگیر!',
                          style: TextStyle(fontSize: 14, fontFamily: 'Vazir'),
                        ),
                        Text(
                          'روزهای متوالی: ${progress.streak}',
                          style: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => startDailyChallenge(context, level),
                          child: const Text('شروع چالش', style: TextStyle(fontFamily: 'Vazir')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Card(
            elevation: 4,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => const Card(
            elevation: 4,
            child: Center(child: Text('خطا در بارگذاری', style: TextStyle(fontFamily: 'Vazir'))),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, String level, ProgressEntity progress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => LevelScreen(level: level),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'سطح $level',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress.retentionPercentage / 100,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue.shade400,
              ),
              const SizedBox(height: 5),
              Text(
                '${progress.retentionPercentage.toStringAsFixed(1)}% کامل شده',
                style: const TextStyle(fontFamily: 'Vazir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}