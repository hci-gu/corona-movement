import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/api/api.dart' as api;
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';

class StepsModel extends ValueNotifier {
  DateTime from = DateTime.parse(StepsModel.fromDate);
  DateTime to;
  List<HealthData> data = [];
  HealthComparison comparison;
  bool fetching = true;
  bool refresh = true;
  List<int> days = [1, 2, 3, 4, 5, 6, 7];

  StepsModel() : super(null);

  setFetching() {
    fetching = true;
    notifyListeners();
  }

  setData(List<HealthData> steps) {
    data = steps;
    fetching = false;
    notifyListeners();
  }

  setComparison(HealthComparison newComparison) {
    comparison = newComparison;
    notifyListeners();
  }

  updateDays(int day, bool add) {
    if (add)
      days.add(day);
    else
      days.remove(day);
    days.sort();
    notifyListeners();
  }

  static String fromDate = '2020-01-01';
  static List<Map<String, dynamic>> weekdays = [
    {'display': 'Monday', 'value': 1},
    {'display': 'Tuesday', 'value': 2},
    {'display': 'Wednesday', 'value': 3},
    {'display': 'Thursday', 'value': 4},
    {'display': 'Friday', 'value': 5},
    {'display': 'Saturday', 'value': 6},
    {'display': 'Sunday', 'value': 7}
  ];
}

var stepsAtom = Atom('steps', StepsModel());

List groupByHour(List<HealthData> list) {
  Map<String, dynamic> obj = list.fold({}, (obj, x) {
    var key = x.hours.toString();
    if (obj[key] == null) {
      obj[key] = [];
    }
    obj[key].add(x);
    return obj;
  });
  return obj.keys.map((key) {
    return {
      'key': key,
      'values': obj[key],
    };
  }).toList();
}

List putDataInBuckets(List<Map<String, dynamic>> data) {
  return List.generate(24, (index) {
    var match = data.firstWhere((o) => o['key'] == index.toString(),
        orElse: () => null);
    return {
      'key': index,
      'value': match != null ? match['value'] : 0.0,
    };
  });
}

typedef Filter = bool Function(dynamic o);
List filterDataIntoBuckets(List data, Filter filter, List<int> weekdays) {
  List dataInFilter = data
      .where(filter)
      .toList()
      .where((o) => weekdays.contains(o.weekday))
      .toList();
  var numDates = dataInFilter.map((o) => o.date).toSet().length;
  List _group = groupByHour(dataInFilter);
  return putDataInBuckets(_group.map((o) {
    return {
      'key': o['key'],
      'value': o['values'].fold(0, (sum, x) => sum + x.value) / numDates
    };
  }).toList());
}

var stepsBeforeAndAfterSelector =
    Selector('steps-before-and-after-selector', (GetStateValue get) {
  StepsModel steps = get(stepsAtom);
  List<String> dates = get(userDatesSelector);

  var start = dates[0];
  var compareDate = dates[1];
  if (steps.data.length == 0) return [];

  return [
    filterDataIntoBuckets(
      steps.data,
      (o) =>
          (o.date.compareTo(start) >= 0 && o.date.compareTo(compareDate) < 0),
      steps.days,
    ),
    filterDataIntoBuckets(
      steps.data,
      (o) => (o.date.compareTo(compareDate) >= 0),
      steps.days,
    ),
  ];
});

int getDaysBetween(String from, String to, List<int> daysToInclude) {
  var days = 0;
  List dayDiff = List.generate(
      DateTime.parse(to).difference(DateTime.parse(from)).inDays,
      (index) => index);
  dayDiff.forEach((value) {
    var date = DateTime.parse(from).add(Duration(days: value));
    if (daysToInclude.contains(date.weekday)) {
      days++;
    }
  });

  return days;
}

var totalStepsBeforeAndAfterSelector =
    Selector('total-steps-before-and-after-selector', (GetStateValue get) {
  StepsModel steps = get(stepsAtom);
  HealthComparison comparison = get(stepsComparisonSelector);
  List<String> dates = get(userDatesSelector);

  if (steps.days.length == 7) {
    if (comparison == null) {
      return [0, 0];
    }
    return [comparison.user.before.toInt(), comparison.user.after.toInt()];
  }

  var start = dates[0];
  var compareDate = dates[1];
  var beforeDays = getDaysBetween(start, compareDate, steps.days) + 1;
  var afterDays = getDaysBetween(compareDate,
      DateTime.now().toIso8601String().substring(0, 10), steps.days);
  var before = steps.data
      .where((o) =>
          (o.date.compareTo(start) >= 0 && o.date.compareTo(compareDate) < 0))
      .where((o) => steps.days.contains(o.weekday))
      .fold(0, (sum, o) => sum + o.value)
      .toInt();
  var after = steps.data
      .where((o) => (o.date.compareTo(compareDate) >= 0))
      .where((o) => steps.days.contains(o.weekday))
      .fold(0, (sum, o) => sum + o.value)
      .toInt();

  return [(before / beforeDays).toInt(), (after / afterDays).toInt()];
});

var stepsDiffBeforeAndAfterSelector =
    Selector('steps-percent-difference-selector', (GetStateValue get) {
  var values = get(totalStepsBeforeAndAfterSelector);

  if (values[0] == 0) return null;
  return (100 * (values[1] - values[0]) / values[0]).toStringAsFixed(1);
});

var stepsDayBreakdownSelector =
    Selector('steps-day-breakdown-selector', (GetStateValue get) {
  StepsModel steps = get(stepsAtom);
  Map days = steps.data.fold({}, (dates, o) {
    if (dates[o.date] != null) {
      dates[o.date][o.hours] = {
        'hours': o.hours,
        'value': o.value,
        'date': o.date,
        'weekday': o.weekday,
      };
    } else {
      dates[o.date] = List.generate(24, (index) {
        return {
          'hours': index,
          'value': 0,
          'date': o.date,
          'weekday': o.weekday,
        };
      }).toList();
    }
    return dates;
  });
  return days;
});

var stepsDayTotalSelector =
    Selector('steps-day-total-selector', (GetStateValue get) {
  Map days = get(stepsDayBreakdownSelector);

  return days.keys.map((key) {
    return {
      'date': key,
      'value': days[key].fold(0.0, (sum, day) => sum + day['value'])
    };
  }).toList();
});

var stepsComparisonSelector = Selector('steps-comparison', (GetStateValue get) {
  StepsModel steps = get(stepsAtom);

  return steps.comparison;
});

Action getStepsComparisonAction = (get) async {
  StepsModel steps = get(stepsAtom);
  User user = get(userAtom);

  if (user.id != 'all') {
    HealthComparison data = await api.getComparison(user.id);
    steps.setComparison(data);
  }
};

Action getStepsAction = (get) async {
  StepsModel steps = get(stepsAtom);
  User user = get(userAtom);
  steps.setFetching();
  List<HealthData> data = await api.getSteps(
    user.id,
    steps.from,
    DateTime.now(),
  );
  steps.setData(data);
};

var stepsTodaySelector = Selector('steps-today', (GetStateValue get) {
  StepsModel steps = get(stepsAtom);
  var todaysDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return steps.data
      .where((o) => o.date.compareTo(todaysDate) == 0)
      .fold(0, (sum, o) => sum + o.value)
      .toInt();
});

var typicalStepsSelector = Selector('typical-steps', (GetStateValue get) {
  StepsModel steps = get(stepsAtom);
  var todaysDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var hour = DateTime.now().hour;
  var day = DateFormat('EEEE').format(DateTime.now());
  var similarDaySteps = steps.data.where((o) =>
      // not today
      // weekday this weekday
      // hour <= this hour
      o.date.compareTo(todaysDate) != 0 &&
      DateFormat('EEEE').format(DateTime.parse(o.date)).compareTo(day) == 0 &&
      o.hours <= hour);
  var uniqueDays = similarDaySteps.map((o) => o.date).toSet().length;
  if (uniqueDays == 0) return 0;
  return (similarDaySteps.fold(0.0, (sum, o) => sum + o.value).toInt() /
          uniqueDays)
      .toInt();
});
