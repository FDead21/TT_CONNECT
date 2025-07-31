class Comment {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.text,
    required this.timestamp,
  });
}