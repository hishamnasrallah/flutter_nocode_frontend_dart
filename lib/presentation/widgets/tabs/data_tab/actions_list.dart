// lib/presentation/widgets/tabs/data_tab/actions_list.dart
import 'package:flutter/material.dart';
import '../../../../../data/models/action.dart';
import '../../../../../data/repositories/action_repository.dart';
import '../../../../../data/repositories/screen_repository.dart';
import '../../../../../data/repositories/data_source_repository.dart';
import '../../dialogs/add_action_dialog.dart';
import '../../dialogs/edit_action_dialog.dart';
import '../../../utils/action_helpers.dart';

class ActionsList extends StatelessWidget {
  final List<AppAction> actions;
  final VoidCallback onRefresh;
  final ActionRepository actionRepository;
  final ScreenRepository screenRepository;
  final DataSourceRepository dataSourceRepository;
  final String applicationId;

  const ActionsList({
    super.key,
    required this.actions,
    required this.onRefresh,
    required this.actionRepository,
    required this.screenRepository,
    required this.dataSourceRepository,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildActionCard(context, action);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flash_on, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No actions configured',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add actions to handle user interactions',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              showAddActionDialog(
                context,
                applicationId,
                actionRepository,
                screenRepository,
                dataSourceRepository,
                onRefresh,
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Action'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, AppAction action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ActionHelpers.getActionColor(action.actionType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            ActionHelpers.getActionIcon(action.actionType),
            color: ActionHelpers.getActionColor(action.actionType),
          ),
        ),
        title: Text(action.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${ActionHelpers.getActionTypeLabel(action.actionType)}'),
            if (action.targetScreenName != null)
              Text('Target: ${action.targetScreenName}'),
            if (action.apiDataSourceName != null)
              Text('Data Source: ${action.apiDataSourceName}'),
            if (action.url != null)
              Text('URL: ${action.url}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showEditActionDialog(
                  context,
                  action,
                  applicationId,
                  actionRepository,
                  screenRepository,
                  dataSourceRepository,
                  onRefresh,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showAddActionDialog(
                  context,
                  applicationId,
                  actionRepository,
                  screenRepository,
                  dataSourceRepository,
                  onRefresh,
                );
              },
              tooltip: 'Add New Action',
            ),
          ],
        ),
      ),
    );
  }
}