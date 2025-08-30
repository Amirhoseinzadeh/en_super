import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/entities/vocab_entity.dart';
import '../providers/progress_provider.dart';
import '../providers/vocab_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final List<VocabEntity> vocabs;

  const FlashcardScreen({Key? key, required this.vocabs}) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int currentIndex = 0;
  bool showAnswer = false;
  final FlutterTts tts = FlutterTts();
  bool ttsSupported = true;

  @override
  void initState() {
    super.initState();
    _initializeTts();
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

  void _nextCard() {
    setState(() {
      showAnswer = false;
      currentIndex = (currentIndex + 1) % widget.vocabs.length;
    });
  }

  void _markAsLearned(int quality) {
    final vocab = widget.vocabs[currentIndex];
    ref.read(updateSRSUseCaseProvider).execute(vocab, quality);
    ref.read(progressNotifierProvider(vocab.level).notifier).updateProgress(
      currentIndex + 1,
      ((currentIndex + 1) / widget.vocabs.length * 100),
    );
    _nextCard();
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
    final vocab = widget.vocabs[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'فلش‌کارت',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() => showAnswer = !showAnswer),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.grey, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vocab.word,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (showAnswer) ...[
                  Text(
                    vocab.persian,
                    style: const TextStyle(fontFamily: 'Vazir', fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vocab.definition,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'مثال: ${vocab.example}',
                    style: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
                  ),
                ],
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 30),
                  onPressed: () => _speak(vocab.word),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _markAsLearned(5),
            child: const Icon(Icons.check),
            backgroundColor: Colors.green,
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => _markAsLearned(0),
            child: const Icon(Icons.close),
            backgroundColor: Colors.red,
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _nextCard,
            child: const Icon(Icons.skip_next),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}