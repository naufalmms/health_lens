import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:health_lens/providers/health_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HeartRateDetailPage extends StatefulWidget {
  const HeartRateDetailPage({super.key});

  @override
  _HeartRateDetailPageState createState() => _HeartRateDetailPageState();
}

class _HeartRateDetailPageState extends State<HeartRateDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHeartRateData();
    });
  }

  Future<void> _fetchHeartRateData() async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    await healthProvider.fetchHeartRateData();
  }

  double _extractNumericValue(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return 0.0;
  }

  double _calculateMinHeartRate(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : data
            .map((e) => _extractNumericValue(e.value))
            .reduce((a, b) => a < b ? a : b);
  }

  double _calculateMaxHeartRate(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : data
            .map((e) => _extractNumericValue(e.value))
            .reduce((a, b) => a > b ? a : b);
  }

  double _calculateAvgHeartRate(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : data
                .map((e) => _extractNumericValue(e.value))
                .reduce((a, b) => a + b) /
            data.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Details'),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthProvider.error.isNotEmpty) {
            return Center(child: Text('Error: ${healthProvider.error}'));
          }

          final heartRateData = healthProvider.heartRateData;

          // Prepare data for chart
          final chartData = heartRateData
              .map((e) => FlSpot(e.dateTo.millisecondsSinceEpoch.toDouble(),
                  _extractNumericValue(e.value)))
              .toList();

          return Column(
            children: [
              // Heart Rate Statistics Container
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                        'Min',
                        _calculateMinHeartRate(heartRateData)
                            .toStringAsFixed(1)),
                    _buildStatCard(
                        'Avg',
                        _calculateAvgHeartRate(heartRateData)
                            .toStringAsFixed(1)),
                    _buildStatCard(
                        'Max',
                        _calculateMaxHeartRate(heartRateData)
                            .toStringAsFixed(1)),
                  ],
                ),
              ),

              // Heart Rate Chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Detailed List
              Expanded(
                child: ListView.builder(
                  itemCount: heartRateData.length,
                  itemBuilder: (context, index) {
                    final dataPoint = heartRateData[index];
                    return ListTile(
                      title: Text(
                          'Heart Rate: ${_extractNumericValue(dataPoint.value)} bpm'),
                      subtitle: Text(
                        'Time: ${DateFormat('yyyy-MM-dd HH:mm').format(dataPoint.dateTo)}',
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
