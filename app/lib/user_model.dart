import 'package:flutter/foundation.dart';

import 'recoil.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart' as api;

int chunkSize = 500;
var userAtom = Atom(
  'user',
  ValueNotifier({
    'userId': null,
    'lastFetch': DateTime.utc(2020, 01, 01),
    'pendingHealthDataPoints': [],
  }),
);

Selector userIdSelector = Selector('user-selector', (GetStateValue get) {
  var user = get(userAtom);
  return user.value['userId'];
});

Selector pendingDataPointsSelector =
    Selector('user-selector', (GetStateValue get) {
  var user = get(userAtom);
  return user.value['pendingHealthDataPoints'];
});

Action initAction = (get) async {
  ValueNotifier user = get(userAtom);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('id');
  if (userId == null) {
    userId = await api.register();
    await prefs.setString('id', userId);
  }
  user.value['userId'] = userId;
  String lastFetchDateString = prefs.getString('lastFetch');
  DateTime lastFetch = lastFetchDateString != null
      ? DateTime.parse(lastFetchDateString)
      : DateTime.utc(2020, 01, 01);
  user.value['lastFetch'] = lastFetch;
  user.notifyListeners();
};

Future syncHealthData(ValueNotifier user, int offset) async {
  await api.postData(user.value['userId'], offset * chunkSize,
      user.value['pendingHealthDataPoints'][0]);

  user.value['pendingHealthDataPoints'].removeAt(0);
  user.notifyListeners();

  if (user.value['pendingHealthDataPoints'].length > 0) {
    return syncHealthData(user, offset + 1);
  }
}

Action registerAction = (get) async {};

Action getStepsAction = (get) async {
  ValueNotifier user = get(userAtom);
  bool _isAuthorized = await Health.requestAuthorization();
  print('_isAuthorized $_isAuthorized');
  if (_isAuthorized) {
    DateTime startDate = user.value['lastFetch'];
    DateTime endDate = DateTime.now();
    try {
      List<HealthDataPoint> steps = await Health.getHealthDataFromType(
        startDate,
        endDate,
        HealthDataType.STEPS,
      );
      while (steps.length > 0) {
        user.value['pendingHealthDataPoints']
            .add(steps.take(chunkSize).toList());
        steps.removeRange(
            0, steps.length > chunkSize ? chunkSize : steps.length);
      }

      await syncHealthData(user, 0);
      user.value['lastFetch'] = endDate;
      user.notifyListeners();
    } catch (exception) {
      print(exception.toString());
    }
  }
};

Action setUserId = (get) async {
  var user = get(userAtom);
  user.userId = 'hej-hå';
};
