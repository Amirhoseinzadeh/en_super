import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 3)
class UserProfile {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String? avatarPath;

  UserProfile({
    required this.userId,
    required this.username,
    this.avatarPath,
  });
}