
// lib/presentation/build/build_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class BuildHistoryScreen extends StatefulWidget {
  final String applicationId;

  const BuildHistoryScreen({super.key, required this.applicationId});

  @override
  State<BuildHistoryScreen> createState() => _BuildHistoryScreenState();
}

class _BuildHistoryScreenState extends State<BuildHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    // This would fetch build history from the API
    // For now, showing a placeholder

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Mock data
        itemBuilder: (context, index) {
          return _buildHistoryCard(index);
        },
      ),
    );
  }

  Widget _buildHistoryCard(int index) {
    final isSuccess = index % 2 == 0;
    final status = isSuccess ? 'success' : 'failed';
    final date = DateTime.now().subtract(Duration(days: index));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSuccess
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.check : Icons.close,
            color: isSuccess ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text('Build #${1000 + index}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormat('MMM dd, yyyy - HH:mm').format(date)),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(status),
                const SizedBox(width: 8),
                if (isSuccess)
                  Text(
                    '12.5 MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSuccess)
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  // Download APK
                },
                tooltip: 'Download APK',
              ),
            IconButton(
              icon: const Icon(Icons.description),
              onPressed: () {
                // View logs
              },
              tooltip: 'View Logs',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'success' ? AppColors.success : AppColors.error;
    final label = status == 'success' ? 'Success' : 'Failed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}