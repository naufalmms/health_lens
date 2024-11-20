import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

enum HealthServiceStatus { available, needsInstallation, unavailable, unknown }

class HealthProvider with ChangeNotifier {
  final Health _health = Health();
  List<HealthDataPoint> _healthData = [];
  bool _isLoading = false;
  String _error = '';
  int _steps = 0;
  HealthServiceStatus _serviceStatus = HealthServiceStatus.unknown;

  // Getters
  List<HealthDataPoint> get healthData => _healthData;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get steps => _steps;
  HealthServiceStatus get serviceStatus => _serviceStatus;

  // Health data types to fetch
  static final types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  ];

  Future<HealthServiceStatus> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Configure Health
      await _health.configure();

      if (Platform.isAndroid) {
        final status = await _checkAndHandleHealthConnect();
        _serviceStatus = status;
        if (status != HealthServiceStatus.available) {
          _error = 'Health Connect is not available or needs installation';
          notifyListeners();
          return status;
        }
      }

      _serviceStatus = HealthServiceStatus.available;
      return HealthServiceStatus.available;
    } catch (e) {
      _error = 'Failed to initialize health services: $e';
      _serviceStatus = HealthServiceStatus.unavailable;
      return HealthServiceStatus.unavailable;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<HealthServiceStatus> _checkAndHandleHealthConnect() async {
  //   try {
  //     final status = await _health.getHealthConnectSdkStatus();

  //     switch (status) {
  //       case HealthConnectSdkStatus.sdkUnavailable:
  //         return HealthServiceStatus.unavailable;

  //       case HealthConnectSdkStatus.sdkAvailable:
  //         return HealthServiceStatus.available;

  //       default:
  //         return HealthServiceStatus.unknown;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error checking Health Connect status: $e');
  //     }
  //     return HealthServiceStatus.unknown;
  //   }
  // }

  Future<HealthServiceStatus> _checkAndHandleHealthConnect() async {
    try {
      final status = await _health.getHealthConnectSdkStatus();

      switch (status) {
        case HealthConnectSdkStatus.sdkUnavailable:
          return HealthServiceStatus.needsInstallation;

        case HealthConnectSdkStatus.sdkAvailable:
          return HealthServiceStatus.available;

        default:
          // Explicitly check if Health Connect is installed
          try {
            await _health.installHealthConnect();
            return HealthServiceStatus.needsInstallation;
          } catch (installError) {
            // If installation fails, it likely means Health Connect is not supported
            return HealthServiceStatus.unavailable;
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Health Connect status: $e');
      }
      return HealthServiceStatus.unavailable;
    }
  }

  Future<bool> installHealthConnect() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (Platform.isAndroid) {
        await _health.installHealthConnect();
        final status = await _checkAndHandleHealthConnect();
        return status == HealthServiceStatus.available;
      }
      return false;
    } catch (e) {
      _error = 'Failed to install Health Connect: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestAuthorization() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // First check if Health Connect is available on Android
      if (Platform.isAndroid &&
          _serviceStatus != HealthServiceStatus.available) {
        _error = 'Health Connect is not available. Please install it first.';
        return false;
      }

      // Request activity recognition permission
      final activityStatus = await Permission.activityRecognition.request();
      if (activityStatus.isDenied) {
        _error = 'Activity recognition permission denied';
        return false;
      }

      // Request health permissions
      final hasPermissions = await _health.hasPermissions(types);

      if (hasPermissions == null || !hasPermissions) {
        final granted = await _health.requestAuthorization(types);
        return granted;
      }

      return true;
    } catch (e) {
      _error = 'Failed to request authorization: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHealthData() async {
    if (_serviceStatus != HealthServiceStatus.available) {
      _error = 'Health services are not available';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      final healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: yesterday,
        endTime: now,
      );

      _healthData = _health.removeDuplicates(healthData);
      _healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
    } catch (e) {
      _error = 'Failed to fetch health data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSteps() async {
    if (_serviceStatus != HealthServiceStatus.available) {
      _error = 'Health services are not available';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now);
      _steps = steps ?? 0;
    } catch (e) {
      _error = 'Failed to fetch steps: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> revokeAccess() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _health.revokePermissions();
      _healthData = [];
      _steps = 0;
      _serviceStatus = HealthServiceStatus.unknown;
    } catch (e) {
      _error = 'Failed to revoke access: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
