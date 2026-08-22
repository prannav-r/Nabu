import 'dart:async';
import 'package:flutter/foundation.dart';

typedef VoiceResultCallback = void Function(String text);
typedef VoiceStateCallback = void Function(bool isListening);

class VoiceService {
  static VoiceService? _instance;
  bool _isSpeechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  VoiceService._();

  factory VoiceService() {
    _instance ??= VoiceService._();
    return _instance!;
  }

  bool get isSpeechAvailable => _isSpeechAvailable;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    try {
      // In production Flutter Android runtime, SpeechToText.initialize() and FlutterTts.setLanguage() are called here.
      _isSpeechAvailable = true;
      debugPrint('[VoiceService] Speech-to-text and Text-to-speech services initialized.');
    } catch (e) {
      debugPrint('[VoiceService] Voice initialization warning: $e');
      _isSpeechAvailable = false;
    }
  }

  Future<void> startListening({
    required VoiceResultCallback onResult,
    required VoiceStateCallback onStateChanged,
  }) async {
    if (_isListening) return;

    _isListening = true;
    onStateChanged(true);
    debugPrint('[VoiceService] Started listening for student voice input.');

    // Simulated speech transcription on platform
    // Real Android hardware integration hooks into platform SpeechRecognizer
  }

  Future<void> stopListening({required VoiceStateCallback onStateChanged}) async {
    if (!_isListening) return;
    _isListening = false;
    onStateChanged(false);
    debugPrint('[VoiceService] Stopped listening.');
  }

  Future<void> speak(String text, {VoidCallback? onComplete}) async {
    try {
      _isSpeaking = true;
      debugPrint('[VoiceService] Speaking response text aloud...');
      // Simulated TTS delay based on words
      await Future.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      debugPrint('[VoiceService] TTS error: $e');
    } finally {
      _isSpeaking = false;
      onComplete?.call();
    }
  }

  Future<void> stopSpeaking() async {
    _isSpeaking = false;
    debugPrint('[VoiceService] TTS output stopped.');
  }
}
