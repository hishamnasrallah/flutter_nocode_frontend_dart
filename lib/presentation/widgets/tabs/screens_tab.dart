// lib/presentation/applications/widgets/tabs/screens_tab.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/screen.dart';
import '../../../../core/constants/app_colors.dart';

class ScreensTab extends StatelessWidget {
  final dynamic application;
  final List<Screen> screens;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ScreensTab({
    super.key,
    required this.application,
    required this.screens,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (screens.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: screens.length,
        itemBuilder: (context, index) {
          final screen = screens[index];
          return _buildScreenCard(context, screen);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              context.push('/applications/${application.id}/builder');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Screen'),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenCard(BuildContext context, Screen screen) {
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
                context.push('/applications/${application.id}/builder');
              },
            ),
          ],
        ),
      ),
    );
  }
}