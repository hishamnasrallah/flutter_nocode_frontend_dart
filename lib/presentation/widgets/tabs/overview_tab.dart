// lib/presentation/applications/widgets/tabs/overview_tab.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// Import components using relative paths
import '../components/stat_card.dart';
import '../components/widget_distribution_chart.dart';
import '../components/application_status_chip.dart';

class OverviewTab extends StatelessWidget {
  final dynamic application;
  final Map<String, dynamic>? statistics;

  const OverviewTab({
    super.key,
    required this.application,
    this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App info card
          _buildAppInfoCard(context),
          const SizedBox(height: 24),

          // Statistics
          if (statistics != null) ...[
            _buildStatisticsSection(context),
            const SizedBox(height: 24),

            // Widget distribution chart (if available)
            if (statistics!['widgets']?['by_type'] != null) ...[
              _buildWidgetDistributionSection(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apps,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.packageName,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text('v${application.version}'),
                            backgroundColor: Colors.grey[200],
                            labelPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 8),
                          ApplicationStatusChip(status: application.buildStatus),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (application.description != null && application.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(application.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: 'Screens',
              value: statistics!['screens']?['total']?.toString() ??
                     statistics!['screens_count']?.toString() ?? '0',
              icon: Icons.phone_android,
              color: AppColors.primary,
            ),
            StatCard(
              title: 'Widgets',
              value: statistics!['widgets']?['total']?.toString() ??
                     statistics!['widgets_count']?.toString() ?? '0',
              icon: Icons.widgets,
              color: AppColors.accent,
            ),
            StatCard(
              title: 'Data Sources',
              value: statistics!['data_sources']?['total']?.toString() ??
                     statistics!['data_sources_count']?.toString() ?? '0',
              icon: Icons.storage,
              color: AppColors.info,
            ),
            StatCard(
              title: 'Actions',
              value: statistics!['actions']?['total']?.toString() ??
                     statistics!['actions_count']?.toString() ?? '0',
              icon: Icons.flash_on,
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWidgetDistributionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Widget Distribution',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: WidgetDistributionChart(
                data: statistics!['widgets']['by_type'],
              ),
            ),
          ),
        ),
      ],
    );
  }
}