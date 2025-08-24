
// lib/presentation/builder/components/toolbar/screen_selector.dart
import 'package:flutter/material.dart';
import '../../../../data/models/screen.dart';
import '../../../../core/constants/app_colors.dart';

class ScreenSelector extends StatelessWidget {
  final List<Screen> screens;
  final String? selectedScreenId;
  final Function(String) onScreenSelected;
  final VoidCallback onAddScreen;
  final VoidCallback onScreenSettings;

  const ScreenSelector({
    super.key,
    required this.screens,
    required this.selectedScreenId,
    required this.onScreenSelected,
    required this.onAddScreen,
    required this.onScreenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.phone_android, color: Colors.grey[700]),
          const SizedBox(width: 12),
          const Text(
            'Screen:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildScreenDropdown(),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onAddScreen,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Screen'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onScreenSettings,
            tooltip: 'Screen Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildScreenDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: DropdownButton<String>(
        value: selectedScreenId,
        isExpanded: true,
        underline: const SizedBox(),
        items: screens.map((screen) {
          return DropdownMenuItem(
            value: screen.id.toString(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (screen.isHomeScreen) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'HOME',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    '${screen.name} (${screen.routeName})',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onScreenSelected(value);
          }
        },
      ),
    );
  }
}