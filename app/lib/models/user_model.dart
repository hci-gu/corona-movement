import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfhmovement/models/form_model.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
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
  bool awaitingDataSource = false;
  bool gaveEstimate = false;
  DateTime lastSync;
  double stepsEstimate = 0.0;

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

  setAwaitingDataSource(bool done) {
    awaitingDataSource = done;
    notifyListeners();
  }

  setInited() {
    inited = true;
    notifyListeners();
  }

  setStepsEstimate(value) {
    stepsEstimate = value;
    notifyListeners();
  }

  setGaveEstimate(value) {
    gaveEstimate = value;
    notifyListeners();
  }

  reset() {
    inited = true;
    unlocked = true;
    id = null;
    compareDate = null;
    latestUploadDate = null;
    dataSource = null;
    division = null;
    code = '';
    loading = false;
    awaitingDataSource = false;
    gaveEstimate = false;
    lastSync = null;
    stepsEstimate = 0.0;

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
  FormModel form = get(formAtom);

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
    user.setGaveEstimate(true);
    form.setUploaded();
    onboarding.setDone();
  }
  user.setInited();
};

Action registerAction = (get) async {
  User user = get(userAtom);
  if (user.id != null) return;
  OnboardingModel onboarding = get(onboardingAtom);
  onboarding.setGaveConsent();

  api.UserResponse response = await api.register(
    onboarding.date,
    onboarding.initialDataDate,
    onboarding.division,
    user.code,
  );
  user.setUser(response);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', user.id);
};

Action proceedWithoutStepsAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);
  FormModel form = get(formAtom);

  user.setGaveEstimate(true);
  user.setUser(fakeUser(onboarding));
  form.setUploaded();
  onboarding.setDone();

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
  user.setLoading(true);
  try {
    DateTime from = user.latestUploadDate;
    DateTime to = DateTime.now();

    if (user.dataSource == 'Garmin') {
      if (DateTime.now().difference(from).inDays == 0) {
        return user.setLoading(false);
      }
      if (user.dataSource != null) user.setAwaitingDataSource(true);
    } else {
      List<HealthDataPoint> steps = await Health.getHealthDataFromType(
        from,
        to,
        HealthDataType.STEPS,
      );
      List dataChunks = [];
      while (steps.length > 0) {
        dataChunks.add(steps.take(750).toList());
        steps.removeRange(
          0,
          steps.length > 750 ? 750 : steps.length,
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

Action updateEstimateAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  await api.updateUserEstimate(user.id, user.stepsEstimate);

  user.setLoading(false);
};

Action shouldUnlockAction = (get) async {
  User user = get(userAtom);

  bool locked = await api.shouldUnlock();

  if (!locked) {
    user.setUnlocked();
  }
};

Action deleteUserAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);
  user.setLoading(true);

  bool deleted;
  if (user.id != 'all') {
    deleted = await api.deleteUser(user.id);
  } else {
    deleted = true;
  }

  if (deleted) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('id');
    user.reset();
    onboarding.reset();
  } else {
    user.setLoading(false);
  }
};
