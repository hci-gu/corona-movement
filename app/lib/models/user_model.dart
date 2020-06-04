import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mycoronamovement/models/recoil.dart';
import 'package:mycoronamovement/api.dart' as api;

int chunkSize = 500;
var userAtom = Atom(
  'user',
  ValueNotifier({
    'inited': false,
    'authorizationFailed': false,
    'userId': null,
    'lastFetch': null,
    'availableData': [],
    'pendingHealthDataPoints': [],
  }),
);
var dataDateAtom =
    Atom('data-date', ValueNotifier(DateTime.parse('2020-01-01')));
Selector dataDateSelector = Selector('data-date-selector', (GetStateValue get) {
  var date = get(dataDateAtom);
  return date;
});

Selector userIdSelector =
    Selector('user-selector-user-id', (GetStateValue get) {
  var user = get(userAtom);
  return user.value['userId'];
});

Selector pendingDataPointsSelector =
    Selector('user-selector-pending-data', (GetStateValue get) {
  var user = get(userAtom);
  return user.value['pendingHealthDataPoints'];
});

Selector availableDataSelector =
    Selector('user-selector-available-data', (GetStateValue get) {
  var user = get(userAtom);
  return user.value['availableData'];
});

Selector lastFetchSelector =
    Selector('user-selector-last-fetch', (GetStateValue get) {
  var user = get(userAtom);
  return user.value['lastFetch'];
});

Selector userStateSelector =
    Selector('user-selector-state', (GetStateValue get) {
  var user = get(userAtom);
  var userId = get(userIdSelector);
  var lastFetch = get(lastFetchSelector);

  if (user.value['inited'] == false) {
    return '';
  }
  if (userId == null) {
    return 'home';
  }
  if (lastFetch == null) {
    return 'pick-data-range';
  }
  if (DateTime.now().difference(lastFetch).inDays < 10) {
    return 'charts';
  }
  return 'sync-data';
});

Action initAction = (get) async {
  ValueNotifier user = get(userAtom);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('id');
  if (userId != null) {
    user.value['userId'] = userId;
  }
  String lastFetchDateString = prefs.getString('lastFetch');
  if (lastFetchDateString != null) {
    user.value['lastFetch'] = DateTime.parse(lastFetchDateString);
  }
  user.value['inited'] = true;
  user.notifyListeners();
};

Action getHealthAuthorization = (get) async {
  ValueNotifier user = get(userAtom);
  try {
    bool _isAuthorized = await Health.requestAuthorization();
    if (_isAuthorized) {
      String userId = await api.register();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', userId);
      user.value['userId'] = userId;
    } else {
      user.value['authorizationFailed'] = true;
    }
    user.notifyListeners();
  } catch (e) {
    print(e);
  }
};

Future syncHealthData(ValueNotifier user) async {
  await api.postData(
      user.value['userId'], user.value['pendingHealthDataPoints'][0]);

  user.value['pendingHealthDataPoints'].removeAt(0);
  user.notifyListeners();

  if (user.value['pendingHealthDataPoints'].length > 0) {
    return syncHealthData(user);
  }
}

Action getStepsAction = (get) async {
  ValueNotifier user = get(userAtom);
  DateTime startDate = user.value['lastFetch'];
  DateTime endDate = DateTime.now();
  try {
    List<HealthDataPoint> steps = await Health.getHealthDataFromType(
      startDate,
      endDate,
      HealthDataType.STEPS,
    );
    while (steps.length > 0) {
      user.value['pendingHealthDataPoints'].add(steps.take(chunkSize).toList());
      steps.removeRange(0, steps.length > chunkSize ? chunkSize : steps.length);
    }

    await syncHealthData(user);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFetch', endDate.toIso8601String());
    user.value['lastFetch'] = endDate;
    user.notifyListeners();
  } catch (exception) {
    print(exception.toString());
  }
};

Action getAvailableStepsForDateAction = (get) async {
  ValueNotifier user = get(userAtom);
  ValueNotifier date = get(dataDateSelector);
  DateTime startDate = date.value;
  DateTime endDate = DateTime.now();
  try {
    List<HealthDataPoint> steps = await Health.getHealthDataFromType(
      startDate,
      endDate,
      HealthDataType.STEPS,
    );
    user.value['availableData'] = steps;
    user.notifyListeners();
  } catch (exception) {
    print(exception.toString());
  }
};

Action setLastFetchAction = (get) async {
  ValueNotifier user = get(userAtom);
  ValueNotifier date = get(dataDateSelector);

  user.value['lastFetch'] = date.value;
  user.notifyListeners();
};
