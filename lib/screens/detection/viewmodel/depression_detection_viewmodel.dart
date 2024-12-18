import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:health_lens/applications/database/firestore_service.dart';
import 'package:health_lens/screens/detection/model/depression_risk_model.dart';

class DepressionDetectionProvider with ChangeNotifier {
  DepressionRiskModel? _depressionRiskModel;
  bool _isLoading = false;
  String _error = '';

  DepressionRiskModel? get depressionRiskModel => _depressionRiskModel;
  bool get isLoading => _isLoading;
  String get error => _error;

  bool _isDepressed = false;
  bool get isDepressed => _isDepressed;
  bool _needsAssessment = false;
  bool get needsAssessment => _needsAssessment;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestoreService = FirestoreService();

  Future<void> assessDepressionRisk(
    List<HealthDataPoint> sleepData,
    List<HealthDataPoint> stepsData,
    List<HealthDataPoint> heartRateData,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final userId = _auth.currentUser?.uid;

      int daysWithDepressionIndicators = 0;
      int daysWithValidData = 0;
      double totalRiskScore = 0;
      List<Map<String, dynamic>> dailyDepressionData = [];

      // Analyze each day
      for (int i = 0; i < 14; i++) {
        final currentDate = now.subtract(Duration(days: i));
        final nextDate = currentDate.add(const Duration(days: 1));

        // Filter data for current day
        final dailySleepData = sleepData
            .where((data) =>
                data.dateFrom.isAfter(currentDate) &&
                data.dateTo.isBefore(nextDate))
            .toList();

        final dailyStepsData = stepsData
            .where((data) =>
                data.dateFrom.isAfter(currentDate) &&
                data.dateTo.isBefore(nextDate))
            .toList();

        final dailyHeartRateData = heartRateData
            .where((data) =>
                data.dateFrom.isAfter(currentDate) &&
                data.dateTo.isBefore(nextDate))
            .toList();

        // Check if we have enough data for this day
        bool hasValidData = dailySleepData.isNotEmpty &&
            dailyStepsData.isNotEmpty &&
            dailyHeartRateData.isNotEmpty;

        if (hasValidData) {
          daysWithValidData++;

          // Calculate daily averages
          final dailySleepDuration = dailySleepData
                  .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
                  .reduce((a, b) => a + b) /
              60.0;

          final dailySteps = dailyStepsData
              .map((e) =>
                  (e.value as NumericHealthValue).numericValue.toDouble())
              .reduce((a, b) => a + b);

          final dailyHeartRate = dailyHeartRateData
                  .map((e) =>
                      (e.value as NumericHealthValue).numericValue.toDouble())
                  .reduce((a, b) => a + b) /
              dailyHeartRateData.length;

          // Assess daily risk factors
          final sleepRisk = _assessSleepRisk(dailySleepDuration);
          final stepsRisk = _assessStepsRisk(dailySteps);
          final heartRateRisk = _assessHeartRateRisk(dailyHeartRate);

          // Calculate daily risk
          final List<bool> riskFactors = [sleepRisk, stepsRisk, heartRateRisk];
          final int riskCount = riskFactors.where((risk) => risk).length;

          // If two or more risk factors are present, consider it a day with depression indicators
          if (riskCount >= 2) {
            daysWithDepressionIndicators++;
            totalRiskScore += (riskCount / 3) * 100;

            // Prepare daily depression data
            dailyDepressionData.add({
              'date': currentDate.toIso8601String(),
              'sleepDuration': dailySleepDuration,
              'dailySteps': dailySteps,
              'heartRate': dailyHeartRate,
              'sleepRisk': sleepRisk,
              'stepsRisk': stepsRisk,
              'heartRateRisk': heartRateRisk,
              'riskScore': (riskCount / 3) * 100
            });
          }

          if (kDebugMode) {
            print('Date: ${currentDate.toString()}');
            print('Has Valid Data: Yes');
            print('Sleep Duration: $dailySleepDuration hours');
            print('Steps: $dailySteps');
            print('Heart Rate: $dailyHeartRate');
            print('Risk Count: $riskCount');
            print('Depression Indicators: ${riskCount >= 2 ? 'Yes' : 'No'}\n');
          }
        } else {
          if (kDebugMode) {
            print('Date: ${currentDate.toString()}');
            print('Has Valid Data: No');
            print('Sleep Data: ${dailySleepData.length}');
            print('Steps Data: ${dailyStepsData.length}');
            print('Heart Rate Data: ${dailyHeartRateData.length}');
            print('Depression Indicators: No (Insufficient Data)\n');
          }
        }
      }

      // Calculate average risk score only for days with valid data and depression indicators
      final double averageRiskScore = daysWithDepressionIndicators > 0
          ? totalRiskScore / daysWithDepressionIndicators
          : 0;

      // Only consider depression if we have 14 valid days and sufficient depression indicators
      if (daysWithValidData == 14) {
        _isDepressed = daysWithDepressionIndicators >= 14;
      } else {
        // If we don't have 14 valid days, consider as not depressed
        _isDepressed = false;
        if (kDebugMode) {
          print(
              'Insufficient valid days ($daysWithValidData) for assessment. 14 days required.');
        }
      }

      _needsAssessment = _isDepressed;
      final riskLevel = _determineRiskLevel(averageRiskScore);

      _depressionRiskModel = DepressionRiskModel(
        sleepQualityScore: 0,
        physicalActivityScore: 0,
        heartRateVariabilityScore: 0,
        totalRiskScore: averageRiskScore,
        riskLevel: riskLevel,
        daysWithDepressionIndicators: daysWithDepressionIndicators,
        totalValidDays: daysWithValidData,
      );

      if (userId != null) {
        // Save daily depression data to Firestore
        await _saveDetailedDepressionData(userId, dailyDepressionData);
      }

      if (_isDepressed && userId != null) {
        showDepressionNotification();

        // Check if analysis results have already been stored
        final existingAnalysis = await firestoreService.queryCollection(
            collectionName: 'depression_analysis',
            whereConditions: {'userId': userId},
            limit: 1);

        // Store analysis results if not already stored
        if (existingAnalysis.isEmpty) {
          // Use the _storeAnalysisResults method for the latest day's data
          if (sleepData.isNotEmpty &&
              stepsData.isNotEmpty &&
              heartRateData.isNotEmpty) {
            final latestDayData = await _calculateAveragesFromValidData(
              sleepData,
              stepsData,
              heartRateData,
            );

            await _storeAnalysisResults(
              latestDayData['avgHeartRate']!,
              latestDayData['avgRestingHeartRate']!,
              latestDayData['avgDailySteps']!,
              latestDayData['avgSleepDuration']!,
            );
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Depression risk assessment failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, double>> _calculateAveragesFromValidData(
    List<HealthDataPoint> sleepData,
    List<HealthDataPoint> stepsData,
    List<HealthDataPoint> heartRateData,
  ) async {
    final now = DateTime.now();

    // Variabel untuk menyimpan data yang valid
    List<HealthDataPoint> validSleepData = [];
    List<HealthDataPoint> validStepsData = [];
    List<HealthDataPoint> validHeartRateData = [];

    // Analisis data selama 14 hari terakhir
    for (int i = 0; i < 14; i++) {
      final currentDate = now.subtract(Duration(days: i));
      final nextDate = currentDate.add(const Duration(days: 1));

      final dailySleepData = sleepData
          .where((data) =>
              data.dateFrom.isAfter(currentDate) &&
              data.dateTo.isBefore(nextDate))
          .toList();

      final dailyStepsData = stepsData
          .where((data) =>
              data.dateFrom.isAfter(currentDate) &&
              data.dateTo.isBefore(nextDate))
          .toList();

      final dailyHeartRateData = heartRateData
          .where((data) =>
              data.dateFrom.isAfter(currentDate) &&
              data.dateTo.isBefore(nextDate))
          .toList();

      // Jika data pada hari ini lengkap, tambahkan ke data valid
      if (dailySleepData.isNotEmpty &&
          dailyStepsData.isNotEmpty &&
          dailyHeartRateData.isNotEmpty) {
        validSleepData.addAll(dailySleepData);
        validStepsData.addAll(dailyStepsData);
        validHeartRateData.addAll(dailyHeartRateData);
      }
    }

    // Hitung rata-rata dari data yang valid
    final avgSleepDuration = validSleepData.isEmpty
        ? 0.0
        : validSleepData
                .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
                .reduce((a, b) => a + b) /
            (validSleepData.length * 60.0);

    final avgDailySteps = validStepsData.isEmpty
        ? 0.0
        : validStepsData
                .map((e) =>
                    (e.value as NumericHealthValue).numericValue.toDouble())
                .reduce((a, b) => a + b) /
            validStepsData.length;

    final avgHeartRate = validHeartRateData.isEmpty
        ? 0.0
        : validHeartRateData
                .map((e) =>
                    (e.value as NumericHealthValue).numericValue.toDouble())
                .reduce((a, b) => a + b) /
            validHeartRateData.length;

    return {
      'avgSleepDuration': avgSleepDuration,
      'avgDailySteps': avgDailySteps,
      'avgHeartRate': avgHeartRate,
      'avgRestingHeartRate': avgHeartRate,
    };
  }

  bool _assessSleepRisk(double sleepDuration) {
    return sleepDuration < 6 || sleepDuration > 8;
  }

  bool _assessStepsRisk(double steps) {
    return steps < 3000;
  }

  bool _assessHeartRateRisk(double heartRate) {
    return heartRate > 100;
  }

  String _determineRiskLevel(double riskScore) {
    if (riskScore >= 66) {
      return 'High Risk';
    } else if (riskScore >= 33) {
      return 'Moderate Risk';
    }
    return 'Low Risk';
  }

  Future<void> showDepressionNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'depression_channel',
      'Depression Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Depression Assessment Alert',
      'Depression indicators detected in 8 or more days. Please complete the assessment.',
      platformChannelSpecifics,
      payload: 'depression_assessment',
    );
  }

  Future<void> _saveDetailedDepressionData(
      String userId, List<Map<String, dynamic>> dailyData) async {
    final today = DateTime.now();

    for (var dayData in dailyData) {
      final dataDate = DateTime.parse(dayData['date']);

      // Check if the data is for today or a future date
      if (dataDate.isAtSameMomentAs(today) || dataDate.isAfter(today)) {
        // Check if this day's data already exists
        final existingData = await firestoreService.queryCollection(
            collectionName: 'detailed_depression_data',
            whereConditions: {'userId': userId, 'date': dayData['date']});

        if (existingData.isEmpty) {
          // If no existing data, save the new data
          await firestoreService.saveData(
              collectionName: 'detailed_depression_data',
              data: {
                ...dayData,
                'userId': userId,
                'timestamp': FieldValue.serverTimestamp()
              });

          if (kDebugMode) {
            print('Saved depression data for ${dayData['date']}');
          }
        } else {
          // If data exists and is for today, update the existing data
          await firestoreService.updateDailyDocument(
            collectionName: 'detailed_depression_data',
            documentId: userId,
            data: {
              ...dayData,
              'timestamp': FieldValue.serverTimestamp(),
            },
          );

          if (kDebugMode) {
            print('Updated depression data for ${dayData['date']}');
          }
        }
      } else {
        // Check if this day's data is already saved
        final existingData = await firestoreService.queryCollection(
            collectionName: 'detailed_depression_data',
            whereConditions: {'userId': userId, 'date': dayData['date']});

        // If no existing data, save the day's data
        if (existingData.isEmpty) {
          await firestoreService.saveData(
              collectionName: 'detailed_depression_data',
              data: {
                ...dayData,
                'userId': userId,
                'timestamp': FieldValue.serverTimestamp()
              });

          if (kDebugMode) {
            print('Saved depression data for ${dayData['date']}');
          }
        }
      }
    }
  }

  Future<void> _storeAnalysisResults(
    double avgHeartRate,
    double avgRestingHeartRate,
    double avgDailySteps,
    double avgDailySleepDuration,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      bool success = await firestoreService.saveDepressionAnalysis(
        userId: userId,
        avgRestingHeartRate: avgRestingHeartRate,
        avgHeartRate: avgHeartRate,
        avgDailySteps: avgDailySteps,
        avgDailySleepDuration: avgDailySleepDuration,
        deepSleepPercentage: 0,
        avgDailyActiveEnergyBurned: 0,
        avgDailyWorkoutMinutes: 0,
        isDepressed: _isDepressed,
        needsAssessment: _needsAssessment,
      );

      if (kDebugMode) {
        print(success
            ? 'Depression analysis saved successfully'
            : 'Failed to save depression analysis');
      }
    }
  }
}
