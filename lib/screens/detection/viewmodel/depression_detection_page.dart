// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:health/health.dart';
// import 'package:health_lens/applications/database/firestore_service.dart';
// import 'package:health_lens/screens/detection/model/depression_risk_model.dart';

// class DepressionDetectionProvider with ChangeNotifier {
//   DepressionRiskModel? _depressionRiskModel;
//   bool _isLoading = false;
//   String _error = '';

//   DepressionRiskModel? get depressionRiskModel => _depressionRiskModel;
//   bool get isLoading => _isLoading;
//   String get error => _error;

//   bool _isDepressed = false;
//   bool get isDepressed => _isDepressed;
//   bool _needsAssessment = false;
//   bool get needsAssessment => _needsAssessment;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final firestoreService = FirestoreService();

//   Future<void> assessDepressionRisk(
//     List<HealthDataPoint> physicalActivityData,
//     List<HealthDataPoint> sleepData,
//     List<HealthDataPoint> heartRateData,
//   ) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       // Calculate health metrics
//       final totalActivityDuration = physicalActivityData.isEmpty
//           ? 0.0
//           : physicalActivityData
//                   .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
//                   .reduce((a, b) => a + b) /
//               60.0;

//       final avgSleepDuration = sleepData.isEmpty
//           ? 0.0
//           : sleepData
//                   .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
//                   .reduce((a, b) => a + b) /
//               (sleepData.length * 60.0);

//       final heartRates = heartRateData
//           .map((e) => (e.value as NumericHealthValue).numericValue.toDouble())
//           .toList();

//       // Calculate averages for storage
//       final avgRestingHeartRate = heartRates.isEmpty
//           ? 0.0
//           : heartRates.reduce((a, b) => a + b) / heartRates.length;
//       final avgHeartRate =
//           avgRestingHeartRate; // Using resting heart rate as average for simplicity

//       // Calculate activity metrics
//       final avgDailySteps = physicalActivityData.isEmpty
//           ? 0.0
//           : physicalActivityData
//                   .where((e) => e.type == HealthDataType.STEPS)
//                   .map((e) =>
//                       (e.value as NumericHealthValue).numericValue.toDouble())
//                   .fold(0.0, (a, b) => a + b) /
//               (physicalActivityData.isNotEmpty
//                   ? physicalActivityData.length
//                   : 1);

//       // Calculate sleep metrics
//       final deepSleepPercentage = sleepData.isEmpty
//           ? 0.0
//           : sleepData.where((e) => e.type == HealthDataType.SLEEP_DEEP).length /
//               sleepData.length *
//               100;

//       // Calculate energy and workout metrics
//       final avgDailyActiveEnergyBurned = physicalActivityData.isEmpty
//           ? 0.0
//           : physicalActivityData
//                   .where((e) => e.type == HealthDataType.ACTIVE_ENERGY_BURNED)
//                   .map((e) =>
//                       (e.value as NumericHealthValue).numericValue.toDouble())
//                   .fold(0.0, (a, b) => a + b) /
//               (physicalActivityData.isNotEmpty
//                   ? physicalActivityData.length
//                   : 1);

//       final avgDailyWorkoutMinutes = totalActivityDuration /
//           (physicalActivityData.isEmpty ? 1 : physicalActivityData.length);

//       // Perform risk assessment
//       final physicalActivityScore =
//           _assessPhysicalActivity(totalActivityDuration);
//       final sleepQualityScore = _assessSleepQuality(avgSleepDuration);
//       final heartRateVariabilityScore = _assessHeartRateVariability(heartRates);

//       final totalRiskScore = _calculateTotalRiskScore(
//         physicalActivityScore,
//         sleepQualityScore,
//         heartRateVariabilityScore,
//       );

//       _depressionRiskModel = DepressionRiskModel(
//         physicalActivityScore: physicalActivityScore,
//         sleepQualityScore: sleepQualityScore,
//         heartRateVariabilityScore: heartRateVariabilityScore,
//         totalRiskScore: totalRiskScore,
//         riskLevel: _determineRiskLevel(totalRiskScore),
//       );

//       // Store analysis results
//       await _storeAnalysisResults(
//         avgRestingHeartRate,
//         avgHeartRate,
//         avgDailySteps,
//         avgSleepDuration,
//         deepSleepPercentage,
//         avgDailyActiveEnergyBurned,
//         avgDailyWorkoutMinutes,
//       );

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _error = 'Depression risk assessment failed: $e';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   double _assessPhysicalActivity(double totalActivityDuration) {
//     // Less activity indicates higher depression risk
//     if (totalActivityDuration < 2) return 100.0;
//     if (totalActivityDuration < 4) return 75.0;
//     if (totalActivityDuration < 6) return 50.0;
//     if (totalActivityDuration < 8) return 25.0;
//     return 0.0;
//   }

//   double _assessSleepQuality(double avgSleepDuration) {
//     // Abnormal sleep duration indicates higher risk
//     if (avgSleepDuration < 4 || avgSleepDuration > 10) return 100.0;
//     if (avgSleepDuration < 5 || avgSleepDuration > 9) return 75.0;
//     if (avgSleepDuration < 6 || avgSleepDuration > 8) return 50.0;
//     return 0.0;
//   }

//   double _assessHeartRateVariability(List<double> heartRates) {
//     if (heartRates.isEmpty) return 50.0;

//     // final avgHeartRate = heartRates.reduce((a, b) => a + b) / heartRates.length;
//     final minHeartRate = heartRates.reduce((a, b) => a < b ? a : b);
//     final maxHeartRate = heartRates.reduce((a, b) => a > b ? a : b);

//     final variability = maxHeartRate - minHeartRate;

//     // Higher variability might indicate stress/anxiety
//     if (variability > 40) return 100.0;
//     if (variability > 30) return 75.0;
//     if (variability > 20) return 50.0;
//     return 0.0;
//   }

//   double _calculateTotalRiskScore(
//     double physicalActivityScore,
//     double sleepQualityScore,
//     double heartRateVariabilityScore,
//   ) {
//     return (physicalActivityScore +
//             sleepQualityScore +
//             heartRateVariabilityScore) /
//         3;
//   }

//   String _determineRiskLevel(double totalRiskScore) {
//     if (totalRiskScore > 75) {
//       _isDepressed = true;
//       _needsAssessment = true;
//       showDepressionNotification();
//       return 'High Risk';
//     }
//     if (totalRiskScore > 50) {
//       _isDepressed = true;
//       _needsAssessment = true;
//       showDepressionNotification();
//       return 'Moderate Risk';
//     }
//     _isDepressed = false;
//     _needsAssessment = false;
//     return 'Low Risk';
//   }

//   Future<void> showDepressionNotification() async {
//     var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'depression_channel',
//       'Depression Alerts',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//     var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Depression Assessment Alert',
//       'Depression symptoms detected. Please complete the assessment.',
//       platformChannelSpecifics,
//       payload: 'depression_assessment',
//     );
//   }

//   Future<void> _storeAnalysisResults(
//       double avgRestingHeartRate,
//       double avgHeartRate,
//       double avgDailySteps,
//       double avgDailySleepDuration,
//       double deepSleepPercentage,
//       double avgDailyActiveEnergyBurned,
//       double avgDailyWorkoutMinutes) async {
//     final userId = _auth.currentUser?.uid;
//     if (userId != null) {
//       bool success = await firestoreService.saveDepressionAnalysis(
//         userId: userId,
//         avgRestingHeartRate: avgRestingHeartRate,
//         avgHeartRate: avgHeartRate,
//         avgDailySteps: avgDailySteps,
//         avgDailySleepDuration: avgDailySleepDuration,
//         deepSleepPercentage: deepSleepPercentage,
//         avgDailyActiveEnergyBurned: avgDailyActiveEnergyBurned,
//         avgDailyWorkoutMinutes: avgDailyWorkoutMinutes,
//         isDepressed: _isDepressed,
//         needsAssessment: _needsAssessment,
//       );

//       if (success) {
//         if (kDebugMode) {
//           print('Depression analysis saved successfully');
//         }
//       } else {
//         if (kDebugMode) {
//           print('Failed to save depression analysis');
//         }
//       }
//     }
//   }
// }

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
      // final fourteenDaysAgo = now.subtract(const Duration(days: 14));

      int daysWithDepressionIndicators = 0;
      int daysWithValidData = 0;
      double totalRiskScore = 0;

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

      // Only consider depression if we have enough valid days and enough days with indicators
      if (daysWithValidData >= 8) {
        _isDepressed = daysWithDepressionIndicators >= 8;
      } else {
        // If we don't have enough valid days, consider as not depressed
        _isDepressed = false;
        if (kDebugMode) {
          print(
              'Insufficient valid days ($daysWithValidData) for assessment. Minimum 8 days required.');
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

      if (_isDepressed) {
        showDepressionNotification();
      }

      // Store the latest day's data if available
      if (sleepData.isNotEmpty &&
          stepsData.isNotEmpty &&
          heartRateData.isNotEmpty) {
        final latestDayData = await _calculateLatestDayAverages(
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Depression risk assessment failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, double>> _calculateLatestDayAverages(
    List<HealthDataPoint> sleepData,
    List<HealthDataPoint> stepsData,
    List<HealthDataPoint> heartRateData,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final latestSleepData = sleepData
        .where((data) =>
            data.dateFrom.isAfter(today) && data.dateTo.isBefore(tomorrow))
        .toList();
    final latestStepsData = stepsData
        .where((data) =>
            data.dateFrom.isAfter(today) && data.dateTo.isBefore(tomorrow))
        .toList();
    final latestHeartRateData = heartRateData
        .where((data) =>
            data.dateFrom.isAfter(today) && data.dateTo.isBefore(tomorrow))
        .toList();

    final avgSleepDuration = latestSleepData.isEmpty
        ? 0.0
        : latestSleepData
                .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
                .reduce((a, b) => a + b) /
            60.0;

    final avgDailySteps = latestStepsData.isEmpty
        ? 0.0
        : latestStepsData
            .map((e) => (e.value as NumericHealthValue).numericValue.toDouble())
            .reduce((a, b) => a + b);

    final avgHeartRate = latestHeartRateData.isEmpty
        ? 0.0
        : latestHeartRateData
                .map((e) =>
                    (e.value as NumericHealthValue).numericValue.toDouble())
                .reduce((a, b) => a + b) /
            latestHeartRateData.length;

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