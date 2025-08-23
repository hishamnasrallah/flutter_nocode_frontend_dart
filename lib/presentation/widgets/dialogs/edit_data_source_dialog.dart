// lib/presentation/widgets/dialogs/edit_data_source_dialog.dart
import 'package:flutter/material.dart';
import '../../../../data/models/data_source.dart';
import '../../../../data/repositories/data_source_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

void showEditDataSourceDialog(
  BuildContext context,
  DataSource dataSource,
  DataSourceRepository repository,
  VoidCallback onSuccess,
) {
  final nameController = TextEditingController(text: dataSource.name);
  final baseUrlController = TextEditingController(text: dataSource.baseUrl ?? '');
  final endpointController = TextEditingController(text: dataSource.endpoint ?? '');
  final headersController = TextEditingController(text: dataSource.headers ?? '');

  String selectedMethod = dataSource.method;
  String selectedType = dataSource.dataSourceType;
  bool useDynamicUrl = dataSource.useDynamicBaseUrl;

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Data Source'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Type dropdown
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['REST_API', 'GraphQL', 'Firebase', 'Database']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? 'REST_API';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Base URL field
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://api.example.com',
                  ),
                ),
                const SizedBox(height: 16),

                // Endpoint field
                TextField(
                  controller: endpointController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint',
                    border: OutlineInputBorder(),
                    hintText: '/api/v1/resource',
                  ),
                ),
                const SizedBox(height: 16),

                // Method dropdown
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    border: OutlineInputBorder(),
                  ),
                  items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value ?? 'GET';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Headers field
                TextField(
                  controller: headersController,
                  decoration: const InputDecoration(
                    labelText: 'Headers (JSON)',
                    border: OutlineInputBorder(),
                    hintText: '{"Authorization": "Bearer token"}',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Dynamic URL checkbox
                CheckboxListTile(
                  title: const Text('Use Dynamic Base URL'),
                  subtitle: const Text('Allow runtime URL configuration'),
                  value: useDynamicUrl,
                  onChanged: (value) {
                    setState(() {
                      useDynamicUrl = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a name'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                Helpers.showLoadingDialog(context, message: 'Updating data source...');

                await repository.updateDataSource(
                  dataSource.id.toString(),
                  {
                    'name': nameController.text,
                    'data_source_type': selectedType,
                    'base_url': baseUrlController.text.isEmpty ? null : baseUrlController.text,
                    'endpoint': endpointController.text.isEmpty ? null : endpointController.text,
                    'method': selectedMethod,
                    'headers': headersController.text.isEmpty ? null : headersController.text,
                    'use_dynamic_base_url': useDynamicUrl,
                  },
                );

                Helpers.hideLoadingDialog(context);
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data source updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );

                onSuccess();
              } catch (e) {
                Helpers.hideLoadingDialog(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    ),
  );
}