import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:wfhmovement/api.dart' as api;
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/garmin_client.dart';
import 'package:wfhmovement/models/steps.dart';
import 'package:wfhmovement/models/user_model.dart';

class GarminModel extends ValueNotifier {
  DateTime fetchFrom;
  GarminClient client;
  String username = '';
  String password = '';

  List<dynamic> availableData = [];
  List<dynamic> dataChunks = [];

  GarminModel() : super(null);

  setUsername(String value) {
    username = value;
    notifyListeners();
  }

  setPassword(String value) {
    password = value;
    notifyListeners();
  }
}

int chunkSize = 500;
var garminAtom = Atom('garmin', GarminModel());

Action garminAuthorizationAction = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  GarminModel model = get(garminAtom);
  onboarding.setFetching(true);

  try {
    model.client = GarminClient(
      model.username,
      model.password,
    );
    await model.client.connect();
    onboarding.setAuthorized(true);
  } catch (e) {
    print(e);
    onboarding.setFetching(false);
  }
};

Action garminGetAvailableData = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  GarminModel model = get(garminAtom);
  List<HealthDataPoint> steps =
      await model.client.fetchSteps(StepsModel.fromDate);

  onboarding.setAvailableData(steps);
};

Future syncHealthData(GarminClient garminClient, OnboardingModel onboarding,
    String userId) async {
  String date = onboarding.dataChunks[0];
  List<HealthDataPoint> steps = await garminClient.fetchSteps(date);
  await api.postData(userId, steps);

  onboarding.removeDataChunk();

  if (onboarding.dataChunks.length > 0) {
    return syncHealthData(garminClient, onboarding, userId);
  }
}

Action garminGetAndUploadSteps = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);
  GarminModel model = get(garminAtom);

  int days =
      DateTime.now().difference(DateTime.parse(StepsModel.fromDate)).inDays;

  List dates = List.generate(days, (index) {
    DateTime date = DateTime.now().subtract(Duration(days: index));
    return date.toString().substring(0, 10);
  });

  onboarding.setDataChunks(dates);
  onboarding.setAvailableData([]);

  await syncHealthData(model.client, onboarding, user.id);
};
