// lib/presentation/builder/components/dialogs/add_screen_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/builder_provider.dart';

class AddScreenDialog extends StatefulWidget {
  final String applicationId;
  final VoidCallback onSuccess;

  const AddScreenDialog({
    super.key,
    required this.applicationId,
    required this.onSuccess,
  });

  @override
  State<AddScreenDialog> createState() => _AddScreenDialogState();
}

class _AddScreenDialogState extends State<AddScreenDialog> {
  final _nameController = TextEditingController();
  final _routeController = TextEditingController();
  bool _isHomeScreen = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Screen'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Screen Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _routeController,
              decoration: const InputDecoration(
                labelText: 'Route Path',
                border: OutlineInputBorder(),
                hintText: '/screen-name',
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Set as Home Screen'),
              value: _isHomeScreen,
              onChanged: (value) {
                setState(() {
                  _isHomeScreen = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.isEmpty || _routeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final builderProvider = context.read<BuilderProvider>();
            await builderProvider.createScreen(
              applicationId: widget.applicationId,
              name: _nameController.text,
              routeName: _routeController.text,
              isHomeScreen: _isHomeScreen,
            );

            Navigator.pop(context);
            widget.onSuccess();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _routeController.dispose();
    super.dispose();
  }
}

