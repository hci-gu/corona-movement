import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart' as api;

class UserModel with ChangeNotifier {
  int chunkSize = 500;
  String userId;
  DateTime lastFetch;
  List<List<HealthDataPoint>> pendingHealthDataPoints;

  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userId = prefs.getString('id');
    if (userId == null) {
      userId = await api.register();
      await prefs.setString('id', userId);
    }
    String lastFetchDateString = prefs.getString('lastFetch');
    lastFetch = lastFetchDateString != null
        ? DateTime.parse(lastFetchDateString)
        : DateTime.utc(2018, 01, 01);
  }

  Future syncHealthData(int offset) async {
    await api.postData(userId, offset * chunkSize, pendingHealthDataPoints[0]);

    pendingHealthDataPoints.removeAt(0);
    notifyListeners();

    if (pendingHealthDataPoints.length > 0) {
      return syncHealthData(offset + 1);
    }
  }

  void getSteps() async {
    bool _isAuthorized = await Health.requestAuthorization();
    print('_isAuthorized $_isAuthorized');
    if (_isAuthorized) {
      DateTime startDate = lastFetch;
      DateTime endDate = DateTime.now();
      try {
        List<HealthDataPoint> steps = await Health.getHealthDataFromType(
          startDate,
          endDate,
          HealthDataType.STEPS,
        );
        pendingHealthDataPoints = [];
        while (steps.length > 0) {
          pendingHealthDataPoints.add(steps.take(chunkSize).toList());
          steps.removeRange(
              0, steps.length > chunkSize ? chunkSize : steps.length);
        }

        syncHealthData(0).then((_) {
          lastFetch = endDate;
        });
      } catch (exception) {
        print(exception.toString());
      }
    }
  }

  static Future ping() async {
    await api.ping();
  }
}
