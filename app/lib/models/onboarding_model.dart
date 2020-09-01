import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:wfhmovement/models/garmin.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api.dart' as api;
import 'package:wfhmovement/models/user_model.dart';

class OnboardingModel extends ValueNotifier {
  DateTime date;
  String division;
  String dataSource;
  List<dynamic> availableData = [];
  List<dynamic> dataChunks = [];
  DateTime initialDataDate;
  bool fetching = false;
  bool authorized = false;
  bool gaveConsent = false;
  bool uploading = false;
  bool done = false;

  OnboardingModel() : super(null);

  setDate(DateTime selectedDate) {
    date = selectedDate;
    notifyListeners();
  }

  setDataSource(String selectedDataSource) {
    if (dataSource != selectedDataSource) {
      dataSource = selectedDataSource;
      authorized = false;
      availableData = [];
    }
    notifyListeners();
  }

  setAuthorized(bool success) {
    authorized = success;
    notifyListeners();
  }

  setAvailableData(List steps) {
    availableData = steps;
    if (steps.length > 0) {
      initialDataDate =
          DateTime.fromMillisecondsSinceEpoch(availableData[0].dateFrom);
    }
    fetching = false;
    notifyListeners();
  }

  setDataChunks(List updatedDataChunks) {
    dataChunks = updatedDataChunks;
    notifyListeners();
  }

  removeDataChunk() {
    dataChunks.removeAt(0);
    notifyListeners();
  }

  setFetching(bool done) {
    fetching = done;
    notifyListeners();
  }

  setGaveConsent() {
    gaveConsent = true;
    notifyListeners();
  }

  setDone() {
    done = true;
  }

  setUploading(bool value) {
    uploading = value;
    notifyListeners();
  }

  reset() {
    date = null;
    division = null;
    dataSource = null;
    availableData = [];
    dataChunks = [];
    initialDataDate = null;
    fetching = false;
    authorized = false;
    gaveConsent = false;
    uploading = false;
    done = false;

    notifyListeners();
  }

  static List dataSources = ['Google fitness', 'Apple health', 'Garmin'];
}

int chunkSize = 750;
var onboardingAtom = Atom('onboarding', OnboardingModel());

Action getHealthAuthorizationAction = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  if (onboarding.dataSource == 'Garmin') {
    return garminAuthorizationAction(get);
  }
  try {
    onboarding.setAuthorized(false);
    bool _isAuthorized = await Health.requestAuthorization();
    onboarding.setAuthorized(_isAuthorized);
  } catch (e) {
    print(e);
  }
};

Future<List<HealthDataPoint>> getSteps(
    DateTime from, DateTime to, List<HealthDataPoint> totalSteps) async {
  List<HealthDataPoint> steps = await Health.getHealthDataFromType(
    from,
    to,
    HealthDataType.STEPS,
  );
  if (steps.length > 0) {
    totalSteps.addAll(steps);
    DateTime threeYearsAgo = DateTime.now().subtract(Duration(days: 365 * 3));
    if (from.isBefore(threeYearsAgo)) {
      totalSteps.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      return totalSteps;
    }

    return getSteps(from.subtract(Duration(days: 30)), from, totalSteps);
  }
  totalSteps.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
  return totalSteps;
}

Action getAvailableStepsAction = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  DateTime now = DateTime.now();
  onboarding.setFetching(true);
  if (onboarding.dataSource == 'Garmin') {
    return garminGetAvailableData(get);
  }
  try {
    List<HealthDataPoint> steps = await getSteps(
      now.subtract(Duration(days: 30)),
      now,
      [],
    );
    onboarding.setAvailableData(steps);
  } catch (exception) {
    print(exception.toString());
  }
};

Future syncHealthData(OnboardingModel onboarding, String userId) async {
  await api.postData(userId, onboarding.dataChunks[0]);

  onboarding.removeDataChunk();

  if (onboarding.dataChunks.length > 0) {
    return syncHealthData(onboarding, userId);
  }
}

Action uploadStepsAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);
  onboarding.setUploading(true);

  if (onboarding.dataSource == 'Garmin') {
    return garminGetAndUploadSteps(get);
  }

  try {
    List<dynamic> stepsChunks = [];
    while (onboarding.availableData.length > 0) {
      stepsChunks.add(onboarding.availableData.take(chunkSize).toList());
      onboarding.availableData.removeRange(
        0,
        onboarding.availableData.length > chunkSize
            ? chunkSize
            : onboarding.availableData.length,
      );
    }
    onboarding.setDataChunks(stepsChunks);
    await syncHealthData(onboarding, user.id);
    onboarding.setUploading(false);
    onboarding.setDone();
    user.setLastSync();
  } catch (exception) {
    print(exception.toString());
  }
};
