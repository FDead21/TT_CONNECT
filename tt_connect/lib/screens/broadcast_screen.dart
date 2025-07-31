import 'package:flutter/material.dart';

enum TargetAudience { all, departments, roles }

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  TargetAudience _selectedAudience = TargetAudience.all;
  bool _isSending = false;

  final List<String> _allDepartments = [
    'HR',
    'Business Planning',
    'Development',
    'MES Operation',
    'Manufacturing Moderinization',
  ];
  final List<String> _allRoles = [
    'Operator',
    'Staff',
    'Chief',
    'Manager',
    'Team Leader',
    'Group Leader',
    'VSM',
    'Plant Manager',
    'Director',
  ];

  final Set<String> _selectedDepartments = {};
  final Set<String> _selectedRoles = {};

  void _sendBroadcast() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });
    await Future.delayed(const Duration(seconds: 2));

    print('--- BROADCAST SENT ---');
    print('Title: ${_titleController.text}');
    print('Body: ${_bodyController.text}');
    print('Target: ${_selectedAudience.name}');
    if (_selectedAudience == TargetAudience.departments) {
      print('Selected Departments: ${_selectedDepartments.join(', ')}');
    }
    if (_selectedAudience == TargetAudience.roles) {
      print('Selected Roles: ${_selectedRoles.join(', ')}');
    }
    print('----------------------');

    setState(() {
      _isSending = false;
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Broadcast sent successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Broadcast'), backgroundColor: const Color(0xFF00ABA2),
        actions: [
          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            IconButton(icon: const Icon(Icons.send), onPressed: _sendBroadcast),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Add Photo'),
                  onPressed: () {
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.videocam),
                  label: const Text('Add Video'),
                  onPressed: () {
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Target Audience',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(
                  label: const Text('All Employees'),
                  selected: _selectedAudience == TargetAudience.all,
                  onSelected: (selected) {
                    setState(() => _selectedAudience = TargetAudience.all);
                  },
                ),
                ChoiceChip(
                  label: const Text('By Department'),
                  selected: _selectedAudience == TargetAudience.departments,
                  onSelected: (selected) {
                    setState(
                      () => _selectedAudience = TargetAudience.departments,
                    );
                  },
                ),
                ChoiceChip(
                  label: const Text('By Role'),
                  selected: _selectedAudience == TargetAudience.roles,
                  onSelected: (selected) {
                    setState(() => _selectedAudience = TargetAudience.roles);
                  },
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildConditionalFilters(),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionalFilters() {
    if (_selectedAudience == TargetAudience.departments) {
      return _buildFilterChipList(
        title: 'Select Departments',
        allItems: _allDepartments,
        selectedItems: _selectedDepartments,
      );
    } else if (_selectedAudience == TargetAudience.roles) {
      return _buildFilterChipList(
        title: 'Select Roles',
        allItems: _allRoles,
        selectedItems: _selectedRoles,
      );
    } else {
      return Container();
    }
  }
  
  Widget _buildFilterChipList({
    required String title,
    required List<String> allItems,
    required Set<String> selectedItems,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children:
                allItems.map((item) {
                  return FilterChip(
                    label: Text(item),
                    selected: selectedItems.contains(item),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedItems.add(item);
                        } else {
                          selectedItems.remove(item);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
