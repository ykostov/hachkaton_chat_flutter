import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kid_user.dart';
import '../services/auth_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  KidUser? currentUser;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  // Sample messages for demonstration
  final List<Map<String, dynamic>> _sampleMessages = [
    {
      'text': 'Hi there! How are you?',
      'isMe': false,
      'sender': 'Parent Bot',
      'time': DateTime.now().subtract(Duration(minutes: 5)),
    },
    {
      'text': 'I\'m good, thanks for asking!',
      'isMe': true,
      'sender': 'Me',
      'time': DateTime.now().subtract(Duration(minutes: 4)),
    },
    {
      'text': 'What did you learn today?',
      'isMe': false,
      'sender': 'Parent Bot',
      'time': DateTime.now().subtract(Duration(minutes: 3)),
    },
    {
      'text': 'I learned about dinosaurs!',
      'isMe': true,
      'sender': 'Me',
      'time': DateTime.now().subtract(Duration(minutes: 2)),
    },
    {
      'text': 'That\'s awesome! Tell me more about it.',
      'isMe': false,
      'sender': 'Parent Bot',
      'time': DateTime.now().subtract(Duration(minutes: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('LOGOUT'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldLogout) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final success = await _authService.logout();
      if (success) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout. Please try again.')),
        );
        setState(() {
          _isLoggingOut = false;
        });
      }
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // Here you would send the message to your backend
    // For now, just clear the input
    setState(() {
      // Add message to local state for demonstration
      _sampleMessages.add({
        'text': _messageController.text,
        'isMe': true,
        'sender': 'Me',
        'time': DateTime.now(),
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? Text('Loading...')
            : Text('Chat with Parent'),
        actions: [
          IconButton(
            icon: _isLoggingOut 
                ? SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.exit_to_app),
            onPressed: _isLoggingOut ? null : _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User info card
                Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            currentUser?.name.substring(0, 1).toUpperCase() ?? 'K',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logged in as: ${currentUser?.name ?? 'Unknown'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                currentUser?.email ?? 'No email',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.logout),
                          label: Text('Logout'),
                          onPressed: _isLoggingOut ? null : _logout,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _sampleMessages.length,
                    itemBuilder: (ctx, index) {
                      final message = _sampleMessages[index];
                      return MessageBubble(
                        message: message['text'],
                        isMe: message['isMe'],
                        senderName: message['sender'],
                        time: message['time'],
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            labelText: 'Send a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}