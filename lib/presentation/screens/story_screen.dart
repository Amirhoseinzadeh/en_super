import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';
import '../../domain/entities/vocab_entity.dart';
import '../providers/vocab_provider.dart';

class StoryScreen extends ConsumerStatefulWidget {
  final List<VocabEntity> vocabs;

  const StoryScreen({Key? key, required this.vocabs}) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  final FlutterTts tts = FlutterTts();
  String storyText = '';
  List<Map<String, dynamic>> questions = [];
  bool showQuestion = false;
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool ttsSupported = true;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadStory();
  }

  Future<void> _initializeTts() async {
    try {
      await tts.setLanguage('en-US');
      await tts.setPitch(1.0);
    } catch (e) {
      setState(() {
        ttsSupported = false;
      });
      print('TTS not supported: $e');
    }
  }

  Future<void> _loadStory() async {
    final jsonString = await rootBundle.loadString('assets/data/stories.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final storyData = jsonList.firstWhere(
          (story) => story['level'] == widget.vocabs[0].level,
      orElse: () => {'text': 'No story available', 'questions': []},
    );
    setState(() {
      storyText = storyData['text'] as String;
      questions = List<Map<String, dynamic>>.from(storyData['questions']);
    });
  }

  void _checkQuestionAnswer(String answer, Map<String, dynamic> question) {
    final isCorrect = answer == question['correctAnswer'];
    final quality = isCorrect ? 5 : 0;
    final vocab = widget.vocabs.firstWhere((v) => v.word == question['word']);
    ref.read(updateSRSUseCaseProvider).execute(vocab, quality);
    setState(() {
      selectedAnswer = answer;
      showResult = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showResult = false;
        selectedAnswer = null;
        currentQuestionIndex++;
        showQuestion = currentQuestionIndex < questions.length;
      });
    });
  }

  Future<void> _speak(String word) async {
    if (ttsSupported) {
      try {
        await tts.speak(word);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تلفظ در این دستگاه پشتیبانی نمی‌شود')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تلفظ در این دستگاه پشتیبانی نمی‌شود')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.vocabs.map((vocab) => vocab.word.toLowerCase()).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'داستان تعاملی',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: _buildStoryText(words),
                  ),
                ),
              ),
            ),
            if (showQuestion && currentQuestionIndex < questions.length) ...[
              const SizedBox(height: 20),
              Text(
                'معنی "${questions[currentQuestionIndex]['word']}" چیست؟',
                style: const TextStyle(fontFamily: 'Vazir', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...questions[currentQuestionIndex]['options'].map((option) => ElevatedButton(
                onPressed: showResult ? null : () => _checkQuestionAnswer(option, questions[currentQuestionIndex]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: showResult
                      ? (option == questions[currentQuestionIndex]['correctAnswer']
                      ? Colors.green
                      : selectedAnswer == option
                      ? Colors.red
                      : null)
                      : null,
                ),
                child: Text(option, style: const TextStyle(fontFamily: 'Vazir')),
              )),
              if (showResult)
                Lottie.asset(
                  selectedAnswer == questions[currentQuestionIndex]['correctAnswer']
                      ? 'assets/animations/success.json'
                      : 'assets/animations/error.json',
                  width: 100,
                  height: 100,
                ),
            ],
            if (!showQuestion && currentQuestionIndex == 0)
              ElevatedButton(
                onPressed: () => setState(() => showQuestion = true),
                child: const Text('شروع سؤالات', style: TextStyle(fontFamily: 'Vazir')),
              ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildStoryText(Set<String> vocabWords) {
    final words = storyText.split(' ');
    final spans = <TextSpan>[];

    for (var word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
      final isVocab = vocabWords.contains(cleanWord);
      spans.add(
        TextSpan(
          text: '$word ',
          style: TextStyle(
            fontWeight: isVocab ? FontWeight.bold : FontWeight.normal,
            color: isVocab ? Colors.blue.shade700 : Colors.black,
          ),
          recognizer: isVocab
              ? (TapGestureRecognizer()
            ..onTap = () {
              final vocab = widget.vocabs.firstWhere((v) => v.word.toLowerCase() == cleanWord);
              _showVocabDialog(context, vocab);
            })
              : null,
        ),
      );
    }
    return spans;
  }

  void _showVocabDialog(BuildContext context, VocabEntity vocab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vocab.word, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ترجمه: ${vocab.persian}', style: const TextStyle(fontFamily: 'Vazir')),
            const SizedBox(height: 10),
            Text('تعریف: ${vocab.definition}'),
            const SizedBox(height: 10),
            Text('مثال: ${vocab.example}', style: const TextStyle(fontFamily: 'Vazir')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speak(vocab.word),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن', style: TextStyle(fontFamily: 'Vazir')),
          ),
        ],
      ),
    );
  }
}