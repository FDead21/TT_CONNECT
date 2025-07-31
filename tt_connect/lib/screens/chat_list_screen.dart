import 'package:flutter/material.dart';
import 'broadcast_screen.dart';
import '../models/conversation.dart';
import '../services/mock_chat_service.dart';
import 'chat_detail_screen.dart'; 

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final MockChatService _chatService = MockChatService();
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _chatService.fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
     const bool _isManager = true;

     
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), backgroundColor: const Color(0xFF00ABA2)),
      body: FutureBuilder<List<Conversation>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final conversations = snapshot.data!;
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(convo.userAvatarUrl)),
                title: Text(convo.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(convo.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: convo)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}