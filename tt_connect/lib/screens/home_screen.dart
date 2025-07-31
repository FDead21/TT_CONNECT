// lib/screens/home_screen.dart (Updated for 4 tabs)

import 'package:flutter/material.dart';
import 'create_post_screen.dart';
import 'feed_screen.dart';
import 'chat_list_screen.dart';
import 'notifications_screen.dart';
import 'user_profile_screen.dart';
import 'broadcast_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final bool _isManager = true;

  void _navigateToCreatePost() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
  }

  // Handler for creating a broadcast
  void _navigateToBroadcast() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BroadcastScreen()));
  }

  static const List<Widget> _screens = <Widget>[
    FeedScreen(),
    ChatListScreen(),
    NotificationsScreen(), 
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1 || index == 2 || index == 3) {
      if (_isManager) {}
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget? _buildFab() {
    if (!_isManager) return null;

    switch (_selectedIndex) {
      case 0: 
        return FloatingActionButton(
          key: const ValueKey('add_post_fab'), 
          onPressed: _navigateToCreatePost,
          child: const Icon(Icons.add),
          tooltip: 'Create Post',
        );
      case 1: 
        return FloatingActionButton(
          key: const ValueKey('broadcast_fab'),
          onPressed: _navigateToBroadcast,
          child: const Icon(Icons.campaign),
          tooltip: 'Broadcast Message',
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chat',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications), 
            label: 'Notifications',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF00ABA2),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -30),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: _buildFab(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
