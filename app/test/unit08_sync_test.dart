import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/features/sync/services/client_sync_service.dart';

void main() {
  group('Unit 08 - Client Synchronization Tests', () {
    test('SyncResult structure and defaults', () {
      const result = SyncResult(
        success: true,
        syncedAttemptsCount: 2,
        syncedLessonsCount: 1,
        message: 'Sync succeeded',
        syncedAt: '2026-08-22T03:00:00Z',
      );

      expect(result.success, true);
      expect(result.syncedAttemptsCount, 2);
      expect(result.syncedLessonsCount, 1);
      expect(result.syncedAt, '2026-08-22T03:00:00Z');
    });

    test('ClientSyncService preserves base URL configuration', () {
      final service = ClientSyncService();
      service.backendUrl = 'http://localhost:8000/';
      expect(service.backendUrl, 'http://localhost:8000');
    });
  });
}
