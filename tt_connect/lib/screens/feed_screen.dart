import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_widget.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final headers = await ApiService._getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/posts/feed?page=1&limit=10'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _posts = (data['posts'] as List)
              .map((postJson) => Post.fromJson(postJson))
              .toList();
          _hasMore = data['hasMore'];
          _currentPage = 1;
        });
      }
    } catch (error) {
      print('Error loading more posts: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Feed'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _posts.isEmpty && _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return PostWidget(
                    post: _posts[index],
                    onLikeToggle: _toggleLike,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
          if (result == true) {
            _loadPosts(); // Refresh feed after creating post
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _toggleLike(String postId) async {
    try {
      final headers = await ApiService._getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/posts/$postId/like'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final postIndex = _posts.indexWhere((p) => p.postId == postId);
          if (postIndex != -1) {
            final post = _posts[postIndex];
            _posts[postIndex] = Post(
              postId: post.postId,
              content: post.content,
              imageUrl: post.imageUrl,
              createdAt: post.createdAt,
              author: post.author,
              likesCount: data['liked'] 
                  ? post.likesCount + 1 
                  : post.likesCount - 1,
              commentsCount: post.commentsCount,
              isLiked: data['liked'],
            );
          }
        });
      }
    } catch (error) {
      print('Error toggling like: $error');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}