import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/features/auth/services/client_auth_service.dart';

void main() {
  group('Unit 09 - Client Authentication & Security State Tests', () {
    test('Auth initial state is unauthenticated (offline local student)', () {
      final auth = ClientAuthService();
      expect(auth.isAuthenticated, false);
      expect(auth.currentUsername, 'Local Student');
    });

    test('Logout clears local tokens cleanly', () {
      final auth = ClientAuthService();
      auth.logout();
      expect(auth.isAuthenticated, false);
      expect(auth.authToken, null);
    });
  });
}
