import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api/fitbit.dart' as fitbitApi;
import 'package:wfhmovement/api/api.dart' as api;
import 'package:wfhmovement/models/user_model.dart';
import 'onboarding_model.dart';

Action fitbitAuthorizationAction = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  onboarding.setFetching(true);

  try {
    final accessToken = await fitbitApi.getAccessToken();
    onboarding.setAccessToken(accessToken);
    onboarding.setAuthorized(true);
  } catch (e) {
    print(e);
    onboarding.setFetching(false);
  }
};

Action fitbitGetAvailableData = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  List<List<DatePeriod>> datePeriods = get(userPeriodsSelector);

  DateTime firstWfhDate = datePeriods.last.first.from;
  String dateBefore = firstWfhDate
      .subtract(Duration(days: 290))
      .toIso8601String()
      .substring(0, 10);
  String now = DateTime.now().toIso8601String().substring(0, 10);

  List<FitbitDay> days =
      await fitbitApi.getDays(onboarding.accessToken, dateBefore, now);

  List<FitbitDay> daysWithData = days.where((e) => e.value > 0).toList();
  onboarding.setAvailableData(daysWithData);
};

Future syncHealthData(
    User user, OnboardingModel onboarding, String userId) async {
  String date = onboarding.dataChunks[0];
  try {
    List<Map<String, dynamic>> steps =
        await fitbitApi.getSteps(onboarding.accessToken, date);
    await api.postJsonData(userId, steps, onboarding.dataChunks.length == 1);
  } on fitbitApi.RatelimitExceeded catch (e) {
    user.setRateLimitTimeStamp(e.timestamp);
    await api.processStepsOnAbort(userId);
    onboarding.dataChunks.clear();
    onboarding.setUploading(false);
    onboarding.setDone();
  } catch (e) {
    print(e);
  }

  onboarding.removeDataChunk();

  if (onboarding.dataChunks.length > 0) {
    return syncHealthData(user, onboarding, userId);
  }
}

Action fitbitGetAndUploadSteps = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);

  onboarding
      .setDataChunks(onboarding.availableData.map((e) => e.date).toList());
  onboarding.setAvailableData([]);

  await syncHealthData(user, onboarding, user.id);
  onboarding.setUploading(false);
  onboarding.setDone();
  user.setLastSync();
};

Action fitbitSyncSteps = (get) async {
  OnboardingModel onboarding = get(onboardingAtom);
  User user = get(userAtom);

  final accessToken = await fitbitApi.getAccessToken();
  onboarding.setAccessToken(accessToken);

  String from = user.latestUploadDate.toIso8601String().substring(0, 10);
  String to = DateTime.now().toIso8601String().substring(0, 10);

  List<FitbitDay> days;
  try {
    days = await fitbitApi.getDays(accessToken, from, to);
  } on fitbitApi.RatelimitExceeded catch (e) {
    user.setRateLimitTimeStamp(e.timestamp);
    user.setLoading(false);
    return;
  } catch (e) {
    user.setLoading(false);
    return;
  }
  List<FitbitDay> daysWithData = days.where((e) => e.value > 0).toList();

  onboarding.setDataChunks(daysWithData.map((e) => e.date).toList());

  await syncHealthData(user, onboarding, user.id);

  getUserLatestUploadAction(get);
  user.setLastSync();
};
