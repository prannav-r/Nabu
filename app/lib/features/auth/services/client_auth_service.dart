import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../sync/services/client_sync_service.dart';

class AuthResult {
  final bool success;
  final String? token;
  final String? username;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.token,
    this.username,
    this.errorMessage,
  });
}

class ClientAuthService {
  static ClientAuthService? _instance;
  final ClientSyncService _syncService;

  String? _authToken;
  String? _currentUsername;

  ClientAuthService._({ClientSyncService? syncService})
      : _syncService = syncService ?? ClientSyncService();

  factory ClientAuthService({ClientSyncService? syncService}) {
    _instance ??= ClientAuthService._(syncService: syncService);
    return _instance!;
  }

  bool get isAuthenticated => _authToken != null;
  String? get currentUsername => _currentUsername ?? 'Local Student';
  String? get authToken => _authToken;

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${_syncService.backendUrl}/auth/register');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'] as String?;
        _currentUsername = data['user']['username'] as String?;
        return AuthResult(
          success: true,
          token: _authToken,
          username: _currentUsername,
        );
      } else {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: false,
          errorMessage: (data['detail'] as String?) ?? 'Registration failed.',
        );
      }
    } catch (e) {
      debugPrint('[ClientAuthService] Registration error: $e');
      return const AuthResult(
        success: false,
        errorMessage: 'Cannot reach backend server. Continue in Offline Mode.',
      );
    }
  }

  Future<AuthResult> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${_syncService.backendUrl}/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username_or_email': usernameOrEmail,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access_token'] as String?;
        _currentUsername = data['user']['username'] as String?;
        return AuthResult(
          success: true,
          token: _authToken,
          username: _currentUsername,
        );
      } else {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: false,
          errorMessage: (data['detail'] as String?) ?? 'Login failed.',
        );
      }
    } catch (e) {
      debugPrint('[ClientAuthService] Login error: $e');
      return const AuthResult(
        success: false,
        errorMessage: 'Cannot reach backend server. Continue in Offline Mode.',
      );
    }
  }

  void logout() {
    _authToken = null;
    _currentUsername = null;
  }
}
