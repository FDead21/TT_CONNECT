import '../models/user_profile.dart';

class MockUserService {
  final Map<String, UserProfile> _users = {
    'current_user': UserProfile(
      name: 'Fernando Delvecchio',
      employeeId: 'TT23090028',
      email: 'ad.fernando@taekwang.com',
      department: 'HRIO',
      profilePictureUrl: 'https://i.pravatar.cc/150?img=11',
    ),
    'user_1': UserProfile(
      name: 'User 1',
      employeeId: 'ID-10001',
      email: 'user.1@company.co.id',
      department: 'Engineering',
      profilePictureUrl: 'https://i.pravatar.cc/150?img=0',
    ),
    'user_2': UserProfile(
      name: 'User 2',
      employeeId: 'ID-10002',
      email: 'user.2@company.co.id',
      department: 'IT Support',
      profilePictureUrl: 'https://i.pravatar.cc/150?img=1',
    ),
  };

  Future<UserProfile> fetchCurrentUserProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return _users['current_user']!;
  }

  Future<UserProfile> fetchUserProfileById(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _users[userId] ?? _users['user_1']!; 
  }

}