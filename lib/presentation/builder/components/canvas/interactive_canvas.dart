// lib/presentation/builder/components/canvas/interactive_canvas.dart
import 'package:flutter/material.dart';
import '../../../../data/models/screen.dart';
import '../../../../data/models/app_widget.dart';
import '../../../../core/constants/app_colors.dart';
import 'live_preview_renderer.dart';
import 'responsive_device_frame.dart' hide DeviceType, ResponsiveDeviceFrame;
import '../../utils/builder_state_manager.dart';

class InteractiveCanvas extends StatefulWidget {
  final BuilderStateManager stateManager;
  final Screen? selectedScreen;
  final List<AppWidget> widgets;
  final AppWidget? selectedWidget;
  final Function(AppWidget?) onWidgetSelected;
  final Function(Map<String, dynamic>) onWidgetAdded;
  final Function(AppWidget) onWidgetDeleted;
  final Function(AppWidget, int) onWidgetReordered;
  final Function(AppWidget, AppWidget?) onWidgetMoved;

  const InteractiveCanvas({
    super.key,
    required this.stateManager,
    required this.selectedScreen,
    required this.widgets,
    required this.selectedWidget,
    required this.onWidgetSelected,
    required this.onWidgetAdded,
    required this.onWidgetDeleted,
    required this.onWidgetReordered,
    required this.onWidgetMoved,
  });

  @override
  State<InteractiveCanvas> createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas>
    with SingleTickerProviderStateMixin {

  DeviceType _deviceType = DeviceType.phone;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: widget.stateManager.zoomLevel,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(InteractiveCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateManager.zoomLevel != widget.stateManager.zoomLevel) {
      _zoomAnimation = Tween<double>(
        begin: _zoomAnimation.value,
        end: widget.stateManager.zoomLevel,
      ).animate(CurvedAnimation(
        parent: _zoomController,
        curve: Curves.easeInOut,
      ));
      _zoomController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _buildCanvasToolbar(),
          Expanded(
            child: Stack(
              children: [
                _buildGridBackground(),
                _buildCanvas(),
                _buildFloatingActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.dashboard_customize, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            'Canvas',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          _buildZoomControls(),
          const SizedBox(width: 16),
          _buildViewOptions(),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: widget.stateManager.zoomOut,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${(widget.stateManager.zoomLevel * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: widget.stateManager.zoomIn,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOptions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            widget.stateManager.showGrid ? Icons.grid_on : Icons.grid_off,
            size: 20,
          ),
          onPressed: widget.stateManager.toggleGrid,
          tooltip: widget.stateManager.showGrid ? 'Hide Grid' : 'Show Grid',
        ),
        IconButton(
          icon: Icon(
            widget.stateManager.showOutlines ? Icons.border_all : Icons.border_clear,
            size: 20,
          ),
          onPressed: widget.stateManager.toggleOutlines,
          tooltip: widget.stateManager.showOutlines ? 'Hide Outlines' : 'Show Outlines',
        ),
      ],
    );
  }

  Widget _buildGridBackground() {
    if (!widget.stateManager.showGrid) return const SizedBox.shrink();

    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(
          color: Colors.grey[300]!.withOpacity(0.3),
          gridSize: 20.0,
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    if (widget.selectedScreen == null) {
      return _buildEmptyCanvas();
    }

    return AnimatedBuilder(
      animation: _zoomAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _zoomAnimation.value,
          child: Center(
            child: ResponsiveDeviceFrame(
              deviceType: _deviceType,
              showFrame: true,
              onDeviceChanged: () {
                setState(() {
                  _deviceType = DeviceType.values[
                    (_deviceType.index + 1) % DeviceType.values.length
                  ];
                });
              },
              child: LivePreviewRenderer(
                screen: widget.selectedScreen!,
                widgets: widget.widgets,
                selectedWidget: widget.selectedWidget,
                onWidgetSelected: widget.onWidgetSelected,
                onWidgetDropped: widget.onWidgetAdded,
                onWidgetMoved: widget.onWidgetMoved,
                isInteractive: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCanvas() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Screen Selected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a screen from the dropdown above or create a new one',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Trigger add screen dialog
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Screen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            onPressed: () {
              widget.stateManager.showPreview(context);
            },
            tooltip: 'Preview',
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.orange,
            onPressed: () {
              // Undo action
            },
            tooltip: 'Undo',
            child: const Icon(Icons.undo),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
            onPressed: () {
              // Redo action
            },
            tooltip: 'Redo',
            child: const Icon(Icons.redo),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double gridSize;

  GridPainter({required this.color, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gridSize != gridSize;
  }
}