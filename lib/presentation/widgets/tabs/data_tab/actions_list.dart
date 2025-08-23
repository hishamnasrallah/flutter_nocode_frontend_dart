// lib/presentation/applications/widgets/tabs/data_tab/actions_list.dart
import 'package:flutter/material.dart';
import '../../../utils/action_helpers.dart';

class ActionsList extends StatelessWidget {
  final List<dynamic> actions;

  const ActionsList({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(action);
      },
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
              // Add action
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Action'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ActionHelpers.getActionColor(action['action_type']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            ActionHelpers.getActionIcon(action['action_type']),
            color: ActionHelpers.getActionColor(action['action_type']),
          ),
        ),
        title: Text(action['name'] ?? 'Unnamed Action'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${ActionHelpers.getActionTypeLabel(action['action_type'])}'),
            if (action['target_screen_name'] != null)
              Text('Target: ${action['target_screen_name']}'),
            if (action['api_data_source_name'] != null)
              Text('Data Source: ${action['api_data_source_name']}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Edit action
          },
        ),
      ),
    );
  }
}