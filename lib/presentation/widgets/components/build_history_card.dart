// lib/presentation/applications/widgets/components/build_history_card.dart
import 'package:flutter/material.dart';
import '../../../../data/models/build_history.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../utils/build_status_utils.dart';

class BuildHistoryCard extends StatelessWidget {
  final BuildHistory buildHistory;

  const BuildHistoryCard({
    super.key,
    required this.buildHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = buildHistory.status == 'success';
    final color = BuildStatusUtils.getBuildStatusColor(buildHistory.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.check :
            buildHistory.status == 'failed' ? Icons.close : Icons.sync,
            color: color,
          ),
        ),
        title: Text('Build #${buildHistory.buildId.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Helpers.formatDateTime(buildHistory.buildStartTime)),
            if (buildHistory.durationDisplay != null)
              Text('Duration: ${buildHistory.durationDisplay}'),
            if (buildHistory.apkSizeMb != null && isSuccess)
              Text('Size: ${buildHistory.apkSizeMb!.toStringAsFixed(2)} MB'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSuccess && buildHistory.apkFile != null)
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  // TODO: Download APK
                },
                tooltip: 'Download APK',
              ),
            IconButton(
              icon: const Icon(Icons.description),
              onPressed: () {
                // TODO: View logs
              },
              tooltip: 'View Logs',
            ),
          ],
        ),
      ),
    );
  }
}