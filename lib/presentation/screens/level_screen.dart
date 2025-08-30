import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocab_provider.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'story_screen.dart';

class LevelScreen extends ConsumerWidget {
  final String level;

  const LevelScreen({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabsProvider(level));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سطح $level',
          style: const TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
      body: vocabAsync.when(
        data: (vocabs) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLearningOption(
                    context,
                    title: 'فلش‌کارت',
                    icon: Icons.card_giftcard,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardScreen(vocabs: vocabs),
                      ),
                    ),
                  ),
                  _buildLearningOption(
                    context,
                    title: 'آزمون',
                    icon: Icons.quiz,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(vocabs: vocabs),
                      ),
                    ),
                  ),
                  _buildLearningOption(
                    context,
                    title: 'داستان',
                    icon: Icons.book,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryScreen(vocabs: vocabs),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: vocabs.length,
                  itemBuilder: (context, index) {
                    final vocab = vocabs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(
                          vocab.word,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          vocab.persian,
                          style: const TextStyle(fontFamily: 'Vazir'),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () {
                            // تلفظ با flutter_tts
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(child: Text('خطا در بارگذاری لغات')),
      ),
    );
  }

  Widget _buildLearningOption(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.blue.shade400),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontFamily: 'Vazir', fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}