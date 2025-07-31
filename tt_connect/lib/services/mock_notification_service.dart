import 'package:flutter/material.dart';
import '../models/notification_message.dart';

class MockNotificationService {
  final List<NotificationMessage> _dummyData = [
    NotificationMessage(
      id: '1',
      type: NotificationType.like,
      title: 'Budi Hartono liked your post.',
      body: '"Selamat berakhir pekan! Just wanted to share a photo..."',
      timestamp: DateTime(2025, 7, 18, 9, 10),
      channelName: 'Feed', channelColor: Colors.transparent, senderName: '', 
    ),
    NotificationMessage(
      id: '2',
      type: NotificationType.comment,
      title: 'Siti Nurhaliza commented: "Wow, looks like so much fun!"',
      body: '"Selamat berakhir pekan! Just wanted to share a photo..."',
      timestamp: DateTime(2025, 7, 18, 9, 05),
      channelName: 'Feed', channelColor: Colors.transparent, senderName: '',
    ),
    NotificationMessage(
      id: '3',
      type: NotificationType.system,
      title: 'CRITICAL: Phishing Attempt Detected',
      body: 'An email with the subject "Urgent Payroll Update" is circulating. Do not click any links.',
      timestamp: DateTime(2025, 7, 18, 8, 30),
      channelName: 'IT-Security', channelColor: Colors.transparent, senderName: '',
    ),
    NotificationMessage(
      id: '4',
      type: NotificationType.like,
      title: 'Agus Salim and 2 others liked your post.',
      body: '"Heads up team! We will be rolling out the new internal software..."',
      timestamp: DateTime(2025, 7, 17, 18, 00),
      channelName: 'Feed', channelColor: Colors.transparent, senderName: '', isRead: true
    ),
  ];

  Future<List<NotificationMessage>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _dummyData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return _dummyData;
  }
}