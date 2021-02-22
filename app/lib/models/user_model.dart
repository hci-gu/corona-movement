import 'package:flutter/foundation.dart';
import 'package:flutter_native_timezone/generated/i18n.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfhmovement/global-analytics.dart';
import 'package:wfhmovement/models/form_model.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api/api.dart' as api;
import 'package:wfhmovement/api/responses.dart';

import 'app_model.dart';

class User extends ValueNotifier {
  bool inited = false;
  String id;
  String languageOverride;
  DateTime latestUploadDate;
  DateTime initialDataDate = DateTime.parse('2020-01-01');
  List<DatePeriod> beforePeriods;
  List<DatePeriod> afterPeriods;
  String dataSource;
  String groupCode = '';
  Group group;
  String code = '';
  bool loading = false;
  bool awaitingDataSource = false;
  bool gaveEstimate = false;
  bool deeplinkOpen = false;
  DateTime lastSync;
  double stepsEstimate = 0.0;
  bool workedFromHome;

  User() : super(null);

  setCode(String value) {
    code = value;
    notifyListeners();
  }

  setUser(UserResponse response) {
    id = response.id;
    if (response.initialDataDate != null &&
        response.initialDataDate.isAfter(DateTime.parse('2020-01-01'))) {
      initialDataDate = response.initialDataDate.add(Duration(days: 1));
    }
    beforePeriods = response.beforePeriods;
    afterPeriods = response.afterPeriods;
    notifyListeners();
  }

  setAfterPeriods(List<DatePeriod> periods) {
    afterPeriods = periods;
    workedFromHome = true;
    notifyListeners();
  }

  setDidNotWorkFromHome() {
    workedFromHome = false;
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
    notifyListeners();
  }

  setDeeplinkOpen(bool value) {
    deeplinkOpen = value;
    notifyListeners();
  }

  reset() {
    inited = true;
    id = null;
    latestUploadDate = null;
    dataSource = null;
    group = null;
    groupCode = '';
    code = '';
    loading = false;
    awaitingDataSource = false;
    gaveEstimate = false;
    deeplinkOpen = false;
    lastSync = null;
    beforePeriods = null;
    afterPeriods = null;
    workedFromHome = null;
    stepsEstimate = 0.0;

    notifyListeners();
  }
}

int chunkSize = 750;
var userAtom = Atom('user', User());

var userPeriodsSelector =
    Selector('user-periods-selector', (GetStateValue get) {
  User user = get(userAtom);

  return [user.beforePeriods, user.afterPeriods];
});

Action initAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);
  FormModel form = get(formAtom);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageOverride = prefs.getString('language');
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
  user.languageOverride = languageOverride;
  globalAnalytics.init(userId);
  user.setInited();
};

Action registerAction = (get) async {
  User user = get(userAtom);
  if (user.id != null) return;
  OnboardingModel onboarding = get(onboardingAtom);
  onboarding.setGaveConsent();

  UserResponse response = await api.register(
    user.afterPeriods,
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
    'beforePeriods': [
      DatePeriod(
        DateTime.parse('2020-01-01'),
        DateTime.parse('2020-03-11'),
      )
    ],
    'afterPeriods': [
      DatePeriod(
        DateTime.parse('2020-03-11'),
        null,
      )
    ],
  });
}

Action updateUserAfterPeriodsAction = (get) async {
  User user = get(userAtom);
  user.setLoading(true);

  await api.updateUserAfterPeriods(user.id, user.afterPeriods);

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

Action joinGroupAction = (get) async {
  User user = get(userAtom);
  AppModel appModel = get(appModelAtom);
  user.setLoading(true);

  try {
    Group group = await api.getAndjoinGroup(user.groupCode, user.id);
    if (group != null) {
      user.setGroup(group);
    }
  } catch (e) {
    appModel.setSnackMessage('Could not find a group for this code.');
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

Action setUserLanguageOverrideAction = (get) async {
  User user = get(userAtom);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', user.languageOverride);
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
