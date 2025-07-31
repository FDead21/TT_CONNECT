import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false;

  Future<void> _submitPost() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot create an empty post.')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    print('Post submitted: ${_textController.text}');

    setState(() {
      _isPosting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created successfully!'), backgroundColor: Colors.green),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'), backgroundColor: const Color(0xFF00ABA2),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isPosting
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : TextButton(
                    onPressed: _submitPost,
                    child: const Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: const [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Mocking Budi Hartono
                ),
                SizedBox(width: 12),
                Text('Fernando Delvecchio', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null, 
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Photo functionality not implemented yet.')),
                    );
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Add Photo'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}