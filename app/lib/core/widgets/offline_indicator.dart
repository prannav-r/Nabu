import 'package:flutter/material.dart';
import '../theme.dart';

enum SyncStatus {
  offline,
  onlineSynced,
  syncing,
  syncFailed,
}

class OfflineStatusIndicator extends StatelessWidget {
  final SyncStatus status;

  const OfflineStatusIndicator({
    super.key,
    this.status = SyncStatus.offline,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String label;

    switch (status) {
      case SyncStatus.offline:
        dotColor = AppColors.textSecondary;
        label = 'Offline — Working locally';
        break;
      case SyncStatus.onlineSynced:
        dotColor = AppColors.success;
        label = 'Online — Synced';
        break;
      case SyncStatus.syncing:
        dotColor = AppColors.primary;
        label = 'Syncing...';
        break;
      case SyncStatus.syncFailed:
        dotColor = AppColors.warning;
        label = 'Sync failed — Will retry';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
