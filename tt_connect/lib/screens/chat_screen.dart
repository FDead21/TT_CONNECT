import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tt_connect/services/api_service.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../services/auth_provider.dart';
import '../services/socket_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScreen({
    Key? key,
    required this.roomId,
    required this.roomName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Timer? _typingTimer;
  Set<String> _typingUsers = {};

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await SocketService.connect();
    SocketService.joinRoom(widget.roomId);
    
    // Add listeners
    SocketService.addMessageListener(_onNewMessage);
    SocketService.addTypingListener(_onTypingUpdate);
    
    await _loadMessages();
  }

  void _onNewMessage(ChatMessage message) {
    if (message.roomId == widget.roomId) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    }
  }

  void _onTypingUpdate(String empId, bool isTyping) {
    final currentUser = context.read<AuthProvider>().user;
    if (empId == currentUser?.empId) return; // Ignore own typing
    
    setState(() {
      if (isTyping) {
        _typingUsers.add(empId);
      } else {
        _typingUsers.remove(empId);
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final headers = await ApiService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/chat/rooms/${widget.roomId}/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages = (data['messages'] as List)
              .map((messageJson) => ChatMessage.fromJson(messageJson))
              .toList();
        });
        _scrollToBottom();
      }
    } catch (error) {
      print('Error loading messages: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    SocketService.sendMessage(widget.roomId, messageText);
    _messageController.clear();
    
    // Stop typing indicator
    _stopTyping();
  }

  void _onTyping() {
    SocketService.startTyping(widget.roomId);
    
    // Cancel previous timer
    _typingTimer?.cancel();
    
    // Set new timer to stop typing after 2 seconds of inactivity
    _typingTimer = Timer(Duration(seconds: 2), _stopTyping);
  }

  void _stopTyping() {
    SocketService.stopTyping(widget.roomId);
    _typingTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomName),
            if (_typingUsers.isNotEmpty)
              Text(
                '${_typingUsers.length} user${_typingUsers.length > 1 ? 's' : ''} typing...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMyMessage = message.senderId == currentUser?.empId;
                      
                      return MessageBubble(
                        message: message,
                        isMyMessage: isMyMessage,
                      );
                    },
                  ),
          ),
          
          // Message input
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onChanged: (_) => _onTyping(),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  mini: true,
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SocketService.removeMessageListener(_onNewMessage);
    SocketService.removeTypingListener(_onTypingUpdate);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}