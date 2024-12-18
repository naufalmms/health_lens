import 'package:flutter/material.dart';
import 'package:health_lens/screens/detection/model/depression_risk_model.dart';
import 'package:health_lens/screens/detection/viewmodel/depression_detection_viewmodel.dart';
import 'package:health_lens/screens/main/assessment_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';
import 'package:health_lens/providers/health_provider.dart';

class DepressionDetectionPage extends StatefulWidget {
  const DepressionDetectionPage({super.key});

  @override
  _DepressionDetectionPageState createState() =>
      _DepressionDetectionPageState();
}

class _DepressionDetectionPageState extends State<DepressionDetectionPage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndAnalyzeData();
    });
  }

  Future<void> _fetchAndAnalyzeData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final healthProvider =
          Provider.of<HealthProvider>(context, listen: false);
      final depressionProvider =
          Provider.of<DepressionDetectionProvider>(context, listen: false);

      await Future.wait([
        healthProvider.fetchPhysicalActivityData(),
        healthProvider.fetchSleepData(),
        healthProvider.fetchHeartRateData(),
      ]);

      await depressionProvider.assessDepressionRisk(
        healthProvider.sleepData, // parameter 1
        healthProvider.physicalActivityData, // parameter 2 (stepsData)
        healthProvider.heartRateData, // parameter 3
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depression Risk Assessment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _fetchAndAnalyzeData,
          ),
        ],
      ),
      body: Consumer<DepressionDetectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || _isRefreshing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing health data...'),
                ],
              ),
            );
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchAndAnalyzeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final riskModel = provider.depressionRiskModel;
          if (riskModel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('No data available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchAndAnalyzeData,
                    child: const Text('Refresh Data'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchAndAnalyzeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  provider.isDepressed
                      ? _buildRiskLevelCard(riskModel)
                      : const SizedBox(),
                  const SizedBox(height: 16),
                  _buildDataValidityCard(riskModel),
                  const SizedBox(height: 16),
                  _buildScoreBreakdown(riskModel),
                  const SizedBox(height: 16),
                  _buildRecommendations(riskModel, provider),
                  if (provider.isDepressed) ...[
                    const SizedBox(height: 16),
                    _buildWarningCard(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataValidityCard(DepressionRiskModel riskModel) {
    final validDaysPercentage =
        (riskModel.totalValidDays / 14 * 100).toStringAsFixed(1);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Analysis Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Valid days of data: ${riskModel.totalValidDays}/14 ($validDaysPercentage%)',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Days with depression indicators: ${riskModel.daysWithDepressionIndicators}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskLevelCard(DepressionRiskModel riskModel) {
    return Card(
      color: _getRiskColor(riskModel.riskLevel),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Depression Risk: ${riskModel.riskLevel}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Risk Score: ${riskModel.totalRiskScore.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBreakdown(DepressionRiskModel riskModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Factors Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildIndicatorRow('Sleep Pattern', riskModel.sleepQualityScore),
            const SizedBox(height: 8),
            _buildIndicatorRow(
                'Physical Activity', riskModel.physicalActivityScore),
            const SizedBox(height: 8),
            _buildIndicatorRow(
                'Heart Rate', riskModel.heartRateVariabilityScore),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_getIndicatorColor(value)),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            color: _getIndicatorColor(value),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Depression Risk Alert',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Depression indicators have been detected. It is recommended to complete a detailed assessment.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                pushScreen(
                  context,
                  screen: const AssessmentScreen(),
                  withNavBar: false,
                );
              },
              icon: const Icon(Icons.assessment),
              label: const Text('Take Assessment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(
      DepressionRiskModel riskModel, DepressionDetectionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getRecommendationText(riskModel.riskLevel, provider.isDepressed),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'High Risk':
        return Colors.red;
      case 'Moderate Risk':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _getIndicatorColor(double value) {
    if (value > 75) return Colors.red;
    if (value > 50) return Colors.orange;
    return Colors.green;
  }

  String _getRecommendationText(String riskLevel, bool isDepressed) {
    if (isDepressed) {
      switch (riskLevel) {
        case 'High Risk':
          return 'We strongly recommend consulting a mental health professional. Your health indicators over the past two weeks suggest a significant risk of depression.';
        case 'Moderate Risk':
          return 'Consider speaking with a healthcare provider. Your health patterns indicate potential mental health concerns that could benefit from professional guidance.';
        default:
          return 'Your health indicators over the past two weeks suggest a low risk of depression. Continue maintaining your healthy lifestyle habits.';
      }
    }
    return 'Your health indicators over the past two weeks suggest a low risk of depression. Continue maintaining your healthy lifestyle habits.';
  }
}
