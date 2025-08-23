// lib/presentation/applications/application_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/application_provider.dart';
import '../../providers/builder_provider.dart';
import '../../data/models/screen.dart';
import '../../data/models/build_history.dart';
import '../../data/repositories/application_repository.dart';
import '../../data/repositories/screen_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ApplicationRepository _applicationRepository;
  late ScreenRepository _screenRepository;

  List<Screen> _screens = [];
  List<BuildHistory> _buildHistory = [];
  List<Map<String, dynamic>> _dataSources = [];
  bool _isLoadingScreens = false;
  bool _isLoadingBuilds = false;
  bool _isLoadingDataSources = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize repositories
    final storageService = StorageService();
    final apiService = ApiService(storageService);
    _applicationRepository = ApplicationRepository(apiService);
    _screenRepository = ScreenRepository(apiService);

    _loadApplicationDetails();
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 1: // Screens tab
          if (_screens.isEmpty && !_isLoadingScreens) {
            _loadScreens();
          }
          break;
        case 2: // Data tab
          if (_dataSources.isEmpty && !_isLoadingDataSources) {
            _loadDataSources();
          }
          break;
        case 3: // Build tab
          if (_buildHistory.isEmpty && !_isLoadingBuilds) {
            _loadBuildHistory();
          }
          break;
      }
    }
  }

  Future<void> _loadApplicationDetails() async {
    final provider = context.read<ApplicationProvider>();
    await provider.fetchApplicationDetail(widget.applicationId);
  }

  Future<void> _loadScreens() async {
    setState(() {
      _isLoadingScreens = true;
    });

    try {
      final screens = await _screenRepository.getScreens(applicationId: widget.applicationId);
      setState(() {
        _screens = screens;
        _isLoadingScreens = false;
      });
    } catch (e) {
      debugPrint('Error loading screens: $e');
      setState(() {
        _isLoadingScreens = false;
      });
    }
  }

  Future<void> _loadBuildHistory() async {
    setState(() {
      _isLoadingBuilds = true;
    });

    try {
      final history = await _applicationRepository.getBuildHistory(widget.applicationId);
      setState(() {
        _buildHistory = history;
        _isLoadingBuilds = false;
      });
    } catch (e) {
      debugPrint('Error loading build history: $e');
      setState(() {
        _isLoadingBuilds = false;
      });
    }
  }

  Future<void> _loadDataSources() async {
    setState(() {
      _isLoadingDataSources = true;
    });

    try {
      // TODO: Implement data sources API call when endpoint is available
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _dataSources = [];
        _isLoadingDataSources = false;
      });
    } catch (e) {
      debugPrint('Error loading data sources: $e');
      setState(() {
        _isLoadingDataSources = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    final app = provider.selectedApplication;

    if (provider.isLoading && app == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading application',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  provider.error ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadApplicationDetails(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (app == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('The requested application could not be found.'),
              const SizedBox(height: 8),
              Text('Application ID: ${widget.applicationId}'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadApplicationDetails(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
                onTap: () {
                  // TODO: Edit application
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 8),
                    Text('Clone'),
                  ],
                ),
                onTap: () {
                  _showCloneDialog(context, app);
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export'),
                  ],
                ),
                onTap: () async {
                  final data = await provider.exportApplicationJson(app.id.toString());
                  if (data != null) {
                    // TODO: Download JSON file
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application exported')),
                    );
                  }
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
                onTap: () {
                  _showDeleteDialog(context, app);
                },
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Screens'),
            Tab(text: 'Data'),
            Tab(text: 'Build'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(app, provider.statistics),
          _buildScreensTab(app),
          _buildDataTab(app),
          _buildBuildTab(app),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/applications/${app.id}/builder');
        },
        icon: const Icon(Icons.edit),
        label: const Text('Open Builder'),
      ),
    );
  }

  Widget _buildOverviewTab(dynamic app, Map<String, dynamic>? statistics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.apps,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app.packageName,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text('v${app.version}'),
                                  backgroundColor: Colors.grey[200],
                                  labelPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 8),
                                _buildStatusChip(app.buildStatus),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (app.description != null && app.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(app.description!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics
          if (statistics != null) ...[
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Screens',
                  statistics['screens']?['total']?.toString() ?? '0',
                  Icons.phone_android,
                  AppColors.primary,
                ),
                _buildStatCard(
                  'Widgets',
                  statistics['widgets']?['total']?.toString() ?? '0',
                  Icons.widgets,
                  AppColors.accent,
                ),
                _buildStatCard(
                  'Data Sources',
                  statistics['data_sources']?['total']?.toString() ?? '0',
                  Icons.storage,
                  AppColors.info,
                ),
                _buildStatCard(
                  'Actions',
                  statistics['actions']?['total']?.toString() ?? '0',
                  Icons.flash_on,
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Widget distribution chart
            if (statistics['widgets']?['by_type'] != null) ...[
              Text(
                'Widget Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _buildPieChart(statistics['widgets']['by_type']),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildScreensTab(dynamic app) {
    if (_isLoadingScreens) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_screens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No screens yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first screen in the builder',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/applications/${app.id}/builder');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Screen'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScreens,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _screens.length,
        itemBuilder: (context, index) {
          final screen = _screens[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: screen.isHomeScreen
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  screen.isHomeScreen ? Icons.home : Icons.phone_android,
                  color: screen.isHomeScreen ? AppColors.primary : Colors.grey[600],
                ),
              ),
              title: Text(screen.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route: ${screen.routeName}'),
                  if (screen.widgetsCount != null)
                    Text('${screen.widgetsCount} widgets'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (screen.isHomeScreen)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HOME',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.push('/applications/${app.id}/builder');
                      // TODO: Navigate to specific screen in builder
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTab(dynamic app) {
    if (_isLoadingDataSources) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dataSources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data sources configured',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add API endpoints or databases',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to data sources
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Data Source'),
            ),
          ],
        ),
      );
    }

    // TODO: Display data sources when available
    return const Center(
      child: Text('Data sources will be displayed here'),
    );
  }

  Widget _buildBuildTab(dynamic app) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Build actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Build Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final provider = context.read<ApplicationProvider>();
                            final result = await provider.buildApplication(
                              app.id.toString(),
                              generateSourceOnly: true,
                            );
                            if (result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ?? 'Source generated'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.code),
                          label: const Text('Generate Source'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final provider = context.read<ApplicationProvider>();
                            final result = await provider.buildApplication(
                              app.id.toString(),
                            );
                            if (result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ?? 'Build started'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              // Refresh build history
                              _loadBuildHistory();
                            }
                          },
                          icon: const Icon(Icons.build),
                          label: const Text('Build APK'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Build history
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Build History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_buildHistory.isNotEmpty)
                TextButton(
                  onPressed: () {
                    context.push('/builds/${app.id}');
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingBuilds)
            const Center(child: CircularProgressIndicator())
          else if (_buildHistory.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No builds yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Build your application to see history',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              _buildHistory.take(5).length,
              (index) => _buildHistoryCard(_buildHistory[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildHistory build) {
    final isSuccess = build.status == 'success';
    final color = isSuccess ? AppColors.success :
                   build.status == 'failed' ? AppColors.error : AppColors.warning;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.check :
            build.status == 'failed' ? Icons.close : Icons.sync,
            color: color,
          ),
        ),
        title: Text('Build #${build.buildId.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Helpers.formatDateTime(build.buildStartTime)),
            if (build.durationDisplay != null)
              Text('Duration: ${build.durationDisplay}'),
            if (build.apkSizeMb != null && isSuccess)
              Text('Size: ${build.apkSizeMb!.toStringAsFixed(2)} MB'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSuccess && build.apkFile != null)
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  // TODO: Download APK
                },
                tooltip: 'Download APK',
              ),
            IconButton(
              icon: const Icon(Icons.description),
              onPressed: () {
                // TODO: View logs
              },
              tooltip: 'View Logs',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> data) {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    int index = 0;
    data.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: value.toDouble(),
          title: key,
          color: colors[index % colors.length],
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getBuildStatusColor(status);
    final label = _getBuildStatusLabel(status);

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getBuildStatusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.success;
      case 'building':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getBuildStatusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Built';
      case 'building':
        return 'Building';
      case 'failed':
        return 'Failed';
      case 'not_built':
        return 'Not Built';
      default:
        return status;
    }
  }

  void _showCloneDialog(BuildContext context, dynamic app) {
    final nameController = TextEditingController(text: '${app.name} (Copy)');
    final packageController = TextEditingController(text: '${app.packageName}.copy');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clone Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'New Application Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: packageController,
              decoration: const InputDecoration(
                labelText: 'New Package Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<ApplicationProvider>();
              final newApp = await provider.cloneApplication(
                app.id.toString(),
                name: nameController.text,
                packageName: packageController.text,
              );
              if (newApp != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application cloned successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.go('/applications/${newApp.id}');
              }
            },
            child: const Text('Clone'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: Text('Are you sure you want to delete "${app.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<ApplicationProvider>();
              final success = await provider.deleteApplication(app.id.toString());
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application deleted'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.go('/applications');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}