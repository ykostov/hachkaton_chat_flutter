import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';
import '../services/tts_service.dart'; // Import the TTS service

class ShopChatScreen extends StatefulWidget {
  @override
  _ShopChatScreenState createState() => _ShopChatScreenState();
}

class _ShopChatScreenState extends State<ShopChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final TtsService _ttsService = TtsService(); // Initialize TTS service

  @override
  void initState() {
    super.initState();
    // Initialize TTS
    _ttsService.initialize();
    
    // Add initial welcome message
    _addMessage(
      'Welcome to the chat! How can I help you today?',
      false,
      'Assistant',
      DateTime.now(),
    );
  }

  void _addMessage(String text, bool isMe, String sender, DateTime time) {
    setState(() {
      _messages.add({
        'text': text,
        'isMe': isMe,
        'sender': sender,
        'time': time,
      });
    });
    
    // Read assistant messages aloud
    if (!isMe) {
      _ttsService.speak(text);
    }
  }

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text;
    _messageController.clear();
    
    // Add user message
    _addMessage(
      messageText,
      true,
      'Me',
      DateTime.now(),
    );

    // Simulate typing
    setState(() {
      _isTyping = true;
    });

    // Simulate response after delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
      });
      
      _addMessage(
        "The closest shop for your needs is 'Fantastiko F36'. Do you want locations?",
        false,
        'Assistant',
        DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App bar with TTS toggle
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[200],
          child: Row(
            children: [
              Text(
                "Voice Feedback", 
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              Switch(
                value: _ttsService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _ttsService.toggleTts();
                  });
                },
              ),
              if (_ttsService.isSpeaking)
                IconButton(
                  icon: Icon(Icons.stop_circle),
                  onPressed: () {
                    _ttsService.stop();
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _messages.length,
            itemBuilder: (ctx, index) {
              final message = _messages[index];
              return MessageBubble(
                message: message['text'],
                isMe: message['isMe'],
                senderName: message['sender'],
                time: message['time'],
              );
            },
          ),
        ),
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 16,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text('Assistant is typing...'),
              ],
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
                  onPressed: _handleSendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Stop any ongoing speech when disposing
    _ttsService.stop();
    _messageController.dispose();
    super.dispose();
  }
}