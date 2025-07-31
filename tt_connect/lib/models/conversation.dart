class Conversation {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String lastMessage;
  final DateTime timestamp;

  Conversation({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.lastMessage,
    required this.timestamp,
  });
}