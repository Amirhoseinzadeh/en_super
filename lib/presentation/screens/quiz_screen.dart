import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/vocab_entity.dart';
import '../providers/progress_provider.dart';
import '../providers/vocab_provider.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/models/leaderboard_entry.dart';
import 'dart:math';

class QuizScreen extends ConsumerStatefulWidget {
  final List<VocabEntity> vocabs;

  const QuizScreen({Key? key, required this.vocabs}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  String? selectedAnswer;
  bool showResult = false;
  List<Map<String, dynamic>> questions = [];
  Map<String, String> matchedPairs = {};

  @override
  void initState() {
    super.initState();
    generateQuestions();
    startTimer();
  }

  void generateQuestions() {
    final random = Random();
    questions = widget.vocabs.take(10).map((vocab) {
      final type = ['multiple_choice', 'matching', 'spelling'][random.nextInt(3)];
      final options = _generateOptions(vocab, random);
      return {
        'vocab': vocab,
        'type': type,
        'options': options,
        'correctAnswer': vocab.persian,
      };
    }).toList();
  }

  List<String> _generateOptions(VocabEntity vocab, Random random) {
    final options = [vocab.persian];
    final otherVocabs = widget.vocabs.where((v) => v.word != vocab.word).toList();
    while (options.length < 4 && otherVocabs.isNotEmpty) {
      final randomVocab = otherVocabs[random.nextInt(otherVocabs.length)];
      if (!options.contains(randomVocab.persian)) {
        options.add(randomVocab.persian);
      }
    }
    options.shuffle();
    return options;
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          nextQuestion(0);
        }
      });
    });
  }

  void checkAnswer(String answer) {
    final vocab = questions[currentQuestionIndex]['vocab'] as VocabEntity;
    final isCorrect = answer == questions[currentQuestionIndex]['correctAnswer'];
    final quality = isCorrect ? 5 : 0;
    ref.read(updateSRSUseCaseProvider).execute(vocab, quality);
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      if (isCorrect) {
        score += 10;
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      nextQuestion(quality);
    });
  }

  void checkMatchingAnswer(String word, String persian) {
    final vocab = questions[currentQuestionIndex]['vocab'] as VocabEntity;
    final isCorrect = persian == vocab.persian;
    final quality = isCorrect ? 5 : 0;
    ref.read(updateSRSUseCaseProvider).execute(vocab, quality);
    setState(() {
      matchedPairs[word] = persian;
      showResult = true;
      if (isCorrect) {
        score += 10;
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      nextQuestion(quality);
    });
  }

  void updateLeaderboard() async {
    final datasource = LocalDatasource();
    final entry = LeaderboardEntry(
      userId: 'user1',
      username: 'کاربر نمونه',
      score: score,
      streak: (await ref.read(progressNotifierProvider(widget.vocabs[0].level)).valueOrNull)?.streak ?? 0,
    );
    await datasource.updateLeaderboard(entry);
  }

  void nextQuestion(int quality) {
    setState(() {
      showResult = false;
      selectedAnswer = null;
      matchedPairs.clear();
      currentQuestionIndex++;
      if (currentQuestionIndex < questions.length) {
        startTimer();
      } else {
        timer?.cancel();
        ref.read(progressNotifierProvider(widget.vocabs[0].level).notifier)
            .updateProgress(currentQuestionIndex, (score / (questions.length * 10)) * 100);
        updateLeaderboard();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= questions.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'نتایج آزمون',
            style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue.shade100,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/complete.json', width: 150, height: 150),
              Text(
                'امتیاز شما: $score / ${questions.length * 10}',
                style: const TextStyle(fontFamily: 'Vazir', fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('بازگشت', style: TextStyle(fontFamily: 'Vazir')),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];
    final vocab = question['vocab'] as VocabEntity;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'آزمون سطح ${vocab.level}',
          style: const TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'امتیاز: $score',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'زمان باقی‌مانده: $timeLeft ثانیه',
              style: const TextStyle(fontFamily: 'Vazir', fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              question['type'] == 'spelling' ? 'کلمه را تایپ کنید' : vocab.word,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (question['type'] == 'multiple_choice') ...[
              ...question['options'].map((option) => ElevatedButton(
                onPressed: showResult ? null : () => checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: showResult
                      ? (option == question['correctAnswer']
                      ? Colors.green
                      : selectedAnswer == option
                      ? Colors.red
                      : null)
                      : null,
                ),
                child: Text(option, style: const TextStyle(fontFamily: 'Vazir')),
              )),
            ],
            if (question['type'] == 'matching') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: question['options'].map((option) => Draggable<String>(
                      data: option,
                      feedback: Material(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(option, style: const TextStyle(fontFamily: 'Vazir')),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(option, style: const TextStyle(fontFamily: 'Vazir')),
                      ),
                    )).toList(),
                  ),
                  Column(
                    children: question['options'].map((option) => DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        final matched = matchedPairs.containsValue(option);
                        return Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: matched
                                  ? (option == vocab.persian ? Colors.green : Colors.red)
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            matched ? matchedPairs.entries.firstWhere((entry) => entry.value == option).key : 'بکشید',
                            style: const TextStyle(fontFamily: 'Vazir'),
                          ),
                        );
                      },
                      onAccept: (data) {
                        checkMatchingAnswer(data, option);
                      },
                    )).toList(),
                  ),
                ],
              ),
            ],
            if (question['type'] == 'spelling') ...[
              TextField(
                onSubmitted: showResult ? null : (value) => checkAnswer(value),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'کلمه را وارد کنید',
                  labelStyle: TextStyle(fontFamily: 'Vazir'),
                ),
              ),
            ],
            if (showResult) ...[
              const SizedBox(height: 20),
              Lottie.asset(
                selectedAnswer == question['correctAnswer'] || matchedPairs.containsValue(vocab.persian)
                    ? 'assets/animations/success.json'
                    : 'assets/animations/error.json',
                width: 100,
                height: 100,
              ),
            ],
          ],
        ),
      ),
    );
  }
}