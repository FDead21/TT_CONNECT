// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../models/notification_message.dart';
import '../services/mock_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final MockNotificationService _notificationService = MockNotificationService();
  late Future<List<NotificationMessage>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.fetchNotifications();
  }

  Widget _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return CircleAvatar(backgroundColor: Colors.blue[100], child: const Icon(Icons.thumb_up, size: 20, color: Colors.blue));
      case NotificationType.comment:
        return CircleAvatar(backgroundColor: Colors.green[100], child: const Icon(Icons.comment, size: 20, color: Colors.green));
      case NotificationType.system:
        return CircleAvatar(backgroundColor: Colors.red[100], child: const Icon(Icons.security, size: 20, color: Colors.red));
      default:
        return const CircleAvatar(child: Icon(Icons.notifications));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: const Color(0xFF00ABA2),),
      body: FutureBuilder<List<NotificationMessage>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final message = notifications[index];
                return ListTile(
                  leading: _getIconForType(message.type),
                  title: Text(message.title, style: TextStyle(fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(message.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                  isThreeLine: true,
                );
              },
            );
          }
          return const Center(child: Text('No notifications.'));
        },
      ),
    );
  }
}