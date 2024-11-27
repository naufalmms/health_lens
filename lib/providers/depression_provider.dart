// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:health/health.dart';
// import 'package:health_lens/applications/database/firestore_service.dart';
// import 'package:health_lens/providers/health_provider.dart';
// import 'package:sendgrid_mailer/sendgrid_mailer.dart' as mailers;

// class DepressionProvider with ChangeNotifier {
//   final firestoreService = FirestoreService();
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   bool _isDepressed = false;
//   Map<String, dynamic>? _detectionData;
//   String _error = '';
//   String get error => _error;

//   bool get isDepressed => _isDepressed;
//   Map<String, dynamic>? get detectionData => _detectionData;

//   Future<void> initializeNotifications() async {
//     try {
//       // Request notification permissions
//       NotificationSettings settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );

//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         // Initialize local notifications
//         var initializationSettingsAndroid =
//             const AndroidInitializationSettings('@mipmap/ic_launcher');
//         var initializationSettingsIOS = const DarwinInitializationSettings();

//         var initializationSettings = InitializationSettings(
//             android: initializationSettingsAndroid,
//             iOS: initializationSettingsIOS);

//         await flutterLocalNotificationsPlugin.initialize(
//           initializationSettings,
//           onDidReceiveNotificationResponse: (details) {
//             // Handle notification tap
//             if (kDebugMode) {
//               print('Notification tapped: ${details.payload}');
//             }
//           },
//         );

//         // Configure firebase messaging
//         FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//           // Handle foreground messages
//           _showLocalNotification(message);
//         });

//         FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//           // Handle when app is opened from a notification
//           if (kDebugMode) {
//             print('Message opened app: ${message.notification?.title}');
//           }
//         });
//       }
//     } catch (e) {
//       _error = 'Notification initialization failed: $e';
//       if (kDebugMode) {
//         print(_error);
//       }
//     }
//   }

//   void _showLocalNotification(RemoteMessage message) async {
//     // Convert remote message to local notification
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
//       message.notification?.title ?? 'Depression Alert',
//       message.notification?.body ?? 'Depression symptoms detected',
//       platformChannelSpecifics,
//       payload: message.data.toString(),
//     );
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

//   final HealthProvider _healthProvider;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   bool _isLoading = false;
//   bool _needsAssessment = false;
//   DepressionProvider(this._healthProvider);
//   bool get isLoading => _isLoading;
//   bool get needsAssessment => _needsAssessment;

//   double parseHealthValue(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }
//     if (value is String) {
//       try {
//         return double.parse(value);
//       } catch (e) {
//         if (kDebugMode) {
//           print('Could not parse value: $value');
//         }
//         return 0.0; // or handle the error as needed
//       }
//     }
//     return 0.0;
//   }

//   Future<void> analyzeDepressionRisk() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final now = DateTime.now();
//       final fourteenDaysAgo = now.subtract(const Duration(days: 14));

//       await _healthProvider.fetchHealthData();
//       final healthData = _healthProvider.healthData;

//       // Variabel untuk tracking
//       double avgRestingHeartRate = 0;
//       double avgHeartRate = 0;
//       double totalSleepDuration = 0;
//       int totalSteps = 0;
//       int totalDeepSleepDuration = 0;
//       int totalLightSleepDuration = 0;
//       double totalActiveEnergyBurned = 0;
//       double totalWorkoutMinutes = 0;
//       int restingHeartRateDataPoints = 0;
//       int heartRateDataPoints = 0;
//       int sleepDataPoints = 0;

//       // Proses data kesehatan
//       for (var data in healthData) {
//         if (data.dateTo.isAfter(fourteenDaysAgo)) {
//           switch (data.type) {
//             case HealthDataType.RESTING_HEART_RATE:
//               avgRestingHeartRate += double.parse(data.value.toString());
//               if (kDebugMode) {
//                 print(
//                     'NumericHealthValue - type: ${data.value.runtimeType}, value: ${data.value}');
//               }
//               restingHeartRateDataPoints++;
//               break;
//             case HealthDataType.HEART_RATE:
//               // avgHeartRate += double.parse(data.value.toString());
//               // heartRateDataPoints++;
//               avgRestingHeartRate += parseHealthValue(data.value);
//               restingHeartRateDataPoints++;
//               break;
//             case HealthDataType.STEPS:
//               totalSteps += int.parse(data.value.toString());
//               break;
//             case HealthDataType.SLEEP_DEEP:
//               totalDeepSleepDuration += int.parse(data.value.toString());
//               sleepDataPoints++;
//               break;
//             case HealthDataType.SLEEP_LIGHT:
//               totalLightSleepDuration += int.parse(data.value.toString());
//               sleepDataPoints++;
//               break;
//             case HealthDataType.SLEEP_IN_BED:
//               totalSleepDuration += parseHealthValue(data.value);
//               break;
//             case HealthDataType.ACTIVE_ENERGY_BURNED:
//               totalActiveEnergyBurned += parseHealthValue(data.value);
//               break;
//             case HealthDataType.WORKOUT:
//               // Asumsi value workout adalah durasi dalam menit
//               totalWorkoutMinutes += parseHealthValue(data.value);
//               break;
//             case HealthDataType.ATRIAL_FIBRILLATION_BURDEN:
//             // ""
//             case HealthDataType.AUDIOGRAM:
//             // ""
//             case HealthDataType.BASAL_ENERGY_BURNED:
//             // ""
//             case HealthDataType.BLOOD_GLUCOSE:
//             // ""
//             case HealthDataType.BLOOD_OXYGEN:
//             // ""
//             case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
//             // ""
//             case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
//             // ""
//             case HealthDataType.BODY_FAT_PERCENTAGE:
//             // ""
//             case HealthDataType.BODY_MASS_INDEX:
//             // ""
//             case HealthDataType.BODY_TEMPERATURE:
//             // ""
//             case HealthDataType.BODY_WATER_MASS:
//             // ""
//             case HealthDataType.DIETARY_CARBS_CONSUMED:
//             // ""
//             case HealthDataType.DIETARY_CAFFEINE:
//             // ""
//             case HealthDataType.DIETARY_ENERGY_CONSUMED:
//             // ""
//             case HealthDataType.DIETARY_FATS_CONSUMED:
//             // ""
//             case HealthDataType.DIETARY_PROTEIN_CONSUMED:
//             // ""
//             case HealthDataType.DIETARY_FIBER:
//             // ""
//             case HealthDataType.DIETARY_SUGAR:
//             // ""
//             case HealthDataType.DIETARY_FAT_MONOUNSATURATED:
//             // ""
//             case HealthDataType.DIETARY_FAT_POLYUNSATURATED:
//             // ""
//             case HealthDataType.DIETARY_FAT_SATURATED:
//             // ""
//             case HealthDataType.DIETARY_CHOLESTEROL:
//             // ""
//             case HealthDataType.DIETARY_VITAMIN_A:
//             // ""
//             case HealthDataType.DIETARY_THIAMIN:
//             // ""
//             case HealthDataType.DIETARY_RIBOFLAVIN:
//             // ""
//             case HealthDataType.DIETARY_NIACIN:
//             // ""
//             case HealthDataType.DIETARY_PANTOTHENIC_ACID:
//             // ""
//             case HealthDataType.DIETARY_VITAMIN_B6:
//             // ""
//             case HealthDataType.DIETARY_BIOTIN:
//             // ""
//             case HealthDataType.DIETARY_VITAMIN_B12:
//             // ""
//             case HealthDataType.DIETARY_VITAMIN_C:
//             // ""
//             case HealthDataType.DIETARY_VITAMIN_D:
//             // ""
//             case HealthDataType.DIETARY_VITAMIN_E:
//             // ""
//             case HealthDataType.DIETARY_VITAMIN_K:
//             // ""
//             case HealthDataType.DIETARY_FOLATE:
//             // ""
//             case HealthDataType.DIETARY_CALCIUM:
//             // ""
//             case HealthDataType.DIETARY_CHLORIDE:
//             // ""
//             case HealthDataType.DIETARY_IRON:
//             // ""
//             case HealthDataType.DIETARY_MAGNESIUM:
//             // ""
//             case HealthDataType.DIETARY_PHOSPHORUS:
//             // ""
//             case HealthDataType.DIETARY_POTASSIUM:
//             // ""
//             case HealthDataType.DIETARY_SODIUM:
//             // ""
//             case HealthDataType.DIETARY_ZINC:
//             // ""
//             case HealthDataType.DIETARY_CHROMIUM:
//             // ""
//             case HealthDataType.DIETARY_COPPER:
//             // ""
//             case HealthDataType.DIETARY_IODINE:
//             // ""
//             case HealthDataType.DIETARY_MANGANESE:
//             // ""
//             case HealthDataType.DIETARY_MOLYBDENUM:
//             // ""
//             case HealthDataType.DIETARY_SELENIUM:
//             // ""
//             case HealthDataType.FORCED_EXPIRATORY_VOLUME:
//             // ""
//             case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
//             // ""
//             case HealthDataType.HEART_RATE_VARIABILITY_RMSSD:
//             // ""
//             case HealthDataType.HEIGHT:
//             // ""
//             case HealthDataType.INSULIN_DELIVERY:
//             // ""
//             case HealthDataType.RESPIRATORY_RATE:
//             // ""
//             case HealthDataType.PERIPHERAL_PERFUSION_INDEX:
//             // ""
//             case HealthDataType.WAIST_CIRCUMFERENCE:
//             // ""
//             case HealthDataType.WALKING_HEART_RATE:
//             // ""
//             case HealthDataType.WEIGHT:
//             // ""
//             case HealthDataType.DISTANCE_WALKING_RUNNING:
//             // ""
//             case HealthDataType.DISTANCE_SWIMMING:
//             // ""
//             case HealthDataType.DISTANCE_CYCLING:
//             // ""
//             case HealthDataType.FLIGHTS_CLIMBED:
//             // ""
//             case HealthDataType.DISTANCE_DELTA:
//             // ""
//             case HealthDataType.MINDFULNESS:
//             // ""
//             case HealthDataType.WATER:
//             // ""
//             case HealthDataType.SLEEP_ASLEEP:
//             // ""
//             case HealthDataType.SLEEP_AWAKE_IN_BED:
//             // ""
//             case HealthDataType.SLEEP_AWAKE:
//             // ""
//             case HealthDataType.SLEEP_OUT_OF_BED:
//             // ""
//             case HealthDataType.SLEEP_REM:
//             // ""
//             case HealthDataType.SLEEP_SESSION:
//             // ""
//             case HealthDataType.SLEEP_UNKNOWN:
//             // ""
//             case HealthDataType.EXERCISE_TIME:
//             // ""
//             case HealthDataType.HEADACHE_NOT_PRESENT:
//             // ""
//             case HealthDataType.HEADACHE_MILD:
//             // ""
//             case HealthDataType.HEADACHE_MODERATE:
//             // ""
//             case HealthDataType.HEADACHE_SEVERE:
//             // ""
//             case HealthDataType.HEADACHE_UNSPECIFIED:
//             // ""
//             case HealthDataType.NUTRITION:
//             // ""
//             case HealthDataType.GENDER:
//             // ""
//             case HealthDataType.BIRTH_DATE:
//             // ""
//             case HealthDataType.BLOOD_TYPE:
//             // ""
//             case HealthDataType.MENSTRUATION_FLOW:
//             // ""
//             case HealthDataType.HIGH_HEART_RATE_EVENT:
//             // ""
//             case HealthDataType.LOW_HEART_RATE_EVENT:
//             // ""
//             case HealthDataType.IRREGULAR_HEART_RATE_EVENT:
//             // ""
//             case HealthDataType.ELECTRODERMAL_ACTIVITY:
//             // ""
//             case HealthDataType.ELECTROCARDIOGRAM:
//             // ""
//             case HealthDataType.TOTAL_CALORIES_BURNED:
//             // ""
//           }
//         }
//       }

//       // Hitung rata-rata dan total
//       if (restingHeartRateDataPoints > 0 &&
//           heartRateDataPoints > 0 &&
//           sleepDataPoints > 0) {
//         // Rata-rata denyut jantung
//         avgRestingHeartRate = avgRestingHeartRate / restingHeartRateDataPoints;
//         avgHeartRate = avgHeartRate / heartRateDataPoints;

//         // Rata-rata langkah harian
//         double avgDailySteps = totalSteps / 14;

//         // Rata-rata durasi tidur
//         double avgDailySleepDuration = totalSleepDuration / 14;

//         // Rata-rata energi aktif yang dibakar
//         double avgDailyActiveEnergyBurned = totalActiveEnergyBurned / 14;

//         // Rata-rata menit latihan
//         double avgDailyWorkoutMinutes = totalWorkoutMinutes / 14;

//         // Persentase tidur dalam fase deep sleep
//         double deepSleepPercentage = (totalDeepSleepDuration /
//                 (totalDeepSleepDuration + totalLightSleepDuration)) *
//             100;

//         // Kriteria deteksi depresi
//         _isDepressed = (avgRestingHeartRate > 90 ||
//                 avgRestingHeartRate < 50) || // Abnormal resting heart rate
//             (avgHeartRate > 100 ||
//                 avgHeartRate < 60) || // Abnormal average heart rate
//             (avgDailySteps < 3000) || // Low physical activity
//             (avgDailySleepDuration < 6 ||
//                 avgDailySleepDuration > 10) || // Irregular sleep duration
//             (deepSleepPercentage < 10) || // Insufficient deep sleep
//             (avgDailyActiveEnergyBurned < 200) || // Low active energy burned
//             (avgDailyWorkoutMinutes < 30); // Insufficient workout duration

//         _needsAssessment = _isDepressed;

//         // Simpan hasil analisis
//         await _storeAnalysisResults(
//             avgRestingHeartRate,
//             avgHeartRate,
//             avgDailySteps,
//             avgDailySleepDuration,
//             deepSleepPercentage,
//             avgDailyActiveEnergyBurned,
//             avgDailyWorkoutMinutes);

//         // Notifikasi jika terdeteksi risiko depresi
//         if (_isDepressed) {
//           await _notifyEmergencyContact();
//           await showDepressionNotification();
//         }
//       }
//     } catch (e) {
//       _error = 'Gagal menganalisis risiko depresi: $e';
//       if (kDebugMode) {
//         print(_error);
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
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

//   Future<void> _notifyEmergencyContact() async {
//     final userId = _auth.currentUser?.uid;
//     if (userId != null) {
//       final firestoreService = FirestoreService();
//       final contacts = await firestoreService.getUserEmergencyContacts(userId);

//       if (contacts != null && contacts['emergencyEmail'] != null) {
//         try {
//           final mailer = mailers.Mailer('YOUR_SENDGRID_API_KEY');
//           final toAddress = mailers.Address(contacts['emergencyEmail']);
//           final fromAddress = mailers.Address(contacts['userEmail']);
//           final personalization = mailers.Personalization([toAddress]);
//           const subject = 'Depression Symptoms Alert';
//           const content = mailers.Content('text/plain',
//               'Depression symptoms have been detected. Please contact the user and recommend seeking professional help');

//           final message = mailers.Email([personalization], fromAddress, subject,
//               content: [content]);

//           await mailer.send(message);
//         } catch (e) {
//           _error = 'Failed to send emergency notification: $e';
//         }
//       }
//     }
//   }
// }
