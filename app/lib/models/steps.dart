import 'package:flutter/foundation.dart';
import 'package:wfhmovement/api.dart' as api;
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';

class StepsModel extends ValueNotifier {
  DateTime from = DateTime.parse('2020-01-01');
  DateTime to;
  List<api.HealthData> data = [];
  api.HealthComparison comparison;
  bool fetching = true;

  StepsModel() : super(null);

  setData(List<api.HealthData> steps) {
    data = steps;
    fetching = false;
    notifyListeners();
  }

  setComparison(api.HealthComparison newComparison) {
    comparison = newComparison;
    notifyListeners();
  }
}

var stepsAtom = Atom('steps', StepsModel());

List groupByHour(List<api.HealthData> list) {
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
const weekdays = [0, 1, 2, 3, 4, 5, 6];
List filterDataIntoBuckets(List data, Filter filter) {
  List _group = groupByHour(
    data
        .where(filter)
        .toList()
        .where((o) => weekdays.contains(o.weekday))
        .toList(),
  );
  return putDataInBuckets(_group.map((o) {
    return {
      'key': o['key'],
      'value':
          o['values'].fold(0, (sum, x) => sum + x.value) / o['values'].length
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
          (o.date.compareTo(start) >= 1 && o.date.compareTo(compareDate) < 0),
    ),
    filterDataIntoBuckets(
      steps.data,
      (o) => (o.date.compareTo(compareDate) >= 0),
    ),
  ];
});

var totalStepsBeforeAndAfterSelector =
    Selector('total-steps-before-and-after-selector', (GetStateValue get) {
  var data = get(stepsBeforeAndAfterSelector);
  if (data.length == 0) return [0, 0];
  var values = data
      .map((list) => list.fold(0, (sum, o) => sum + o['value'].toInt()))
      .toList();
  return values;
});

var stepsDiffBeforeAndAfterSelector =
    Selector('steps-percent-difference-selector', (GetStateValue get) {
  var values = get(totalStepsBeforeAndAfterSelector);

  if (values[0] == 0) return null;
  return (100 - ((values[0] / values[1]) * 100)).toStringAsFixed(1);
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

  if (steps.comparison == null) {
    api.HealthComparison data = await api.getComparison(user.id);
    steps.setComparison(data);
  }
};

Action getStepsAction = (get) async {
  StepsModel steps = get(stepsAtom);
  User user = get(userAtom);

  if (steps.data.length == 0) {
    List<api.HealthData> data = await api.getSteps(
      user.id,
      steps.from,
      DateTime.now(),
    );
    steps.setData(data);
  }
};
