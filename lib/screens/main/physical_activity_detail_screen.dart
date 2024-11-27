import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:health_lens/providers/health_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PhysicalActivityDetailPage extends StatefulWidget {
  const PhysicalActivityDetailPage({super.key});

  @override
  _PhysicalActivityDetailPageState createState() =>
      _PhysicalActivityDetailPageState();
}

class _PhysicalActivityDetailPageState
    extends State<PhysicalActivityDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPhysicalActivityData();
    });
  }

  Future<void> _fetchPhysicalActivityData() async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    await healthProvider.fetchPhysicalActivityData();
  }

  double _calculateTotalActivityDuration(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : data
                .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
                .reduce((a, b) => a + b) /
            60.0;
  }

  double _calculateAvgActivityDuration(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : _calculateTotalActivityDuration(data) / data.length;
  }

  double _calculateMaxActivityDuration(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : data
            .map((e) => e.dateTo.difference(e.dateFrom).inMinutes / 60.0)
            .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Physical Activity Details'),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthProvider.error.isNotEmpty) {
            return Center(child: Text('Error: ${healthProvider.error}'));
          }

          final activityData = healthProvider.physicalActivityData;

          // Prepare data for chart
          final chartData = activityData
              .map((e) => FlSpot(e.dateTo.millisecondsSinceEpoch.toDouble(),
                  e.dateTo.difference(e.dateFrom).inMinutes / 60.0))
              .toList();

          return Column(
            children: [
              // Activity Statistics Container
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('Total',
                        '${_calculateTotalActivityDuration(activityData).toStringAsFixed(1)} hrs'),
                    _buildStatCard('Avg',
                        '${_calculateAvgActivityDuration(activityData).toStringAsFixed(1)} hrs'),
                    _buildStatCard('Max',
                        '${_calculateMaxActivityDuration(activityData).toStringAsFixed(1)} hrs'),
                  ],
                ),
              ),

              // Activity Duration Chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Detailed List
              Expanded(
                child: ListView.builder(
                  itemCount: activityData.length,
                  itemBuilder: (context, index) {
                    final dataPoint = activityData[index];
                    final duration =
                        dataPoint.dateTo.difference(dataPoint.dateFrom);
                    return ListTile(
                      title: Text('Activity: ${dataPoint.type.name}'),
                      subtitle: Text(
                        'Duration: ${duration.inHours} hrs ${duration.inMinutes % 60} mins\n'
                        'Time: ${DateFormat('yyyy-MM-dd HH:mm').format(dataPoint.dateFrom)} '
                        'to ${DateFormat('yyyy-MM-dd HH:mm').format(dataPoint.dateTo)}',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
