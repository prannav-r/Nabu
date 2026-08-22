import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Student Profile'),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text(
                'Student',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Local Profile: Student #1'),
              trailing: const OfflineStatusIndicator(status: SyncStatus.offline),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Offline AI'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.memory, color: AppColors.primary),
                  title: const Text('Inference Engine'),
                  subtitle: const Text('ONNX Runtime (Local CPU)'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('Active', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Application'),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
                  title: Text('Version'),
                  trailing: Text('0.1.0 (MVP)'),
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
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
