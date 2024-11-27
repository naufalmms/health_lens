import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:health_lens/providers/health_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SleepPatternDetailPage extends StatefulWidget {
  const SleepPatternDetailPage({super.key});

  @override
  _SleepPatternDetailPageState createState() => _SleepPatternDetailPageState();
}

class _SleepPatternDetailPageState extends State<SleepPatternDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSleepData();
    });
  }

  Future<void> _fetchSleepData() async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    await healthProvider.fetchSleepData();
  }

  double _calculateTotalSleepDuration(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : data
                .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
                .reduce((a, b) => a + b) /
            60.0;
  }

  double _calculateAvgSleepDuration(List<HealthDataPoint> data) {
    return data.isEmpty ? 0 : _calculateTotalSleepDuration(data) / data.length;
  }

  double _calculateMaxSleepDuration(List<HealthDataPoint> data) {
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
        title: const Text('Sleep Pattern Details'),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthProvider.error.isNotEmpty) {
            return Center(child: Text('Error: ${healthProvider.error}'));
          }

          final sleepData = healthProvider.sleepData;

          // Prepare data for chart
          final chartData = sleepData
              .map((e) => FlSpot(e.dateTo.millisecondsSinceEpoch.toDouble(),
                  e.dateTo.difference(e.dateFrom).inMinutes / 60.0))
              .toList();

          return Column(
            children: [
              // Sleep Statistics Container
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('Total',
                        '${_calculateTotalSleepDuration(sleepData).toStringAsFixed(1)} hrs'),
                    _buildStatCard('Avg',
                        '${_calculateAvgSleepDuration(sleepData).toStringAsFixed(1)} hrs'),
                    _buildStatCard('Max',
                        '${_calculateMaxSleepDuration(sleepData).toStringAsFixed(1)} hrs'),
                  ],
                ),
              ),

              // Sleep Duration Chart
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
                          color: Colors.purple,
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
                  itemCount: sleepData.length,
                  itemBuilder: (context, index) {
                    final dataPoint = sleepData[index];
                    final duration =
                        dataPoint.dateTo.difference(dataPoint.dateFrom);
                    return ListTile(
                      title: Text(
                          'Sleep Duration: ${duration.inHours} hrs ${duration.inMinutes % 60} mins'),
                      subtitle: Text(
                        'From: ${DateFormat('yyyy-MM-dd HH:mm').format(dataPoint.dateFrom)} '
                        'To: ${DateFormat('yyyy-MM-dd HH:mm').format(dataPoint.dateTo)}',
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
