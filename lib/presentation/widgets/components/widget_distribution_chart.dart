// lib/presentation/applications/widgets/components/widget_distribution_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class WidgetDistributionChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const WidgetDistributionChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = _buildChartSections();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
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

    return sections;
  }
}