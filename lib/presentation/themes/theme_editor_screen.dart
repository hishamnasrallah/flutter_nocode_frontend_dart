
// lib/presentation/themes/theme_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';

class ThemeEditorScreen extends StatefulWidget {
  final String themeId;

  const ThemeEditorScreen({super.key, required this.themeId});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  late TextEditingController _nameController;
  late Color _primaryColor;
  late Color _accentColor;
  late Color _backgroundColor;
  late Color _textColor;
  late bool _isDarkMode;
  late String _fontFamily;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final provider = context.read<ThemeProvider>();
    await provider.fetchThemeDetail(widget.themeId);

    final theme = provider.selectedTheme;
    if (theme != null) {
      setState(() {
        _nameController = TextEditingController(text: theme.name);
        _primaryColor = Color(int.parse(theme.primaryColor.replaceAll('#', '0xFF')));
        _accentColor = Color(int.parse(theme.accentColor.replaceAll('#', '0xFF')));
        _backgroundColor = Color(int.parse(theme.backgroundColor.replaceAll('#', '0xFF')));
        _textColor = Color(int.parse(theme.textColor.replaceAll('#', '0xFF')));
        _isDarkMode = theme.isDarkMode;
        _fontFamily = theme.fontFamily;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final theme = provider.selectedTheme;

    if (provider.isLoading && theme == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (theme == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Theme Not Found')),
        body: const Center(
          child: Text('The requested theme could not be found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Theme'),
        actions: [
          TextButton(
            onPressed: _saveTheme,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          // Editor panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Theme Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Colors',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildColorSelector('Primary Color', _primaryColor, (color) {
                    setState(() => _primaryColor = color);
                  }),
                  const SizedBox(height: 16),

                  _buildColorSelector('Accent Color', _accentColor, (color) {
                    setState(() => _accentColor = color);
                  }),
                  const SizedBox(height: 16),

                  _buildColorSelector('Background Color', _backgroundColor, (color) {
                    setState(() => _backgroundColor = color);
                  }),
                  const SizedBox(height: 16),

                  _buildColorSelector('Text Color', _textColor, (color) {
                    setState(() => _textColor = color);
                  }),
                  const SizedBox(height: 24),

                  Text(
                    'Typography',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _fontFamily,
                    decoration: const InputDecoration(
                      labelText: 'Font Family',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Roboto', 'Poppins', 'Open Sans', 'Lato', 'Montserrat']
                        .map((font) => DropdownMenuItem(
                              value: font,
                              child: Text(font),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _fontFamily = value ?? 'Roboto');
                    },
                  ),
                  const SizedBox(height: 24),

                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark mode for this theme'),
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() => _isDarkMode = value);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Preview panel
          Container(
            width: 400,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: _buildPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(String label, Color color, Function(Color) onColorChanged) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pick $label'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: onColorChanged,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      color: _backgroundColor,
      child: Column(
        children: [
          // App bar preview
          Container(
            height: 56,
            color: _primaryColor,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.menu, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  'Preview App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: _fontFamily,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heading Text',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a sample paragraph text to preview how your theme will look in the application.',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 16,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buttons preview
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Primary Button',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Accent Button',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Title',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: _fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is a card component preview.',
                          style: TextStyle(
                            color: _textColor.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTheme() async {
    final provider = context.read<ThemeProvider>();
    final success = await provider.updateTheme(
      widget.themeId,
      {
        'name': _nameController.text,
        'primary_color': '#${_primaryColor.value.toRadixString(16).substring(2)}',
        'accent_color': '#${_accentColor.value.toRadixString(16).substring(2)}',
        'background_color': '#${_backgroundColor.value.toRadixString(16).substring(2)}',
        'text_color': '#${_textColor.value.toRadixString(16).substring(2)}',
        'font_family': _fontFamily,
        'is_dark_mode': _isDarkMode,
      },
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
