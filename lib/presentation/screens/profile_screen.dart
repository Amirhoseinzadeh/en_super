import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/leaderboard_entry.dart';
import '../providers/progress_provider.dart';

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final datasource = LocalDatasource();
  return await datasource.getUserProfile('user1');
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String? _avatarPath;
  final picker = ImagePicker();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
    }
  }

  void _saveProfile() async {
    final datasource = LocalDatasource();
    final profile = UserProfile(
      userId: 'user1',
      username: _usernameController.text.isEmpty ? 'کاربر نمونه' : _usernameController.text,
      avatarPath: _avatarPath,
    );
    await datasource.saveUserProfile(profile);
    final leaderboardEntry = LeaderboardEntry(
      userId: 'user1',
      username: profile.username,
      score: (await datasource.getLeaderboard()).firstWhere((entry) => entry.userId == 'user1', orElse: () => LeaderboardEntry(userId: 'user1', username: profile.username, score: 0, streak: 0)).score,
      streak: (await ref.read(progressNotifierProvider('A1')).valueOrNull)?.streak ?? 0,
    );
    await datasource.updateLeaderboard(leaderboardEntry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('پروفایل ذخیره شد', style: TextStyle(fontFamily: 'Vazir'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final progressAsync = ref.watch(progressNotifierProvider('A1'));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'پروفایل کاربر',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade100,
      ),
      body: profileAsync.when(
        data: (profile) {
          _usernameController.text = profile?.username ?? 'کاربر نمونه';
          _avatarPath = profile?.avatarPath;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                    child: _avatarPath == null
                        ? const Icon(Icons.person, size: 50, color: Colors.blue)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _pickAvatar,
                  child: const Text(
                    'انتخاب تصویر پروفایل',
                    style: TextStyle(fontFamily: 'Vazir', color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'نام کاربری',
                    labelStyle: TextStyle(fontFamily: 'Vazir'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('ذخیره تغییرات', style: TextStyle(fontFamily: 'Vazir')),
                ),
                const SizedBox(height: 20),
                progressAsync.when(
                  data: (progress) => Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'لغات آموخته‌شده: ${progress.learnedCount}',
                            style: const TextStyle(fontFamily: 'Vazir', fontSize: 16),
                          ),
                          Text(
                            'روزهای متوالی: ${progress.streak}',
                            style: const TextStyle(fontFamily: 'Vazir', fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('خطا: $error', style: const TextStyle(fontFamily: 'Vazir')),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطا: $error', style: const TextStyle(fontFamily: 'Vazir'))),
      ),
    );
  }
}