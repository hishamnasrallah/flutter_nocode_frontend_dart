// lib/presentation/applications/applications_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> {
  final _searchController = TextEditingController();
  String _filterStatus = 'all';
  String _sortBy = 'updated';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final provider = context.read<ApplicationProvider>();
    await provider.fetchApplications();
  }

  @override
  Widget build(BuildContext context) {
    final applicationProvider = context.watch<ApplicationProvider>();
    var applications = applicationProvider.applications;

    // Apply filters and search
    if (_searchController.text.isNotEmpty) {
      applications = applications.where((app) =>
        app.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        app.packageName.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    if (_filterStatus != 'all') {
      applications = applications.where((app) => app.buildStatus == _filterStatus).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        applications.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'updated':
        applications.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'created':
        applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.applications),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'not_built', child: Text('Not Built')),
              const PopupMenuItem(value: 'building', child: Text('Building')),
              const PopupMenuItem(value: 'success', child: Text('Built')),
              const PopupMenuItem(value: 'failed', child: Text('Failed')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Name')),
              const PopupMenuItem(value: 'updated', child: Text('Last Updated')),
              const PopupMenuItem(value: 'created', child: Text('Created Date')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search applications...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Applications grid
          Expanded(
            child: applicationProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : applications.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: _loadApplications,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: applications.length,
                          itemBuilder: (context, index) {
                            final app = applications[index];
                            return _buildApplicationCard(context, app);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/applications/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apps_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No applications found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Create your first Flutter app',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (_searchController.text.isEmpty)
            ElevatedButton.icon(
              onPressed: () {
                context.push('/applications/create');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Application'),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, dynamic app) {
    final theme = app.theme;
    final primaryColor = theme != null
        ? Color(int.parse(theme.primaryColor.replaceAll('#', '0xFF')))
        : AppColors.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.push('/applications/${app.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App header with theme color
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.apps,
                  size: 32,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

            // App details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.packageName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_android,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${app.screensCount ?? 0} screens',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          'v${app.version}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _buildStatusChip(app.buildStatus),
                  ],
                ),
              ),
            ),

            // Action buttons
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
                        context.push('/applications/${app.id}/builder');
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
                        _showBuildDialog(context, app);
                      },
                      icon: const Icon(Icons.build, size: 16),
                      label: const Text('Build'),
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

  Widget _buildStatusChip(String status) {
    final color = _getBuildStatusColor(status);
    final label = _getBuildStatusLabel(status);
    final icon = _getBuildStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

  IconData _getBuildStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle_outline;
      case 'building':
        return Icons.sync;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  void _showBuildDialog(BuildContext context, dynamic app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Build Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Build ${app.name}?'),
            const SizedBox(height: 16),
            const Text(
              'This will generate the Flutter code and build an APK file.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
              final result = await provider.buildApplication(app.id.toString());
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Build started'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Build'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
