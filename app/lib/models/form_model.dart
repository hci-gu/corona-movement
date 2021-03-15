import 'package:wfhmovement/config.dart';
import 'package:wfhmovement/i18n.dart';

import 'package:flutter/foundation.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/api/api.dart' as api;

class FormModel extends ValueNotifier {
  String country = 'Sweden';
  String gender;
  String ageRange;
  int age;
  String education;
  int educationYear = 1;
  String occupation;
  bool loading = false;
  bool uploaded = false;

  FormModel() : super(null);

  setCountry(value) {
    country = value;
    notifyListeners();
  }

  setField(String type, value) {
    switch (type) {
      case 'gender':
        gender = value;
        break;
      case 'ageRange':
        ageRange = value;
        break;
      case 'age':
        age = value;
        break;
      case 'education':
        education = value;
        break;
      case 'educationYear':
        educationYear = value;
        break;
      case 'occupation':
        occupation = value;
        break;
      default:
    }
    notifyListeners();
  }

  setLoading(value) {
    loading = value;
    notifyListeners();
  }

  setUploaded() {
    loading = false;
    uploaded = true;
    notifyListeners();
  }

  static List genderChoices = [
    'Female'.i18n,
    'Male'.i18n,
    'Other'.i18n,
    'Prefer not to say'.i18n
  ];
  static List ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65-74',
    '75-84',
    '85-94',
    '95-104',
    '105 or older'.i18n,
    'Prefer not to say'.i18n
  ];
  static List educations = [
    'No higher education'.i18n,
    'High school'.i18n,
    'Bachelor\'s Degree'.i18n,
    'Master\'s Degree'.i18n,
    'PhD'.i18n,
    'Trade/Vocational School'.i18n,
    'Prefer not to say'.i18n,
  ];
  static List educationYears = ['1', '2', '3'];
}

var formAtom = Atom('form', FormModel());

var formDoneSelector = Selector('form-done-selector', (GetStateValue get) {
  FormModel form = get(formAtom);

  if (EnvironmentConfig.APP_NAME == 'SFH Movement') {
    return form.country != null &&
        form.gender != null &&
        form.age != null &&
        form.age >= 16 &&
        form.education != null;
  }

  return form.country != null &&
      form.gender != null &&
      form.ageRange != null &&
      form.education != null;
});

Action setUserFormDataAction = (get) async {
  User user = get(userAtom);
  FormModel form = get(formAtom);
  form.setLoading(true);

  await api.setUserFormData(user.id, form);

  form.setUploaded();
};
