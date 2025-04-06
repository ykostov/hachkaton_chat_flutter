import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isEnabled = true;
  TtsState _ttsState = TtsState.stopped;
  String _currentLanguage = 'en-US';
  
  // Available languages
  final Map<String, String> _availableLanguages = {
    'en-US': 'English',
    'bg-BG': 'Bulgarian', // For the Bulgarian text in your app
    'ru-RU': 'Russian',
    'es-ES': 'Spanish',
    'fr-FR': 'French',
    'de-DE': 'German',
  };

  Map<String, String> get availableLanguages => _availableLanguages;
  String get currentLanguage => _currentLanguage;

  Future<void> initialize() async {
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
    });

    _flutterTts.setCancelHandler(() {
      _ttsState = TtsState.stopped;
    });

    _flutterTts.setPauseHandler(() {
      _ttsState = TtsState.paused;
    });

    _flutterTts.setContinueHandler(() {
      _ttsState = TtsState.continued;
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsState = TtsState.stopped;
      print("TTS Error: $msg");
    });
    
    // Get available voices
    try {
      var voices = await _flutterTts.getVoices;
      print("Available voices: $voices");
    } catch (e) {
      print("Failed to get voices: $e");
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_availableLanguages.containsKey(languageCode)) {
      await _flutterTts.setLanguage(languageCode);
      _currentLanguage = languageCode;
    }
  }

  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    
    if (_ttsState == TtsState.playing) {
      await _flutterTts.stop();
    }
    
    // Auto-detect language for mixed content
    if (_containsCyrillic(text) && _currentLanguage != 'bg-BG') {
      await setLanguage('en-US');
    } else if (!_containsCyrillic(text) && _currentLanguage != 'en-US') {
      await setLanguage('en-US');
    }
    
    await _flutterTts.speak(text);
  }

  bool _containsCyrillic(String text) {
    // Simple check for Cyrillic characters
    return RegExp(r'[\u0400-\u04FF]').hasMatch(text);
  }

  Future<void> stop() async {
    if (_ttsState == TtsState.playing) {
      await _flutterTts.stop();
      _ttsState = TtsState.stopped;
    }
  }

  Future<void> pause() async {
    if (_ttsState == TtsState.playing) {
      await _flutterTts.pause();
      _ttsState = TtsState.paused;
    }
  }

  void toggleTts() {
    _isEnabled = !_isEnabled;
    if (!_isEnabled && _ttsState == TtsState.playing) {
      stop();
    }
  }
  
  bool get isEnabled => _isEnabled;
  bool get isSpeaking => _ttsState == TtsState.playing;
  
  // Clean up resources
  Future<void> dispose() async {
    await stop();
    await _flutterTts.stop();
  }
}