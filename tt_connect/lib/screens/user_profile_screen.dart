import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../models/user_profile.dart';
import '../services/mock_user_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String? userId; 
  const UserProfileScreen({super.key, this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final MockUserService _userService = MockUserService();
  late Future<UserProfile> _userProfileFuture;

  bool get isCurrentUserProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    if (isCurrentUserProfile) {
      _userProfileFuture = _userService.fetchCurrentUserProfile();
    } else {
      _userProfileFuture = _userService.fetchUserProfileById(widget.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUserProfile ? 'My Profile' : 'User Profile'),
        backgroundColor: const Color(0xFF00ABA2),
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load profile.'));
          }
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.profilePictureUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.department,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    user.employeeId,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(user.email),
                  ),
                  if (isCurrentUserProfile) ...[
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return Container();
        },
      ),
    );
  }
}
