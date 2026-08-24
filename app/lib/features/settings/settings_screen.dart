import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';
import '../auth/services/client_auth_service.dart';
import '../sync/services/client_sync_service.dart';
import '../sync/services/connectivity_service.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ClientAuthService _authService = ClientAuthService();
  final ClientSyncService _syncService = ClientSyncService();
  final ConnectivityService _connectivity = ConnectivityService();

  late TextEditingController _urlController;
  bool _isTestingConnection = false;
  String? _connectionTestResult;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _syncService.backendUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    _syncService.backendUrl = url;

    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    final isHealthy = await _connectivity.checkConnection(url);

    if (mounted) {
      setState(() {
        _isTestingConnection = false;
        _connectionTestResult = isHealthy
            ? 'Connected: FastAPI Backend is online & responsive'
            : 'Backend unreachable: App is operating in full Offline Mode';
      });
    }
  }

  void _showAuthDialog({required bool isRegister}) {
    final userCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRegister ? 'Register Student Cloud Account' : 'Sign In to Cloud Sync'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              if (isRegister)
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final result = isRegister
                  ? await _authService.register(
                      username: userCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                    )
                  : await _authService.login(
                      usernameOrEmail: userCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                    );

              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.success
                        ? 'Successfully logged in as ${result.username}!'
                        : (result.errorMessage ?? 'Authentication failed.')),
                    backgroundColor: result.success ? Colors.green : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: Text(isRegister ? 'Register' : 'Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings & Connectivity'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, _) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: currentMode == ThemeMode.dark,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool isDark) {
                    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16),
          _buildSectionHeader('Student Profile & Authentication'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      _authService.currentUsername ?? 'Local Student',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _authService.isAuthenticated
                          ? 'Cloud Authenticated (Sync Ready)'
                          : 'Local Offline Profile',
                    ),
                    trailing: OfflineStatusIndicator(
                      status: _authService.isAuthenticated
                          ? SyncStatus.onlineSynced
                          : SyncStatus.offline,
                    ),
                  ),
                  Divider(height: 24, color: Theme.of(context).dividerColor),
                  if (!_authService.isAuthenticated)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showAuthDialog(isRegister: false),
                            child: Text('Sign In'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showAuthDialog(isRegister: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Register'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _authService.logout();
                          setState(() {});
                        },
                        child: Text('Sign Out (Switch to Local Only)'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildSectionHeader('Backend Sync Configuration'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'FastAPI Backend URL',
                      hintText: 'http://10.0.2.2:8000',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isTestingConnection ? null : _testConnection,
                      icon: _isTestingConnection
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(Icons.wifi_tethering_rounded, size: 18),
                      label: Text(_isTestingConnection ? 'Testing...' : 'Test Backend Connection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_connectionTestResult != null) ...[
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        _connectionTestResult!,
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildSectionHeader('Offline AI & Security'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.memory, color: Theme.of(context).colorScheme.primary),
                  title: Text('Local Inference Engine'),
                  subtitle: Text('ONNX Runtime (Zero internet required)'),
                  trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                ListTile(
                  leading: Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.primary),
                  title: Text('Security & Privacy'),
                  subtitle: Text('No cloud DB secrets in app; passwords bcrypt-hashed on server'),
                  trailing: Icon(Icons.lock_outline, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey), size: 20),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                ListTile(
                  leading: Icon(Icons.info_outline, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                  title: Text('App Version'),
                  trailing: Text('0.1.0 (MVP Complete)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
        ),
      ),
    );
  }
}
