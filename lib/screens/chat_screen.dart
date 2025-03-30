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
    await _authService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
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
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            // This would send the message in a real app
                            // For now, we'll just clear the input
                            _messageController.clear();
                          },
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