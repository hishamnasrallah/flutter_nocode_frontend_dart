// lib/presentation/builder/components/canvas/builder_canvas.dart
import 'package:flutter/material.dart';
import '../../../../data/models/app_widget.dart';
import '../../../../data/models/screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../utils/builder_state_manager.dart';
import 'screen_preview.dart';
import 'canvas_toolbar.dart';
import 'grid_painter.dart';

class BuilderCanvas extends StatefulWidget {
  final BuilderStateManager stateManager;
  final Screen? selectedScreen;
  final List<AppWidget> widgets;
  final AppWidget? selectedWidget;
  final Function(AppWidget?) onWidgetSelected;
  final Function(Map<String, dynamic>) onWidgetAdded;
  final Function(AppWidget) onWidgetDeleted;
  final Function(AppWidget, int) onWidgetReordered;
  final Function(AppWidget) onWidgetDuplicated;

  const BuilderCanvas({
    super.key,
    required this.stateManager,
    required this.selectedScreen,
    required this.widgets,
    required this.selectedWidget,
    required this.onWidgetSelected,
    required this.onWidgetAdded,
    required this.onWidgetDeleted,
    required this.onWidgetReordered,
    required this.onWidgetDuplicated,
  });

  @override
  State<BuilderCanvas> createState() => _BuilderCanvasState();
}

class _BuilderCanvasState extends State<BuilderCanvas> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Canvas toolbar
        CanvasToolbar(
          widgetCount: widget.widgets.length,
        ),

        // Canvas area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DragTarget<Map<String, dynamic>>(
                  onWillAccept: (data) => true,
                  onAccept: widget.onWidgetAdded,
                  builder: (context, candidateData, rejectedData) {
                    final isHighlighted = candidateData.isNotEmpty;

                    return _buildCanvasArea(constraints, isHighlighted);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasArea(BoxConstraints constraints, bool isHighlighted) {
    if (widget.stateManager.showGrid) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: GridPainter(
          color: Colors.grey[300]!.withOpacity(0.3),
        ),
        child: _buildCanvasContent(isHighlighted),
      );
    } else {
      return _buildCanvasContent(isHighlighted);
    }
  }

  Widget _buildCanvasContent(bool isHighlighted) {
    return Center(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Transform.scale(
            scale: widget.stateManager.zoomLevel,
            child: _buildDeviceFrame(isHighlighted),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceFrame(bool isHighlighted) {
    return Container(
      width: 375, // iPhone width
      height: 667, // iPhone height
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isHighlighted ? AppColors.primary : Colors.grey[400]!,
          width: isHighlighted ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: widget.selectedScreen == null
            ? _buildEmptyState()
            : ScreenPreview(
                screen: widget.selectedScreen!,
                widgets: widget.widgets,
                selectedWidget: widget.selectedWidget,
                showOutlines: widget.stateManager.showOutlines,
                onWidgetSelected: widget.onWidgetSelected,
                onWidgetDeleted: widget.onWidgetDeleted,
                onWidgetReordered: widget.onWidgetReordered,
                onWidgetDuplicated: widget.onWidgetDuplicated,
                onWidgetAdded: widget.onWidgetAdded,
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_box_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Select or create a screen',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your app interface',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
