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
        dotColor = (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey);
        label = 'Offline — Working locally';
        break;
      case SyncStatus.onlineSynced:
        dotColor = Colors.green;
        label = 'Online — Synced';
        break;
      case SyncStatus.syncing:
        dotColor = Theme.of(context).colorScheme.primary;
        label = 'Syncing...';
        break;
      case SyncStatus.syncFailed:
        dotColor = Colors.orange;
        label = 'Sync failed — Will retry';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
