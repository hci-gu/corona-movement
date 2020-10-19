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
  HealthFactory health;

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
    }
    notifyListeners();
  }

  setAvailableData(List steps) {
    availableData = steps;
    if (steps.length > 0) {
      initialDataDate = availableData[0].dateFrom;
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
    HealthFactory health = HealthFactory();
    bool _isAuthorized = await health.requestAuthorization(
      [HealthDataType.STEPS],
    );
    onboarding.setAuthorized(_isAuthorized, health);
  } catch (e) {
    print(e);
  }
};

// List<HealthDataPoint> mockSteps(DateTime from, DateTime to) {
//   int days = to.difference(from).inDays;
//   List<HealthDataPoint> data = [];
//   List.generate(days, (index) {
//     DateTime date = from.add(Duration(days: index));

//     List.generate(
//         24 * 15,
//         (index) => {
//               data.add(HealthDataPoint(
//                 5,
//                 'STEPS',
//                 date.millisecondsSinceEpoch,
//                 date.millisecondsSinceEpoch,
//                 '',
//                 '',
//               ))
//             });
//   }).toList();

//   return data;
// }

Future<List<HealthDataPoint>> getSteps(HealthFactory health, DateTime from,
    DateTime to, List<HealthDataPoint> totalSteps) async {
  List<HealthDataPoint> steps = await health.getHealthDataFromTypes(
    from,
    to,
    [HealthDataType.STEPS],
  );

  if (steps.length > 0) {
    totalSteps.addAll(steps);
    DateTime threeYearsAgo = DateTime.now().subtract(Duration(days: 365 * 3));
    DateTime initialDataDate = steps.first.dateFrom;
    if (from.isBefore(threeYearsAgo) ||
        initialDataDate.difference(from).inDays > 10) {
      totalSteps.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      return totalSteps;
    }

    return getSteps(
      health,
      from.subtract(Duration(days: 365)),
      from,
      totalSteps,
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
    List<HealthDataPoint> steps = await getSteps(
      onboarding.health,
      now.subtract(Duration(days: 365)),
      now,
      [],
    );
    await api.postData('test', [steps[0]], false);
    onboarding.setAvailableData(steps);
  } catch (exception) {
    print(exception.toString());
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
