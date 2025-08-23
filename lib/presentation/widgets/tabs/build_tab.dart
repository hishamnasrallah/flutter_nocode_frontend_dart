// lib/presentation/widgets/tabs/build_tab.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/build_history.dart';
import '../../../../providers/application_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../components/build_history_card.dart';

class BuildTab extends StatelessWidget {
  final dynamic application;
  final List<BuildHistory> buildHistory;
  final bool isLoading;
  final VoidCallback onRefresh;
  final ApplicationProvider applicationProvider;

  const BuildTab({
    super.key,
    required this.application,
    required this.buildHistory,
    required this.isLoading,
    required this.onRefresh,
    required this.applicationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Build actions
          _buildActionsCard(context),
          const SizedBox(height: 24),

          // Build history
          _buildHistorySection(context),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Build Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await applicationProvider.buildApplication(
                        application.id.toString(),
                        generateSourceOnly: true,
                      );
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Source generated'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('Generate Source'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await applicationProvider.buildApplication(
                        application.id.toString(),
                      );
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Build started'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        onRefresh();
                      }
                    },
                    icon: const Icon(Icons.build),
                    label: const Text('Build APK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Build History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (buildHistory.isNotEmpty)
              TextButton(
                onPressed: () {
                  context.push('/builds/${application.id}');
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (buildHistory.isEmpty)
          _buildEmptyHistoryState()
        else
          ...List.generate(
            buildHistory.take(5).length,
            (index) => BuildHistoryCard(buildHistory: buildHistory[index]), // Fixed: changed 'build' to 'buildHistory'
          ),
      ],
    );
  }

  Widget _buildEmptyHistoryState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No builds yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Build your application to see history',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}