import 'dart:async';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static ConnectivityService? _instance;
  bool _isOnline = false;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  ConnectivityService._();

  factory ConnectivityService() {
    _instance ??= ConnectivityService._();
    return _instance!;
  }

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  Future<bool> checkConnection(String backendUrl) async {
    try {
      final uri = Uri.parse('$backendUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      final online = response.statusCode == 200;
      if (_isOnline != online) {
        _isOnline = online;
        _connectivityController.add(online);
      }
      return online;
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        _connectivityController.add(false);
      }
      return false;
    }
  }

  void dispose() {
    _connectivityController.close();
  }
}
