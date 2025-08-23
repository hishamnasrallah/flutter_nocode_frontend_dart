// lib/presentation/applications/widgets/tabs/data_tab/data_sources_list.dart
import 'package:flutter/material.dart';
import '../../../../../data/models/data_source.dart';
import '../../../../../data/repositories/data_source_repository.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/helpers.dart';
import '../../dialogs/add_data_source_dialog.dart';
import '../../../utils/data_source_helpers.dart';

class DataSourcesList extends StatelessWidget {
  final List<DataSource> dataSources;
  final VoidCallback onRefresh;
  final DataSourceRepository dataSourceRepository;

  const DataSourcesList({
    super.key,
    required this.dataSources,
    required this.onRefresh,
    required this.dataSourceRepository,
  });

  @override
  Widget build(BuildContext context) {
    if (dataSources.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dataSources.length,
        itemBuilder: (context, index) {
          final dataSource = dataSources[index];
          return _buildDataSourceCard(context, dataSource);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storage, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data sources configured',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add API endpoints or databases',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              showAddDataSourceDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Data Source'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceCard(BuildContext context, DataSource dataSource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DataSourceHelpers.getDataSourceColor(dataSource.dataSourceType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            DataSourceHelpers.getDataSourceIcon(dataSource.dataSourceType),
            color: DataSourceHelpers.getDataSourceColor(dataSource.dataSourceType),
          ),
        ),
        title: Text(dataSource.name),
        subtitle: Text(dataSource.dataSourceType.toUpperCase()),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dataSource.baseUrl != null) ...[
                  _buildDetailRow('Base URL', dataSource.baseUrl!),
                  const SizedBox(height: 8),
                ],
                if (dataSource.endpoint != null) ...[
                  _buildDetailRow('Endpoint', dataSource.endpoint!),
                  const SizedBox(height: 8),
                ],
                _buildDetailRow('Method', dataSource.method),
                const SizedBox(height: 8),
                _buildDetailRow('Dynamic URL', dataSource.useDynamicBaseUrl ? 'Yes' : 'No'),
                if (dataSource.fieldsCount != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Fields', '${dataSource.fieldsCount} fields'),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _testDataSourceConnection(context, dataSource);
                      },
                      icon: const Icon(Icons.wifi_tethering, size: 16),
                      label: const Text('Test Connection'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Edit data source
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Future<void> _testDataSourceConnection(BuildContext context, DataSource dataSource) async {
    try {
      Helpers.showLoadingDialog(context, message: 'Testing connection...');

      final result = await dataSourceRepository.testConnection(dataSource.id.toString());

      Helpers.hideLoadingDialog(context);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection successful!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Connection failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Helpers.hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}