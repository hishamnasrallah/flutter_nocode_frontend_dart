// lib/presentation/applications/create_application_screen.dart
import '../../data/models/application.dart';
import '../../data/models/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';

class CreateApplicationScreen extends StatefulWidget {
  const CreateApplicationScreen({super.key});

  @override
  State<CreateApplicationScreen> createState() => _CreateApplicationScreenState();
}

class _CreateApplicationScreenState extends State<CreateApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Form controllers
  final _nameController = TextEditingController();
  final _packageNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0.0');

  int _currentStep = 0;
  int? _selectedThemeId;
  String? _selectedTemplate;

  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'blank',
      'name': 'Blank App',
      'description': 'Start with an empty application',
      'icon': Icons.insert_drive_file_outlined,
      'color': AppColors.primary,
    },
    {
      'id': 'ecommerce',
      'name': 'E-commerce',
      'description': 'Online store with products, cart, and checkout',
      'icon': Icons.shopping_cart,
      'color': Colors.orange,
    },
    {
      'id': 'social_media',
      'name': 'Social Media',
      'description': 'Social app with posts, profiles, and messaging',
      'icon': Icons.people,
      'color': Colors.blue,
    },
    {
      'id': 'news',
      'name': 'News App',
      'description': 'News reader with categories and articles',
      'icon': Icons.newspaper,
      'color': Colors.red,
    },
    {
      'id': 'recipe',
      'name': 'Recipe App',
      'description': 'Recipe collection with meal planning',
      'icon': Icons.restaurant_menu,
      'color': Colors.green,
    },
    {
      'id': 'marketplace',
      'name': 'Marketplace',
      'description': 'Multi-vendor marketplace platform',
      'icon': Icons.store,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadThemes();
    _nameController.addListener(_generatePackageName);
  }

  Future<void> _loadThemes() async {
    final themeProvider = context.read<ThemeProvider>();
    await themeProvider.fetchThemes();
    await themeProvider.fetchThemeTemplates();
  }

  void _generatePackageName() {
    final name = _nameController.text.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    if (name.isNotEmpty) {
      _packageNameController.text = 'com.example.$name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createApplication),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildTemplateStep(),
                _buildBasicInfoStep(),
                _buildThemeStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Template', 'Basic Info', 'Theme', 'Review'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isCompleted
                        ? AppColors.primary
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? AppColors.primary : Colors.grey[600],
                        ),
                      ),
                      if (index < steps.length - 1)
                        Container(
                          height: 2,
                          margin: const EdgeInsets.only(top: 16),
                          color: isCompleted ? AppColors.primary : Colors.grey[300],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTemplateStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Template',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a template to start with, or begin from scratch',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              final isSelected = _selectedTemplate == template['id'];

              return Card(
                elevation: isSelected ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTemplate = template['id'];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: (template['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            template['icon'],
                            size: 32,
                            color: template['color'],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          template['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the basic details for your application',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameController,
              labelText: 'Application Name',
              prefixIcon: Icons.apps,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an application name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _packageNameController,
              labelText: 'Package Name',
              prefixIcon: Icons.folder,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a package name';
                }
                if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$').hasMatch(value)) {
                  return 'Invalid package name format';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              prefixIcon: Icons.description,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _versionController,
              labelText: 'Version',
              prefixIcon: Icons.tag,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a version';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeStep() {
  final themeProvider = context.watch<ThemeProvider>();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a Theme',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a color theme for your application',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Create new theme button
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            title: const Text('Create New Theme'),
            subtitle: const Text('Design a custom theme for your app'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              _showCreateThemeDialog(context);
            },
          ),
        ),
        const SizedBox(height: 24),

        // Theme templates
        if (themeProvider.themeTemplates.isNotEmpty) ...[
          Text(
            'Theme Templates',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: themeProvider.themeTemplates.length,
            itemBuilder: (context, index) {
              final template = themeProvider.themeTemplates[index];
              final primaryColor = Color(int.parse(
                template['primary_color'].replaceAll('#', '0xFF'),
              ));
              final accentColor = Color(int.parse(
                template['accent_color'].replaceAll('#', '0xFF'),
              ));

              return Card(
                child: InkWell(
                  onTap: () async {
                    // Create theme from template
                    final theme = await themeProvider.createTheme(
                      name: '${template['name']} (Custom)',
                      primaryColor: template['primary_color'],
                      accentColor: template['accent_color'],
                      backgroundColor: template['background_color'],
                      textColor: template['text_color'],
                      fontFamily: template['font_family'] ?? 'Roboto',
                      isDarkMode: template['is_dark_mode'] ?? false,
                    );
                    if (theme != null) {
                      setState(() {
                        _selectedThemeId = theme.id;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Theme created and selected'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          template['name'],
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // Existing themes
        Text(
          'My Themes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (themeProvider.themes.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.palette_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No themes available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new theme or use a template above',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: themeProvider.themes.length,
            itemBuilder: (context, index) {
              final theme = themeProvider.themes[index];
              final isSelected = _selectedThemeId == theme.id;
              final primaryColor = Color(int.parse(
                theme.primaryColor.replaceAll('#', '0xFF'),
              ));

              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  title: Text(theme.name),
                  subtitle: Text(theme.isDarkMode ? 'Dark Theme' : 'Light Theme'),
                  trailing: Radio<int>(
                    value: theme.id,
                    groupValue: _selectedThemeId,
                    onChanged: (value) {
                      setState(() {
                        _selectedThemeId = value;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedThemeId = theme.id;
                    });
                  },
                ),
              );
            },
          ),

        // Option to skip theme selection
        const SizedBox(height: 16),
        Card(
          color: Colors.grey[100],
          child: ListTile(
            leading: Radio<int>(
              value: -1,
              groupValue: _selectedThemeId,
              onChanged: (value) {
                setState(() {
                  _selectedThemeId = -1; // Use default theme
                });
              },
            ),
            title: const Text('Use Default Theme'),
            subtitle: const Text('You can change the theme later'),
            onTap: () {
              setState(() {
                _selectedThemeId = -1;
              });
            },
          ),
        ),
      ],
    ),
  );
}

// Add this method to the class:
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
      builder: (context, setDialogState) => AlertDialog(
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
              // Simple color selection
              ListTile(
                title: const Text('Primary Color'),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                onTap: () async {
                  // Simple color selection
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Select Primary Color'),
                      content: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Colors.blue,
                          Colors.red,
                          Colors.green,
                          Colors.purple,
                          Colors.orange,
                          Colors.teal,
                          Colors.pink,
                          Colors.indigo,
                          Colors.cyan,
                        ].map((color) => InkWell(
                          onTap: () => Navigator.pop(context, color),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  );
                  if (color != null) {
                    setDialogState(() {
                      primaryColor = color;
                    });
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (value) {
                  setDialogState(() {
                    isDarkMode = value ?? false;
                    backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
                    textColor = isDarkMode ? Colors.white : Colors.black87;
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
              final theme = await provider.createTheme(
                name: nameController.text,
                primaryColor: '#${primaryColor.value.toRadixString(16).substring(2)}',
                accentColor: '#${accentColor.value.toRadixString(16).substring(2)}',
                backgroundColor: '#${backgroundColor.value.toRadixString(16).substring(2)}',
                textColor: '#${textColor.value.toRadixString(16).substring(2)}',
                isDarkMode: isDarkMode,
              );

              if (theme != null) {
                setState(() {
                  _selectedThemeId = theme.id;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme created and selected'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildReviewStep() {
  final selectedTemplate = _templates.firstWhere(
    (t) => t['id'] == _selectedTemplate,
    orElse: () => _templates.first,
  );

  // Get the selected theme name safely
  String themeName = 'Default Theme';
  if (_selectedThemeId != null && _selectedThemeId != -1) {
    final themeProvider = context.read<ThemeProvider>();
    final theme = themeProvider.themes.firstWhere(
      (t) => t.id == _selectedThemeId,
      orElse: () => themeProvider.themes.isNotEmpty
        ? themeProvider.themes.first
        : AppTheme(
            id: -1,
            name: 'Default Theme',
            primaryColor: '#2196F3',
            accentColor: '#FF4081',
            backgroundColor: '#FFFFFF',
            textColor: '#212121',
            fontFamily: 'Roboto',
            isDarkMode: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );
    themeName = theme.name;
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Create',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your application details before creating',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewItem('Template', selectedTemplate['name']),
                const Divider(),
                _buildReviewItem('Name', _nameController.text),
                const Divider(),
                _buildReviewItem('Package', _packageNameController.text),
                const Divider(),
                _buildReviewItem('Description', _descriptionController.text),
                const Divider(),
                _buildReviewItem('Version', _versionController.text),
                const Divider(),
                _buildReviewItem('Theme', themeName),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Info box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your application will be created with the selected template and theme. You can customize it further in the builder.',
                  style: TextStyle(color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Previous'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: Consumer<ApplicationProvider>(
            builder: (context, provider, _) {
              return ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () {
                        if (_currentStep < 3) {
                          // Validate current step
                          if (_currentStep == 0 && _selectedTemplate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a template'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          if (_currentStep == 1 && !_formKey.currentState!.validate()) {
                            return;
                          }
                          if (_currentStep == 2) {
                            // Allow proceeding with default theme if none selected
                            if (_selectedThemeId == null) {
                              setState(() {
                                _selectedThemeId = -1; // Use default theme
                              });
                            }
                          }

                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _createApplication();
                        }
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_currentStep < 3 ? 'Next' : 'Create Application'),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  Future<void> _createApplication() async {
  final provider = context.read<ApplicationProvider>();

  Application? app;
  if (_selectedTemplate != null && _selectedTemplate != 'blank') {
    // Create from template
    app = await provider.createFromTemplate(
      _selectedTemplate!,
      _nameController.text,
      _packageNameController.text,
    );
  } else {
    // Create blank application
    // Use a default theme ID if none selected
    final themeId = _selectedThemeId == -1 ? 1 : _selectedThemeId;

    app = await provider.createApplication(
      name: _nameController.text,
      packageName: _packageNameController.text,
      description: _descriptionController.text,
      themeId: themeId!,
      version: _versionController.text,
    );
  }

  if (app != null && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application created successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    // Convert id to string for navigation
    context.go('/applications/${app.id.toString()}');  // Add .toString() here
  } else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error ?? 'Failed to create application'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}


  @override
  void dispose() {
    _nameController.dispose();
    _packageNameController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
