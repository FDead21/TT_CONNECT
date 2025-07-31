import '../models/post.dart';

class MockPostService {
  
  final List<Post> _allPosts = List.generate(30, (index) {
    final authorId = 'user_${index % 5 + 1}'; 
    return Post(
      id: 'post_${index + 1}',
      authorId: authorId, 
      authorName: 'User ${index % 5 + 1}',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=${index % 10}',
      postText:
          'This is post number ${index + 1}. Find job here! https://tkg.jobseeker.software/ #TKGBisaBisaBisa',
      timestamp: DateTime.now().subtract(Duration(hours: index)),
      likesCount: (index + 1) * 3,
      commentsCount: (index + 1) % 5,
    );
  });

  Future<List<Post>> fetchPosts({int page = 1, int limit = 10}) async {
    print('Fetching posts... page: $page, limit: $limit');
    await Future.delayed(const Duration(seconds: 1));

    final int startIndex = (page - 1) * limit;
    final int endIndex = startIndex + limit;

    if (startIndex >= _allPosts.length) {
      return []; 
    }

    return _allPosts.sublist(
      startIndex,
      endIndex > _allPosts.length ? _allPosts.length : endIndex,
    );
  }
}
