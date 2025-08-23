// lib/presentation/widgets/tabs/data_tab/data_tab.dart
import 'package:flutter/material.dart';
import '../../../../../data/models/data_source.dart';
import '../../../../../data/models/action.dart';
import '../../../../../data/repositories/data_source_repository.dart';
import '../../../../../data/repositories/action_repository.dart';
import '../../../../../data/repositories/screen_repository.dart';
import 'data_sources_list.dart';
import 'actions_list.dart';

class DataTab extends StatelessWidget {
  final dynamic application;
  final List<DataSource> dataSources;
  final List<AppAction> actions;
  final bool isLoadingDataSources;
  final bool isLoadingActions;
  final VoidCallback onRefreshDataSources;
  final VoidCallback onRefreshActions;
  final DataSourceRepository dataSourceRepository;
  final ActionRepository actionRepository;
  final ScreenRepository screenRepository; // Add this

  const DataTab({
    super.key,
    required this.application,
    required this.dataSources,
    required this.actions,
    required this.isLoadingDataSources,
    required this.isLoadingActions,
    required this.onRefreshDataSources,
    required this.onRefreshActions,
    required this.dataSourceRepository,
    required this.actionRepository,
    required this.screenRepository, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Data Sources'),
              Tab(text: 'Actions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                DataSourcesList(
                  dataSources: dataSources,
                  onRefresh: onRefreshDataSources,
                  dataSourceRepository: dataSourceRepository,
                ),
                isLoadingActions
                  ? const Center(child: CircularProgressIndicator())
                  : ActionsList(
                      actions: actions,
                      onRefresh: onRefreshActions,
                      actionRepository: actionRepository,
                      screenRepository: screenRepository,
                      dataSourceRepository: dataSourceRepository,
                      applicationId: application.id.toString(),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}