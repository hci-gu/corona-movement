import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api.dart' as api;
import 'package:wfhmovement/models/steps.dart';

class User extends ValueNotifier {
  bool inited = false;
  String id;
  DateTime compareDate;
  String division;

  User() : super(null);

  setUser(api.UserResponse response) {
    id = response.id;
    compareDate = response.compareDate;
    division = response.division;
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
