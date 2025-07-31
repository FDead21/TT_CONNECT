class Post {
  final String postId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final PostAuthor author;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  Post({
    required this.postId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.author,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'].toString(),
      content: json['content'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      author: PostAuthor.fromJson(json['author']),
      likesCount: json['likesCount'],
      commentsCount: json['commentsCount'],
      isLiked: json['isLiked'],
    );
  }
}

class PostAuthor {
  final String? userId;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;

  PostAuthor({
    this.userId,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      userId: json['userId']?.toString(),
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  String get fullName => '$firstName $lastName';
}