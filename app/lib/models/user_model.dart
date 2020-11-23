import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/form_model.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api/api.dart' as api;
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/steps.dart';

class User extends ValueNotifier {
  bool unlocked = false;
  bool inited = false;
  String id;
  DateTime compareDate;
  DateTime latestUploadDate;
  DateTime initialDataDate = DateTime.parse('2020-01-01');
  String dataSource;
  String groupCode = '';
  Group group;
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

  setUser(UserResponse response) {
    id = response.id;
    compareDate = response.compareDate;
    if (response.initialDataDate != null &&
        response.initialDataDate.isAfter(DateTime.parse('2020-01-01'))) {
      initialDataDate = response.initialDataDate.add(Duration(days: 1));
    }
    unlocked = true;
    notifyListeners();
  }

  setCompareDate(DateTime date) {
    compareDate = date;
    notifyListeners();
  }

  setLatestUpload(LatestUpload latestUpload) {
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

  setGroupCode(value) {
    groupCode = value;
    notifyListeners();
  }

  setGroup(Group _group) {
    group = _group;
  }

  reset() {
    inited = true;
    unlocked = true;
    id = null;
    compareDate = null;
    latestUploadDate = null;
    dataSource = null;
    group = null;
    groupCode = '';
    code = '';
    loading = false;
    awaitingDataSource = false;
    gaveEstimate = false;
    lastSync = null;
    stepsEstimate = 0.0;

    notifyListeners();
  }
}

int chunkSize = 750;
var userAtom = Atom('user', User());

var userDatesSelector = Selector('user-dates-selector', (GetStateValue get) {
  User user = get(userAtom);

  return [
    user.initialDataDate.toIso8601String().substring(0, 10),
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
    UserResponse response;
    if (userId == 'all') {
      response = fakeUser(onboarding);
    } else {
      response = await api.getUser(userId);
    }
    if (response == null) {
      userId = null;
    } else {
      user.setUser(response);
      if (response.stepsEstimate != null || userId == 'all') {
        user.setGaveEstimate(true);
        form.setUploaded();
      }
      if (response.groupId != null) {
        Group group = await api.getGroup(response.groupId);
        user.setGroup(group);
      }
      onboarding.setDone();
    }
  }
  globalAnalytics.init(userId);
  user.setInited();
};

Action registerAction = (get) async {
  User user = get(userAtom);
  if (user.id != null) return;
  OnboardingModel onboarding = get(onboardingAtom);
  onboarding.setGaveConsent();

  UserResponse response = await api.register(
    onboarding.date,
    onboarding.initialDataDate,
    onboarding.dataSource,
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

UserResponse fakeUser(OnboardingModel onboarding) {
  return UserResponse.fromJson({
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
  await api.postData(userId, chunks[0], chunks.length == 1);

  chunks.removeAt(0);

  if (chunks.length > 0) {
    return uploadChunks(userId, chunks);
  }
}

Action getUserLatestUploadAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  LatestUpload latestUpload = await api.getLatestUpload(user.id);

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
      HealthFactory health = HealthFactory();
      List<HealthDataPoint> steps = await health.getHealthDataFromTypes(
        from,
        to,
        [HealthDataType.STEPS],
      );
      List dataChunks = [];
      if (steps.length == 0) {
        await Future.delayed(Duration(seconds: 1));
      } else {
        while (steps.length > 0) {
          dataChunks.add(steps.take(chunkSize).toList());
          steps.removeRange(
            0,
            steps.length > chunkSize ? chunkSize : steps.length,
          );
        }
        await uploadChunks(user.id, dataChunks);
      }
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

Action joinGroupAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  Group group = await api.getAndjoinGroup(user.groupCode, user.id);

  if (group != null) {
    user.setGroup(group);
  }

  user.setLoading(false);
};

Action leaveGroupAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  bool success = await api.leaveGroup(user.group.id, user.id);

  if (success) {
    user.setGroup(null);
    user.setGroupCode('');
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
  user.setLoading(true);

  bool locked = await api.shouldUnlock();

  if (!locked) {
    user.setUnlocked();
  }
  user.setLoading(false);
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
