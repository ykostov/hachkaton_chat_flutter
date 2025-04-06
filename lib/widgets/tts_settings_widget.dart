import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class TtsSettingsWidget extends StatefulWidget {
  @override
  _TtsSettingsWidgetState createState() => _TtsSettingsWidgetState();
}

class _TtsSettingsWidgetState extends State<TtsSettingsWidget> {
  final TtsService _ttsService = TtsService();
  String _selectedLanguage = 'en-US';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _ttsService.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Voice Feedback',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _ttsService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _ttsService.toggleTts();
                  });
                },
              ),
            ],
          ),
          
          if (_ttsService.isEnabled) ...[
            SizedBox(height: 8),
            
            Text('Language:', style: TextStyle(fontWeight: FontWeight.w500)),
            
            SizedBox(height: 4),
            
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                    _ttsService.setLanguage(newValue);
                  });
                }
              },
              items: _ttsService.availableLanguages.entries
                  .map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
            
            if (_ttsService.isSpeaking)
              ElevatedButton.icon(
                icon: Icon(Icons.stop),
                label: Text('Stop Speaking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _ttsService.stop();
                  setState(() {});
                },
              ),
              
            // Sample text to test voice
            TextButton.icon(
              icon: Icon(Icons.play_arrow),
              label: Text('Test Voice'),
              onPressed: () {
                _ttsService.speak('This is a test of the text-to-speech system. Is it working correctly?');
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }
}