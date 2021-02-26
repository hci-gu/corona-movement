import 'package:wfhmovement/i18n.dart';

import 'package:flutter/foundation.dart';
import 'package:wfhmovement/models/recoil.dart';

class DayFilterModel extends ValueNotifier {
  List<int> days = [1, 2, 3, 4, 5, 6, 7];

  DayFilterModel() : super(null);

  updateDays(int day, bool add) {
    if (add)
      days.add(day);
    else
      days.remove(day);
    days.sort();
    notifyListeners();
  }

  static List<Map<String, dynamic>> weekdays = [
    {'display': 'Monday'.i18n, 'value': 1},
    {'display': 'Tuesday'.i18n, 'value': 2},
    {'display': 'Wednesday'.i18n, 'value': 3},
    {'display': 'Thursday'.i18n, 'value': 4},
    {'display': 'Friday'.i18n, 'value': 5},
    {'display': 'Saturday'.i18n, 'value': 6},
    {'display': 'Sunday'.i18n, 'value': 7}
  ];
}

var dayFilterAtom = Atom('day-filter', DayFilterModel());
