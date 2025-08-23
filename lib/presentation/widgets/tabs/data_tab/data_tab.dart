// lib/presentation/applications/widgets/tabs/data_tab/data_tab.dart
import 'package:flutter/material.dart';
import '../../../../../data/models/data_source.dart';
import '../../../../../data/repositories/data_source_repository.dart';
import 'data_sources_list.dart';
import 'actions_list.dart';

class DataTab extends StatelessWidget {
  final dynamic application;
  final List<DataSource> dataSources;
  final List<dynamic> actions;
  final bool isLoadingDataSources;
  final VoidCallback onRefreshDataSources;
  final DataSourceRepository dataSourceRepository;

  const DataTab({
    super.key,
    required this.application,
    required this.dataSources,
    required this.actions,
    required this.isLoadingDataSources,
    required this.onRefreshDataSources,
    required this.dataSourceRepository,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingDataSources) {
      return const Center(child: CircularProgressIndicator());
    }

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
                ActionsList(
                  actions: actions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}