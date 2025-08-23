// lib/presentation/applications/application_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/builder_provider.dart';
import '../../data/models/screen.dart';
import '../../data/models/build_history.dart';
import '../../data/models/data_source.dart';
import '../../data/repositories/application_repository.dart';
import '../../data/repositories/screen_repository.dart';
import '../../data/repositories/data_source_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

// Import widgets
import '../widgets/tabs/overview_tab.dart';
import '../widgets/tabs/screens_tab.dart';
import '../widgets/tabs/data_tab/data_tab.dart';
import '../widgets/tabs/build_tab.dart';
import '../widgets/dialogs/clone_application_dialog.dart';
import '../widgets/dialogs/delete_application_dialog.dart';
import '../widgets/components/application_status_chip.dart';

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
  late DataSourceRepository _dataSourceRepository;

  List<Screen> _screens = [];
  List<BuildHistory> _buildHistory = [];
  List<DataSource> _dataSources = [];
  List<dynamic> _actions = [];
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
    _dataSourceRepository = DataSourceRepository(apiService);

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

    // Extract actions from the application data if available
    if (provider.selectedApplication != null) {
      _extractActionsFromStatistics(provider.statistics);
    }
  }

  void _extractActionsFromStatistics(Map<String, dynamic>? statistics) {
    setState(() {
      _actions = statistics?['actions'] ?? [];
    });
  }

  Future<void> _loadScreens() async {
    setState(() {
      _isLoadingScreens = true;
    });

    try {
      debugPrint('📱 Loading screens for application: ${widget.applicationId}');
      final screens = await _screenRepository.getScreens(applicationId: widget.applicationId);
      debugPrint('📱 Successfully loaded ${screens.length} screens');

      setState(() {
        _screens = screens;
        _isLoadingScreens = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading screens: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      setState(() {
        _isLoadingScreens = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load screens: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      debugPrint('📊 Loading data sources for application: ${widget.applicationId}');
      final dataSources = await _dataSourceRepository.getDataSources(
        applicationId: widget.applicationId,
      );
      debugPrint('📊 Successfully loaded ${dataSources.length} data sources');

      setState(() {
        _dataSources = dataSources;
        _isLoadingDataSources = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading data sources: $e');
      setState(() {
        _isLoadingDataSources = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data sources: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      return _buildErrorState(provider);
    }

    if (app == null) {
      return _buildNotFoundState();
    }

    return Scaffold(
      appBar: _buildAppBar(app, provider),
      body: TabBarView(
        controller: _tabController,
        children: [
          OverviewTab(
            application: app,
            statistics: provider.statistics,
          ),
          ScreensTab(
            application: app,
            screens: _screens,
            isLoading: _isLoadingScreens,
            onRefresh: _loadScreens,
          ),
          DataTab(
            application: app,
            dataSources: _dataSources,
            actions: _actions,
            isLoadingDataSources: _isLoadingDataSources,
            onRefreshDataSources: _loadDataSources,
            dataSourceRepository: _dataSourceRepository,
          ),
          BuildTab(
            application: app,
            buildHistory: _buildHistory,
            isLoading: _isLoadingBuilds,
            onRefresh: _loadBuildHistory,
            applicationProvider: context.read<ApplicationProvider>(),
          ),
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

  PreferredSizeWidget _buildAppBar(dynamic app, ApplicationProvider provider) {
    return AppBar(
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
                showCloneApplicationDialog(context, app, provider);
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
                showDeleteApplicationDialog(context, app, provider);
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
    );
  }

  Widget _buildErrorState(ApplicationProvider provider) {
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

  Widget _buildNotFoundState() {
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}