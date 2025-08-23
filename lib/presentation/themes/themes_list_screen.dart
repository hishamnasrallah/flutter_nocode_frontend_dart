
// lib/presentation/themes/themes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ThemesListScreen extends StatefulWidget {
  const ThemesListScreen({super.key});

  @override
  State<ThemesListScreen> createState() => _ThemesListScreenState();
}

class _ThemesListScreenState extends State<ThemesListScreen> {
  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    final provider = context.read<ThemeProvider>();
    await provider.fetchThemes();
    await provider.fetchThemeTemplates();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.themes),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadThemes,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadThemes,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme templates
              if (themeProvider.themeTemplates.isNotEmpty) ...[
                Text(
                  'Theme Templates',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: themeProvider.themeTemplates.length,
                    itemBuilder: (context, index) {
                      final template = themeProvider.themeTemplates[index];
                      return _buildTemplateCard(template);
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // My themes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Themes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCreateThemeDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (themeProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (themeProvider.themes.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.palette_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No themes created yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first theme to get started',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: themeProvider.themes.length,
                  itemBuilder: (context, index) {
                    final theme = themeProvider.themes[index];
                    return _buildThemeCard(theme);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final primaryColor = Color(int.parse(template['primary_color'].replaceAll('#', '0xFF')));
    final accentColor = Color(int.parse(template['accent_color'].replaceAll('#', '0xFF')));
    final backgroundColor = Color(int.parse(template['background_color'].replaceAll('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          _applyTemplate(template);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                template['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    template['is_dark_mode'] ? Icons.dark_mode : Icons.light_mode,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template['is_dark_mode'] ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(dynamic theme) {
    final primaryColor = Color(int.parse(theme.primaryColor.replaceAll('#', '0xFF')));
    final accentColor = Color(int.parse(theme.accentColor.replaceAll('#', '0xFF')));
    final backgroundColor = Color(int.parse(theme.backgroundColor.replaceAll('#', '0xFF')));
    final textColor = Color(int.parse(theme.textColor.replaceAll('#', '0xFF')));

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/themes/${theme.id}/edit');
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // Color preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Stack(
                  children: [
                    // Primary color accent
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ),
                    ),
                    // Accent color circle
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Text preview
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: theme.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Theme info
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          theme.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (theme.applicationsCount != null && theme.applicationsCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${theme.applicationsCount} apps',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        theme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        theme.isDarkMode ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        context.push('/themes/${theme.id}/edit');
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[200],
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        _duplicateTheme(theme);
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Clone'),
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                      ),
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

  void _showCreateThemeDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color primaryColor = AppColors.primary;
    Color accentColor = AppColors.accent;
    Color backgroundColor = Colors.white;
    Color textColor = AppColors.textPrimary;
    bool isDarkMode = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Theme'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Theme Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildColorPicker('Primary Color', primaryColor, (color) {
                  setState(() => primaryColor = color);
                }),
                const SizedBox(height: 12),
                _buildColorPicker('Accent Color', accentColor, (color) {
                  setState(() => accentColor = color);
                }),
                const SizedBox(height: 12),
                _buildColorPicker('Background Color', backgroundColor, (color) {
                  setState(() => backgroundColor = color);
                }),
                const SizedBox(height: 12),
                _buildColorPicker('Text Color', textColor, (color) {
                  setState(() => textColor = color);
                }),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Dark Mode'),
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() => isDarkMode = value ?? false);
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a theme name'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                final provider = context.read<ThemeProvider>();
                await provider.createTheme(
                  name: nameController.text,
                  primaryColor: '#${primaryColor.value.toRadixString(16).substring(2)}',
                  accentColor: '#${accentColor.value.toRadixString(16).substring(2)}',
                  backgroundColor: '#${backgroundColor.value.toRadixString(16).substring(2)}',
                  textColor: '#${textColor.value.toRadixString(16).substring(2)}',
                  isDarkMode: isDarkMode,
                );
                _loadThemes();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(String label, Color color, Function(Color) onColorChanged) {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!),
              ),
            ),
            const SizedBox(width: 12),
            Text(label),
            const Spacer(),
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
    );
  }

  void _applyTemplate(Map<String, dynamic> template) async {
    final provider = context.read<ThemeProvider>();
    final theme = await provider.createTheme(
      name: '${template['name']} (Custom)',
      primaryColor: template['primary_color'],
      accentColor: template['accent_color'],
      backgroundColor: template['background_color'],
      textColor: template['text_color'],
      fontFamily: template['font_family'] ?? 'Roboto',
      isDarkMode: template['is_dark_mode'] ?? false,
    );

    if (theme != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme created from template'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadThemes();
    }
  }

  void _duplicateTheme(dynamic theme) async {
    final provider = context.read<ThemeProvider>();
    final newTheme = await provider.duplicateTheme(theme.id.toString());

    if (newTheme != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme duplicated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadThemes();
    }
  }
}
