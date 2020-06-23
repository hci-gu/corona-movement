import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/garmin.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api.dart' as api;
import 'package:wfhmovement/models/steps.dart';

class User extends ValueNotifier {
  bool unlocked = false;
  bool inited = false;
  String id;
  DateTime compareDate;
  DateTime latestUploadDate;
  String dataSource;
  String division;
  String code = '';
  bool loading = false;
  DateTime lastSync;

  User() : super(null);

  setUnlocked() {
    unlocked = true;
    notifyListeners();
  }

  setCode(String value) {
    code = value;
    notifyListeners();
  }

  setUser(api.UserResponse response) {
    id = response.id;
    compareDate = response.compareDate;
    division = response.division;
    unlocked = true;
    notifyListeners();
  }

  setCompareDate(DateTime date) {
    compareDate = date;
    notifyListeners();
  }

  setLatestUpload(api.LatestUpload latestUpload) {
    latestUploadDate = latestUpload.date;
    dataSource = latestUpload.dataSource;
    notifyListeners();
  }

  setLoading(bool done) {
    loading = done;
    notifyListeners();
  }

  setLastSync() {
    lastSync = DateTime.now();
    notifyListeners();
  }

  setInited() {
    inited = true;
    notifyListeners();
  }
}

var userAtom = Atom('user', User());

var userDatesSelector = Selector('user-dates-selector', (GetStateValue get) {
  User user = get(userAtom);

  return [
    StepsModel.fromDate,
    user.compareDate.toIso8601String().substring(0, 10),
    DateTime.now().toIso8601String().substring(0, 10),
  ];
});

Action initAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('id');
  if (userId != null) {
    api.UserResponse response;
    if (userId == 'all') {
      response = fakeUser(onboarding);
    } else {
      response = await api.getUser(userId);
    }
    user.setUser(response);
    onboarding.skip();
  }
  user.setInited();
};

Action registerAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);
  onboarding.setGaveConsent();

  api.UserResponse response = await api.register(
    onboarding.date,
    onboarding.initialDataDate,
    onboarding.division,
  );
  user.setUser(response);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', user.id);
};

Action proceedWithoutStepsAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);

  user.setUser(fakeUser(onboarding));
  onboarding.skip();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', user.id);
};

api.UserResponse fakeUser(OnboardingModel onboarding) {
  return api.UserResponse.fromJson({
    '_id': 'all',
    'compareDate': onboarding.date != null
        ? onboarding.date.toIso8601String()
        : '2020-03-18',
  });
}

Action updateUserCompareDateAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  await api.updateUserCompareDate(user.id, user.compareDate);

  user.setLoading(false);
};

Future uploadChunks(String userId, List chunks) async {
  await api.postData(userId, chunks[0]);

  chunks.removeAt(0);

  if (chunks.length > 0) {
    return uploadChunks(userId, chunks);
  }
}

Action getUserLatestUploadAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  api.LatestUpload latestUpload = await api.getLatestUpload(user.id);

  user.setLatestUpload(latestUpload);

  user.setLoading(false);
};

Action syncStepsAction = (get) async {
  User user = get(userAtom);
  GarminModel garmin = get(garminAtom);
  user.setLoading(true);
  try {
    DateTime from = user.latestUploadDate;
    DateTime to = DateTime.now();

    if (user.dataSource == 'Garmin') {
      await syncGarminSteps(from, user.id, garmin.client);
    } else {
      List<HealthDataPoint> steps = await Health.getHealthDataFromType(
        from,
        to,
        HealthDataType.STEPS,
      );
      List dataChunks = [];
      while (steps.length > 0) {
        dataChunks.add(steps.take(500).toList());
        steps.removeRange(
          0,
          steps.length > 500 ? 500 : steps.length,
        );
      }
      await uploadChunks(user.id, dataChunks);
    }
    getUserLatestUploadAction(get);
    user.setLastSync();
  } catch (e) {
    user.setLoading(false);
  }
};

Action unlockAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  bool unlock = await api.unlock(user.code);

  if (unlock) {
    user.setUnlocked();
  }

  user.setLoading(false);
};
