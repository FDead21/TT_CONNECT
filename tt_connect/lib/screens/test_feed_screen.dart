import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'image_view_screen.dart';
import 'create_post_screen.dart';
import 'user_profile_screen.dart';
import 'comment_screen.dart';
import '../models/post.dart';
import '../services/mock_post_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final MockPostService _postService = MockPostService();
  late Future<List<Post>> _postsFuture;

  final bool _isManager = true;

  final List<Post> _posts = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false; 
  bool _isLoadingMore = false; 
  bool _hasMoreData = true; 
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchInitialPosts(); 

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        _fetchMorePosts();
      }
    });
  }

  Future<void> _fetchInitialPosts() async {
    setState(() {
      _isLoading = true;
    });
    final newPosts = await _postService.fetchPosts(page: 1);
    setState(() {
      _posts.clear();
      _posts.addAll(newPosts);
      _isLoading = false;
      _currentPage = 1;
      _hasMoreData = newPosts.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); 
    super.dispose();
  }

  Future<void> _fetchMorePosts() async {
    if (!_hasMoreData || _isLoadingMore)
      return; 

    setState(() {
      _isLoadingMore = true;
    });

    final newPosts = await _postService.fetchPosts(page: _currentPage + 1);

    setState(() {
      _posts.addAll(newPosts);
      _isLoadingMore = false;
      _currentPage++;
      if (newPosts.isEmpty) {
        _hasMoreData = false;
      }
    });
  }

  void _navigateToCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreatePostScreen(),
      ), 
    );
  }

  Future<void> _refreshFeed() async {
    await _fetchInitialPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Feed'),
        backgroundColor: const Color(0xFF00ABA2),
        elevation: 1,
      ),
      body:
          _isLoading
              ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const PostCardSkeleton(),
                ),
              )
              : RefreshIndicator(
                onRefresh: _refreshFeed,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      _posts.length +
                      (_hasMoreData
                          ? 1
                          : 0), 
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return PostCard(post: _posts[index]);
                  },
                ),
              ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String? _firstUrl;

  @override
  void initState() {
    super.initState();
    _firstUrl = _findFirstUrl(widget.post.postText);
  }

  String? _findFirstUrl(String text) {
    RegExp urlRegex = RegExp(
      r"(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+",
    );
    Match? match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  void _toggleLike() {
    setState(() {
      if (widget.post.isLikedByCurrentUser) {
        widget.post.likesCount--;
        widget.post.isLikedByCurrentUser = false;
      } else {
        widget.post.likesCount++;
        widget.post.isLikedByCurrentUser = true;
      }
    });
  }

  void _showComments() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CommentScreen(postId: widget.post.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.post.authorAvatarUrl),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.post.timestamp.hour}:${widget.post.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            ParsedText(
              text: widget.post.postText,
              style: Theme.of(context).textTheme.bodyMedium,
              parse: <MatchText>[
                MatchText(
                  pattern: r"\B#\w+", 
                  style: TextStyle(color: Theme.of(context).primaryColor),
                  onTap: (tag) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on hashtag: $tag')),
                    );
                  },
                ),
                MatchText(
                  pattern: r"\B@\w+", 
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: (mention) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on mention: $mention')),
                    );
                  },
                ),
              ],
            ),
            if (widget.post.postImageUrl != null)
              GestureDetector()
            else if (_firstUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AnyLinkPreview(
                  link: _firstUrl!,
                  displayDirection: UIDirection.uiDirectionHorizontal,
                  showMultimedia: true,
                  bodyMaxLines: 3,
                  bodyTextOverflow: TextOverflow.ellipsis,
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 8),
            if (widget.post.postImageUrl != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              UserProfileScreen(userId: widget.post.authorId),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.post.authorAvatarUrl,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // ...
                      ],
                    ),
                  ],
                ),
              ),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.post.likesCount} Likes',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '${widget.post.commentsCount} Comments',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  icon:
                      widget.post.isLikedByCurrentUser
                          ? Icons.thumb_up_alt
                          : Icons.thumb_up_alt_outlined,
                  label: 'Like',
                  color:
                      widget.post.isLikedByCurrentUser
                          ? Theme.of(context).primaryColor
                          : Colors.grey[700],
                  onPressed: _toggleLike, 
                ),
                _actionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  color: Colors.grey[700],
                  onPressed: _showComments, 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color? color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
    );
  }
}

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              const CircleAvatar(),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 14, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(width: 60, height: 12, color: Colors.white),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Body text skeleton
          Container(width: double.infinity, height: 14, color: Colors.white),
          const SizedBox(height: 6),
          Container(width: double.infinity, height: 14, color: Colors.white),
          const SizedBox(height: 6),
          Container(width: 200, height: 14, color: Colors.white),
          const SizedBox(height: 12),
          // Image skeleton
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(width: double.infinity, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
