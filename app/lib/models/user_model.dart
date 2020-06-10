import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wfhmovement/models/onboarding_model.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/api.dart' as api;

class User extends ValueNotifier {
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
}

var userAtom = Atom('user', User());

var userDatesSelector = Selector('user-dates-selector', (GetStateValue get) {
  User user = get(userAtom);

  return [
    user.compareDate
        .subtract(Duration(days: 90))
        .toIso8601String()
        .substring(0, 10),
    user.compareDate.toIso8601String().substring(0, 10),
    DateTime.now().toIso8601String().substring(0, 10),
  ];
});

Action initAction = (get) async {
  User user = get(userAtom);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('id');
  if (userId != null) {
    api.UserResponse response = await api.getUser(userId);
    user.setUser(response);
  } else {
    prefs.setString('id', '5edf81e1c8c51ed728f5e56a');
  }
};

Action registerAction = (get) async {
  User user = get(userAtom);
  OnboardingModel onboarding = get(onboardingAtom);

  api.UserResponse response = await api.register(
    onboarding.date,
    onboarding.division,
  );
  user.setUser(response);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', user.id);
};
