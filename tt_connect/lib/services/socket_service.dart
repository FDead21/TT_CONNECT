import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import '../models/chat_message.dart';
import 'api_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static final List<Function(ChatMessage)> _messageListeners = [];
  static final List<Function(String, bool)> _typingListeners = [];

  static Future<void> connect() async {
    final token = await ApiService.getToken();
    if (token == null) return;

    _socket = IO.io('http://10.0.2.2:3000', {
      'transports': ['websocket'],
      'auth': {'token': token}
    });

    _socket!.connect();

    _socket!.on('connect', (_) {
      print('Connected to chat server');
    });

    _socket!.on('disconnect', (_) {
      print('Disconnected from chat server');
    });

    _socket!.on('new_message', (data) {
      final message = ChatMessage.fromJson(data);
      for (var listener in _messageListeners) {
        listener(message);
      }
    });

    _socket!.on('user_typing', (data) {
      final userId = data['userId'];
      final isTyping = data['isTyping'];
      for (var listener in _typingListeners) {
        listener(userId, isTyping);
      }
    });

    _socket!.on('room_messages', (data) {
      // Handle initial room messages
      print('Received room messages: ${data.length}');
    });

    _socket!.on('error', (error) {
      print('Socket error: $error');
    });
  }

  static void joinRoom(String roomId) {
    _socket?.emit('join_room', roomId);
  }

  static void sendMessage(String roomId, String message) {
    _socket?.emit('send_message', {
      'roomId': roomId,
      'message': message,
      'messageType': 'text'
    });
  }

  static void startTyping(String roomId) {
    _socket?.emit('typing_start', roomId);
  }

  static void stopTyping(String roomId) {
    _socket?.emit('typing_stop', roomId);
  }

  static void addMessageListener(Function(ChatMessage) listener) {
    _messageListeners.add(listener);
  }

  static void removeMessageListener(Function(ChatMessage) listener) {
    _messageListeners.remove(listener);
  }

  static void addTypingListener(Function(String, bool) listener) {
    _typingListeners.add(listener);
  }

  static void removeTypingListener(Function(String, bool) listener) {
    _typingListeners.remove(listener);
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _messageListeners.clear();
    _typingListeners.clear();
  }
}