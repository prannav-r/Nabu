import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/features/voice/services/voice_service.dart';

void main() {
  group('Unit 06 - Voice Interaction Service Tests', () {
    late VoiceService voiceService;

    setUp(() {
      voiceService = VoiceService();
    });

    test('Initializes voice service without exceptions', () async {
      await voiceService.initialize();
      expect(voiceService.isSpeechAvailable, true);
    });

    test('Voice listening state transitions correctly', () async {
      bool listeningNotified = false;

      await voiceService.startListening(
        onResult: (_) {},
        onStateChanged: (state) {
          listeningNotified = state;
        },
      );

      expect(voiceService.isListening, true);
      expect(listeningNotified, true);

      await voiceService.stopListening(
        onStateChanged: (state) {
          listeningNotified = state;
        },
      );

      expect(voiceService.isListening, false);
      expect(listeningNotified, false);
    });

    test('TTS speaking and stopping behavior', () async {
      bool completed = false;
      await voiceService.speak(
        'Hello student',
        onComplete: () {
          completed = true;
        },
      );

      expect(completed, true);
      expect(voiceService.isSpeaking, false);
    });
  });
}
