import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:wfhmovement/models/garmin.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api/api.dart' as api;
import 'package:wfhmovement/models/user_model.dart';

class OnboardingModel extends ValueNotifier {
  DateTime date;
  String division;
  String dataSource;
  List<dynamic> availableData = [];
  List<dynamic> dataChunks = [];
  DateTime initialDataDate;
  String error;
  bool fetching = false;
  bool authorized = false;
  bool gaveConsent = false;
  bool uploading = false;
  bool done = false;
  HealthFactory health;
  String loadingMessage;
  DateTime displayDateWhileLoading;

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

  setAuthorized(bool success, [HealthFactory healthFactory]) {
    authorized = success;
    if (healthFactory != null) {
      health = healthFactory;
      Future.delayed(Duration(seconds: 3)).then((_) {
        if (initialDataDate == null) {
          loadingMessage = 'This process can take a while to finish...';
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  setAvailableData(List steps, [DateTime date]) {
    availableData = steps;
    if (date != null) {
      initialDataDate = date;
    }
    fetching = false;
    loadingMessage = '';
    displayDateWhileLoading = null;
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
    if (!fetching) {
      loadingMessage = '';
      displayDateWhileLoading = null;
    } else {
      error = null;
    }
    notifyListeners();
  }

  setError(String errorMessage) {
    error = errorMessage;
    notifyListeners();
  }

  setGaveConsent() {
    gaveConsent = true;
    notifyListeners();
  }

  setDisplayDateWhileLoading(DateTime date) {
    displayDateWhileLoading = date;
    if (loadingMessage == null)
      loadingMessage = 'This process can take a while to finish...';
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
    error = null;

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
    HealthFactory health = HealthFactory();
    bool _isAuthorized = await health.requestAuthorization(
      [HealthDataType.STEPS],
    );
    onboarding.setAuthorized(_isAuthorized, health);
  } catch (e) {
    print(e);
  }
};

Future<List<HealthDataPoint>> getSteps(
    OnboardingModel onboarding,
    DateTime from,
    DateTime to,
    List<HealthDataPoint> totalSteps,
    int extraAttempts) async {
  List<HealthDataPoint> steps = await onboarding.health.getHealthDataFromTypes(
    from,
    to,
    [HealthDataType.STEPS],
  );

  if (steps.length > 0) {
    totalSteps.addAll(steps);
    DateTime oldestFetch = DateTime.now().subtract(Duration(
      days: 365 * (Platform.operatingSystem == 'android' ? 2 : 3),
    ));
    DateTime initialDataDate = steps.first.dateFrom;
    if (from.isBefore(oldestFetch)) {
      totalSteps.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      return totalSteps;
    }

    onboarding.setDisplayDateWhileLoading(initialDataDate);
    return getSteps(
      onboarding,
      from.subtract(Duration(days: 30)),
      from,
      totalSteps,
      extraAttempts,
    );
  } else if (extraAttempts > 0) {
    return getSteps(
      onboarding,
      from.subtract(Duration(days: 30)),
      to,
      totalSteps,
      extraAttempts - 1,
    );
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
    await onboarding.health.requestAuthorization([HealthDataType.STEPS]);
    await onboarding.health.requestAuthorization([HealthDataType.STEPS]);
    List<HealthDataPoint> steps = await getSteps(
        onboarding, now.subtract(Duration(days: 30)), now, [], 3);
    DateTime initialDataDate;
    if (steps.length > 0) {
      initialDataDate = steps[0].dateFrom;
    }
    onboarding.setAvailableData(steps, initialDataDate);
  } catch (exception) {
    onboarding.setError(exception.toString());
    onboarding.setFetching(false);
  }
};

Future syncHealthData(OnboardingModel onboarding, String userId) async {
  await api.postData(
      userId, onboarding.dataChunks[0], onboarding.dataChunks.length == 1);

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
