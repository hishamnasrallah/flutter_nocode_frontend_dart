// lib/presentation/builder/components/toolbar/builder_app_bar.dart
import 'package:flutter/material.dart';
import '../../utils/builder_state_manager.dart';

class BuilderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String applicationName;
  final BuilderStateManager stateManager;
  final VoidCallback onRefresh;
  final VoidCallback onSave;

  const BuilderAppBar({
    super.key,
    required this.applicationName,
    required this.stateManager,
    required this.onRefresh,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Builder - $applicationName'),
      actions: [
        // Zoom controls
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: stateManager.zoomOut,
          tooltip: 'Zoom Out',
        ),
        Text(
          '${(stateManager.zoomLevel * 100).toInt()}%',
          style: const TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: stateManager.zoomIn,
          tooltip: 'Zoom In',
        ),
        const SizedBox(width: 8),

        // View options
        IconButton(
          icon: Icon(stateManager.showGrid ? Icons.grid_on : Icons.grid_off),
          onPressed: stateManager.toggleGrid,
          tooltip: stateManager.showGrid ? 'Hide Grid' : 'Show Grid',
        ),
        IconButton(
          icon: Icon(stateManager.showOutlines ? Icons.border_all : Icons.border_clear),
          onPressed: stateManager.toggleOutlines,
          tooltip: stateManager.showOutlines ? 'Hide Outlines' : 'Show Outlines',
        ),
        const SizedBox(width: 8),

        // Actions
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.preview),
          onPressed: () => stateManager.showPreview(context),
          tooltip: 'Preview',
        ),
        IconButton(
          icon: const Icon(Icons.code),
          onPressed: () => stateManager.showCodePreview(context),
          tooltip: 'View Code',
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: onSave,
          tooltip: 'Save',
        ),
      ],
    );
  }
}
