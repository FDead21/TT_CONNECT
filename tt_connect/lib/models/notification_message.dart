import 'package:flutter/material.dart';

// An enum to represent the message priority
enum Priority { standard, important, critical }
enum NotificationType { like, comment, system }

class NotificationMessage {
  final String id;
  final NotificationType type;
  final String channelName;
  final Color channelColor;
  final String senderName;
  final String? senderAvatarUrl;
  final String title;
  final String body;
  final DateTime timestamp;
  final Priority priority;
  bool isRead;

  NotificationMessage({
    required this.id,
    required this.type,
    required this.channelName,
    required this.channelColor,
    required this.senderName,
    this.senderAvatarUrl,
    required this.title,
    required this.body,
    required this.timestamp,
    this.priority = Priority.standard,
    this.isRead = false,
  });
}

