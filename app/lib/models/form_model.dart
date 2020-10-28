import 'package:flutter/foundation.dart';
import 'package:wfhmovement/models/recoil.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/api.dart' as api;

class FormModel extends ValueNotifier {
  String country = 'Sweden';
  String gender;
  String ageRange;
  String education;
  String occupation;
  bool loading = false;
  bool uploaded = false;

  FormModel() : super(null);

  setCountry(value) {
    country = value;
    notifyListeners();
  }

  setField(String type, String value) {
    switch (type) {
      case 'gender':
        gender = value;
        break;
      case 'ageRange':
        ageRange = value;
        break;
      case 'education':
        education = value;
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

  static List genderChoices = ['Female', 'Male', 'Other', 'Prefer not to say'];
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
    '105 or older',
    'prefer not to say'
  ];
  static List educations = [
    'No higher education',
    'High school',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Trade/Vocational School',
    'Prefer not to say',
  ];
}

var formAtom = Atom('form', FormModel());

var formDoneSelector = Selector('form-done-selector', (GetStateValue get) {
  FormModel form = get(formAtom);

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
