import '../models/comment.dart';

class MockCommentService {
  final Map<String, List<Comment>> _comments = {
    'post_001': [
      Comment(
        id: 'comment_1',
        authorName: 'Siti Nurhaliza',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=25',
        text: 'Wow, looks like so much fun! Great pictures!',
        timestamp: DateTime(2025, 7, 18, 8, 10),
      ),
      Comment(
        id: 'comment_2',
        authorName: 'Agus Salim',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=32',
        text: 'Couldn\'t agree more. A well-deserved break for the team.',
        timestamp: DateTime(2025, 7, 18, 8, 12),
      ),
    ],
  };

  Future<List<Comment>> fetchComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _comments[postId] ?? []; 
  }
}