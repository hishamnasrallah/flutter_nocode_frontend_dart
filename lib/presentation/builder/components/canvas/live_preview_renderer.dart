// lib/presentation/builder/components/canvas/responsive_device_frame.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum DeviceType { phone, tablet, desktop }

class ResponsiveDeviceFrame extends StatefulWidget {
  final Widget child;
  final DeviceType deviceType;
  final bool showFrame;
  final VoidCallback? onDeviceChanged;

  const ResponsiveDeviceFrame({
    super.key,
    required this.child,
    this.deviceType = DeviceType.phone,
    this.showFrame = true,
    this.onDeviceChanged,
  });

  @override
  State<ResponsiveDeviceFrame> createState() => _ResponsiveDeviceFrameState();
}

class _ResponsiveDeviceFrameState extends State<ResponsiveDeviceFrame>
    with SingleTickerProviderStateMixin {

  late AnimationController _rotateController;
  bool _isLandscape = false;

  static const Map<DeviceType, Map<String, double>> _deviceSizes = {
    DeviceType.phone: {'width': 375, 'height': 667},
    DeviceType.tablet: {'width': 768, 'height': 1024},
    DeviceType.desktop: {'width': 1440, 'height': 900},
  };

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = _deviceSizes[widget.deviceType]!;
    final width = _isLandscape ? size['height']! : size['width']!;
    final height = _isLandscape ? size['width']! : size['height']!;

    return Column(
      children: [
        _buildDeviceControls(),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: AnimatedRotation(
              turns: _isLandscape ? 0.25 : 0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: width,
                height: height,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: widget.showFrame ? _buildFrameDecoration() : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.showFrame ? 20 : 0),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDeviceButton(DeviceType.phone, Icons.phone_android),
          const SizedBox(width: 8),
          _buildDeviceButton(DeviceType.tablet, Icons.tablet),
          const SizedBox(width: 8),
          _buildDeviceButton(DeviceType.desktop, Icons.computer),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              _isLandscape ? Icons.stay_current_portrait : Icons.stay_current_landscape,
              size: 20,
            ),
            onPressed: widget.deviceType != DeviceType.desktop
                ? () {
                    setState(() => _isLandscape = !_isLandscape);
                    _rotateController.forward();
                  }
                : null,
            tooltip: _isLandscape ? 'Portrait' : 'Landscape',
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceButton(DeviceType type, IconData icon) {
    final isSelected = widget.deviceType == type;
    return InkWell(
      onTap: () {
        if (widget.onDeviceChanged != null) {
          widget.onDeviceChanged!();
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : Colors.grey[600],
        ),
      ),
    );
  }

  BoxDecoration _buildFrameDecoration() {
    return BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 30,
          offset: const Offset(0, 20),
        ),
      ],
      border: Border.all(
        color: Colors.grey[800]!,
        width: widget.deviceType == DeviceType.phone ? 8 : 2,
      ),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }
}