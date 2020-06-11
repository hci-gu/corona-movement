import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
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

  OnboardingModel() : super(null);

  setDate(DateTime selectedDate) {
    date = selectedDate;
    notifyListeners();
  }

  setDataSource(String selectedDataSource) {
    dataSource = selectedDataSource;
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

  setFetching() {
    fetching = true;
    notifyListeners();
  }

  setGaveConsent() {
    gaveConsent = true;
    notifyListeners();
  }

  static List dataSources = ['Google fitness', 'Apple health', 'Garmin'];
}

int chunkSize = 500;
var onboardingAtom = Atom('onboarding', OnboardingModel());

Action getHealthAuthorizationAction = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  try {
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
    return getSteps(from.subtract(Duration(days: 30)), from, totalSteps);
  }
  totalSteps.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
  return totalSteps;
}

Action getAvailableStepsAction = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  DateTime now = DateTime.now();
  onboarding.setFetching();
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
  } catch (exception) {
    print(exception.toString());
  }
};
