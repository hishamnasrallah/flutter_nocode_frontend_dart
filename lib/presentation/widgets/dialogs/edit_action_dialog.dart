// lib/presentation/widgets/dialogs/edit_action_dialog.dart
import 'package:flutter/material.dart';
import '../../../../data/models/action.dart';
import '../../../../data/models/screen.dart';
import '../../../../data/models/data_source.dart';
import '../../../../data/repositories/action_repository.dart';
import '../../../../data/repositories/screen_repository.dart';
import '../../../../data/repositories/data_source_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

// Define all possible action types
const List<String> _actionTypes = [
  'navigate',
  'api_call',
  'show_dialog',
  'open_url',
  'refresh_data',
  'save_data',  // Added this
  'load_data',  // Added this
  'back',
  'close_dialog',
  'submit_form', // Added this
  'validate_form', // Added this
  'clear_form', // Added this
];

void showEditActionDialog(
  BuildContext context,
  AppAction action,
  String applicationId,
  ActionRepository actionRepository,
  ScreenRepository screenRepository,
  DataSourceRepository dataSourceRepository,
  VoidCallback onSuccess,
) async {
  // Show loading while fetching data
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );

  // Fetch screens and data sources for dropdowns
  List<Screen> screens = [];
  List<DataSource> dataSources = [];

  try {
    screens = await screenRepository.getScreens(applicationId: applicationId);
    dataSources = await dataSourceRepository.getDataSources(applicationId: applicationId);
  } catch (e) {
    debugPrint('Error loading data for action dialog: $e');
  }

  // Close loading dialog
  Navigator.pop(context);

  final nameController = TextEditingController(text: action.name);
  final parametersController = TextEditingController(text: action.parameters ?? '');
  final dialogTitleController = TextEditingController(text: action.dialogTitle ?? '');
  final dialogMessageController = TextEditingController(text: action.dialogMessage ?? '');
  final urlController = TextEditingController(text: action.url ?? '');

  // Check if the action type is in our list, if not, add it
  String selectedActionType = action.actionType;
  List<String> availableActionTypes = List.from(_actionTypes);

  // If the action type from database is not in our list, add it
  if (!availableActionTypes.contains(selectedActionType)) {
    debugPrint('Warning: Unknown action type "$selectedActionType" found, adding to list');
    availableActionTypes.add(selectedActionType);
  }

  // Validate that the target screen exists in the list
  int? selectedTargetScreen;
  if (action.targetScreen != null) {
    final screenExists = screens.any((s) => s.id == action.targetScreen);
    if (screenExists) {
      selectedTargetScreen = action.targetScreen;
    } else {
      debugPrint('Warning: Target screen ${action.targetScreen} not found in screens list');
    }
  }

  // Validate that the data source exists in the list
  int? selectedDataSource;
  if (action.apiDataSource != null) {
    final dataSourceExists = dataSources.any((ds) => ds.id == action.apiDataSource);
    if (dataSourceExists) {
      selectedDataSource = action.apiDataSource;
    } else {
      debugPrint('Warning: Data source ${action.apiDataSource} not found in data sources list');
    }
  }

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Action'),
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
                  items: availableActionTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getActionTypeLabel(type)),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedActionType = value ?? 'navigate';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Conditional fields based on action type
                if (selectedActionType == 'navigate') ...[
                  if (screens.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No screens available. Create screens first.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<int?>(
                      value: selectedTargetScreen,
                      decoration: const InputDecoration(
                        labelText: 'Target Screen',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Select a screen'),
                        ),
                        ...screens.map((screen) => DropdownMenuItem(
                              value: screen.id,
                              child: Text('${screen.name} (${screen.routeName})'),
                            ))
                            .toList(),
                      ],
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
                  if (dataSources.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No data sources available. Create data sources first.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<int?>(
                      value: selectedDataSource,
                      decoration: const InputDecoration(
                        labelText: 'Data Source',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Select a data source'),
                        ),
                        ...dataSources.map((ds) => DropdownMenuItem(
                              value: ds.id,
                              child: Text(ds.name),
                            ))
                            .toList(),
                      ],
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
          TextButton(
            onPressed: () async {
              final confirmed = await Helpers.showConfirmationDialog(
                context,
                title: 'Delete Action',
                message: 'Are you sure you want to delete this action?',
                confirmText: 'Delete',
                isDangerous: true,
              );

              if (confirmed) {
                try {
                  await actionRepository.deleteAction(action.id.toString());
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Action deleted'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  onSuccess();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
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

              try {
                Helpers.showLoadingDialog(context, message: 'Updating action...');

                await actionRepository.updateAction(
                  action.id.toString(),
                  {
                    'name': nameController.text,
                    'action_type': selectedActionType,
                    'target_screen': selectedTargetScreen,
                    'api_data_source': selectedDataSource,
                    'parameters': parametersController.text.isEmpty ? null : parametersController.text,
                    'dialog_title': dialogTitleController.text.isEmpty ? null : dialogTitleController.text,
                    'dialog_message': dialogMessageController.text.isEmpty ? null : dialogMessageController.text,
                    'url': urlController.text.isEmpty ? null : urlController.text,
                  },
                );

                Helpers.hideLoadingDialog(context);
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Action updated successfully'),
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
    case 'save_data':
      return 'Save Data';
    case 'load_data':
      return 'Load Data';
    case 'submit_form':
      return 'Submit Form';
    case 'validate_form':
      return 'Validate Form';
    case 'clear_form':
      return 'Clear Form';
    case 'back':
      return 'Go Back';
    case 'close_dialog':
      return 'Close Dialog';
    default:
      return type.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
      ).join(' ');
  }
}