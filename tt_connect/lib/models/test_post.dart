class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String postText;
  final String? postImageUrl;
  final DateTime timestamp;
  int likesCount; 
  int commentsCount; 
  bool isLikedByCurrentUser; 

  Post({
    required this.id,
    required this.authorId, 
    required this.authorName,
    required this.authorAvatarUrl,
    required this.postText,
    this.postImageUrl,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    this.isLikedByCurrentUser = false, 
  });
}