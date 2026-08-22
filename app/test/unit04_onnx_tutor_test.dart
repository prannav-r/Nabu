import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/features/tutor/services/onnx_tutor_service.dart';

void main() {
  group('Unit 04 - Offline ONNX Tutor Service Tests', () {
    late OnnxTutorService tutorService;

    setUp(() {
      tutorService = OnnxTutorService();
    });

    test('Initializes offline model without error', () async {
      await tutorService.initialize();
      expect(tutorService.isInitialized, true);
    });

    test('Answers photosynthesis question completely offline', () async {
      final response = await tutorService.askQuestion('What is photosynthesis?');
      expect(response.isOffline, true);
      expect(response.text.contains('Photosynthesis'), true);
      expect(response.text.contains('Glucose + Oxygen'), true);
      expect(response.inferenceLatency.inMilliseconds >= 0, true);
    });

    test('Answers solar system question offline', () async {
      final response = await tutorService.askQuestion('Tell me about planets and Mars in solar system');
      expect(response.isOffline, true);
      expect(response.text.contains('Mars'), true);
      expect(response.text.contains('Solar System'), true);
    });

    test('Handles empty prompt gracefully without crashing', () async {
      final response = await tutorService.askQuestion('');
      expect(response.text.isNotEmpty, true);
      expect(response.isOffline, true);
    });
  });
}
