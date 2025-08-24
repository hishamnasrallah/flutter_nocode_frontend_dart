
// lib/presentation/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
bool _hasInitialLoad = false;

  @override
  void initState() {
    super.initState();
    // Load data after frame is rendered to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add a small delay to ensure tokens are properly saved
      await Future.delayed(const Duration(milliseconds: 500));
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (_hasInitialLoad) return;

    final applicationProvider = context.read<ApplicationProvider>();

    debugPrint('📊 Dashboard loading data...');

    try {
      await applicationProvider.fetchApplications();
      _hasInitialLoad = true;
    } catch (e) {
      debugPrint('📊 Dashboard load error: $e');
      // Retry once after a delay
      if (!_hasInitialLoad) {
        await Future.delayed(const Duration(seconds: 1));
        try {
          await applicationProvider.fetchApplications();
          _hasInitialLoad = true;
        } catch (retryError) {
          debugPrint('📊 Dashboard retry failed: $retryError');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                authProvider.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                child: const Text('Profile'),
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
              PopupMenuItem(
                child: const Text('Settings'),
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () async {
                  await authProvider.logout();
                  if (mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(authProvider),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Statistics cards
              _buildStatisticsCards(applicationProvider),
              const SizedBox(height: 24),

              // Recent projects
              _buildRecentProjects(context, applicationProvider),
              const SizedBox(height: 24),

              // Activity chart
              _buildActivityChart(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/applications/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('New App'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.flutter_dash,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text(AppStrings.dashboard),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text(AppStrings.applications),
            onTap: () {
              Navigator.pop(context);
              context.push('/applications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text(AppStrings.themes),
            onTap: () {
              Navigator.pop(context);
              context.push('/themes');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    final user = authProvider.user;
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, ${user?.firstName ?? user?.username ?? 'User'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ready to build something amazing today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.rocket_launch,
            size: 64,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.add_circle, 'label': 'New App', 'color': AppColors.success},
      {'icon': Icons.palette, 'label': 'Themes', 'color': AppColors.accent},
      {'icon': Icons.widgets, 'label': 'Templates', 'color': AppColors.info},
      {'icon': Icons.history, 'label': 'Builds', 'color': AppColors.warning},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              elevation: 2,
              child: InkWell(
                onTap: () {
                  // Handle action tap
                  switch (index) {
                    case 0:
                      context.push('/applications/create');
                      break;
                    case 1:
                      context.push('/themes');
                      break;
                    case 2:
                      // TODO: Show templates
                      break;
                    case 3:
                      // TODO: Show builds
                      break;
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      size: 32,
                      color: action['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(ApplicationProvider applicationProvider) {
    final stats = [
      {
        'title': 'Total Apps',
        'value': '${applicationProvider.applications.length}',
        'icon': Icons.apps,
        'color': AppColors.primary,
      },
      {
        'title': 'Successful Builds',
        'value': '${applicationProvider.applications.where((app) => app.buildStatus == 'success').length}',
        'icon': Icons.check_circle,
        'color': AppColors.success,
      },
      {
        'title': 'Total Screens',
        'value': '${applicationProvider.applications.fold(0, (sum, app) => sum + (app.screensCount ?? 0))}',
        'icon': Icons.phone_android,
        'color': AppColors.info,
      },
      {
        'title': 'Active Projects',
        'value': '${applicationProvider.applications.where((app) => app.buildStatus == 'building').length}',
        'icon': Icons.engineering,
        'color': AppColors.warning,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.statistics,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          stat['icon'] as IconData,
                          color: stat['color'] as Color,
                          size: 24,
                        ),
                        Text(
                          stat['value'] as String,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: stat['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      stat['title'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentProjects(BuildContext context, ApplicationProvider applicationProvider) {
    final recentApps = applicationProvider.applications.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentProjects,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/applications');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentApps.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No applications yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/applications/create');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Your First App'),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentApps.length,
            itemBuilder: (context, index) {
              final app = recentApps[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getBuildStatusColor(app.buildStatus),
                    child: const Icon(
                      Icons.apps,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(app.name),
                  subtitle: Text('Version ${app.version} • ${app.packageName}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusChip(app.buildStatus),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          context.push('/applications/${app.id}');
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    context.push('/applications/${app.id}');
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActivityChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 5),
                        const FlSpot(2, 4),
                        const FlSpot(3, 7),
                        const FlSpot(4, 6),
                        const FlSpot(5, 8),
                        const FlSpot(6, 5),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getBuildStatusColor(status);
    final label = _getBuildStatusLabel(status);

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
