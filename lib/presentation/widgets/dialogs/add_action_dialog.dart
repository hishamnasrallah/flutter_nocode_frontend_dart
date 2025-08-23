// lib/presentation/widgets/dialogs/add_action_dialog.dart
import 'package:flutter/material.dart';
import '../../../../data/models/screen.dart';
import '../../../../data/models/data_source.dart';
import '../../../../data/repositories/action_repository.dart';
import '../../../../data/repositories/screen_repository.dart';
import '../../../../data/repositories/data_source_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

const List<String> _actionTypes = [
  'navigate',
  'api_call',
  'show_dialog',
  'open_url',
  'refresh_data',
  'save_data',
  'load_data',
  'back',
  'close_dialog',
  'submit_form',
  'validate_form',
  'clear_form',
];

void showAddActionDialog(
  BuildContext context,
  String applicationId,
  ActionRepository actionRepository,
  ScreenRepository screenRepository,
  DataSourceRepository dataSourceRepository,
  VoidCallback onSuccess,
) async {
  // Fetch screens and data sources for dropdowns
  List<Screen> screens = [];
  List<DataSource> dataSources = [];

  try {
    screens = await screenRepository.getScreens(applicationId: applicationId);
    dataSources = await dataSourceRepository.getDataSources(applicationId: applicationId);
  } catch (e) {
    debugPrint('Error loading data for action dialog: $e');
  }

  final nameController = TextEditingController();
  final parametersController = TextEditingController();
  final dialogTitleController = TextEditingController();
  final dialogMessageController = TextEditingController();
  final urlController = TextEditingController();

  String selectedActionType = 'navigate';
  int? selectedTargetScreen;
  int? selectedDataSource;

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Add New Action'),
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
                    labelText: 'Action Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Type dropdown
                DropdownButtonFormField<String>(
  value: selectedActionType,
  decoration: const InputDecoration(
    labelText: 'Action Type',
    border: OutlineInputBorder(),
  ),
  items: _actionTypes.map((type) => DropdownMenuItem(
        value: type,
        child: Text(_getActionTypeLabel(type)),
      ))
      .toList(),
  onChanged: (value) {
    setState(() {
      selectedActionType = value ?? 'navigate';
      // Reset fields based on type
      selectedTargetScreen = null;
      selectedDataSource = null;
    });
  },
),
                const SizedBox(height: 16),

                // Conditional fields based on action type
                if (selectedActionType == 'navigate') ...[
                  DropdownButtonFormField<int>(
                    value: selectedTargetScreen,
                    decoration: const InputDecoration(
                      labelText: 'Target Screen',
                      border: OutlineInputBorder(),
                    ),
                    items: screens.map((screen) => DropdownMenuItem(
                          value: screen.id,
                          child: Text('${screen.name} (${screen.routeName})'),
                        ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTargetScreen = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                if (selectedActionType == 'api_call' ||
    selectedActionType == 'save_data' ||
    selectedActionType == 'load_data') ...[
                  DropdownButtonFormField<int>(
                    value: selectedDataSource,
                    decoration: const InputDecoration(
                      labelText: 'Data Source',
                      border: OutlineInputBorder(),
                    ),
                    items: dataSources.map((ds) => DropdownMenuItem(
                          value: ds.id,
                          child: Text(ds.name),
                        ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDataSource = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: parametersController,
                    decoration: const InputDecoration(
                      labelText: 'Parameters (JSON)',
                      border: OutlineInputBorder(),
                      hintText: '{"key": "value"}',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                ],

                if (selectedActionType == 'show_dialog') ...[
                  TextField(
                    controller: dialogTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Dialog Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dialogMessageController,
                    decoration: const InputDecoration(
                      labelText: 'Dialog Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                ],

                if (selectedActionType == 'open_url') ...[
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
                    content: Text('Please enter an action name'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Validate based on action type
              if (selectedActionType == 'navigate' && selectedTargetScreen == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a target screen'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (selectedActionType == 'api_call' && selectedDataSource == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a data source'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (selectedActionType == 'open_url' && urlController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a URL'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                Helpers.showLoadingDialog(context, message: 'Creating action...');

                await actionRepository.createAction(
                  applicationId: applicationId,
                  name: nameController.text,
                  actionType: selectedActionType,
                  targetScreen: selectedTargetScreen,
                  apiDataSource: selectedDataSource,
                  parameters: parametersController.text.isEmpty ? null : parametersController.text,
                  dialogTitle: dialogTitleController.text.isEmpty ? null : dialogTitleController.text,
                  dialogMessage: dialogMessageController.text.isEmpty ? null : dialogMessageController.text,
                  url: urlController.text.isEmpty ? null : urlController.text,
                );

                Helpers.hideLoadingDialog(context);
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Action created successfully'),
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
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}

String _getActionTypeLabel(String type) {
  switch (type) {
    case 'navigate':
      return 'Navigate to Screen';
    case 'api_call':
      return 'API Call';
    case 'show_dialog':
      return 'Show Dialog';
    case 'open_url':
      return 'Open URL';
    case 'refresh_data':
      return 'Refresh Data';
    case 'back':
      return 'Go Back';
    case 'close_dialog':
      return 'Close Dialog';
    default:
      return type;
  }
}