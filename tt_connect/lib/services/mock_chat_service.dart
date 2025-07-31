import '../models/chat_message.dart';
import '../models/conversation.dart';

class MockChatService {
  Future<List<Conversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Conversation(
        id: 'chat_1',
        userName: 'Siti Nurhaliza',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=25',
        lastMessage: 'Baik, Pak. Saya akan segera kerjakan.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Conversation(
        id: 'chat_2',
        userName: 'Agus Salim',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=32',
        lastMessage: 'Laporannya sudah saya kirim via email.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ChatMessage(text: 'Baik, Pak. Saya akan segera kerjakan.', timestamp: DateTime.now().subtract(const Duration(minutes: 10)), isSentByMe: true),
      ChatMessage(text: 'Siti, tolong siapkan laporan penjualan untuk Q2 ya.', timestamp: DateTime.now().subtract(const Duration(minutes: 12)), isSentByMe: false),
    ];
  }
}