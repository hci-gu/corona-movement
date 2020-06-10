import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:wfhmovement/api.dart' as api;
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';

class ChartModel extends ValueNotifier {
  DateTime from = DateTime.parse('2020-01-01');
  DateTime to;
  List data = [];
  bool fetching = true;

  ChartModel() : super(null);

  setData(List<api.HealthData> chartData) {
    data = chartData;
    fetching = false;
    notifyListeners();
  }
}

var stepsChartAtom = Atom('steps-chart', ChartModel());

Action getStepsChartAction = (get) async {
  ChartModel chart = get(stepsChartAtom);

  User user = get(userAtom);
  List<api.HealthData> data = await api.getSteps(
    user.id,
    chart.from,
    DateTime.now(),
  );

  chart.setData(data);
};

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
const weekdays = [1, 2, 3, 4, 5];

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

var stepsChartSelector = Selector('steps-chart-selector', (GetStateValue get) {
  ChartModel chart = get(stepsChartAtom);
  List<String> dates = get(userDatesSelector);

  var start = dates[0];
  var compareDate = dates[1];
  if (chart.data.length == 0) return [];

  return [
    filterDataIntoBuckets(
        chart.data,
        (o) => (o.date.compareTo(start) >= 1 &&
            o.date.compareTo(compareDate) < 0)),
    filterDataIntoBuckets(
        chart.data, (o) => (o.date.compareTo(compareDate) >= 0)),
  ];
});

var totalStepsForChartSelector =
    Selector('total-steps-for-chart-selector', (GetStateValue get) {
  var data = get(stepsChartSelector);
  if (data.length == 0) return [0, 0];
  var values = data
      .map((list) => list.fold(0, (sum, o) => sum + o['value'].toInt()))
      .toList();
  return values;
});

var percentDifferenceSelector =
    Selector('steps-percent-difference-selector', (GetStateValue get) {
  var values = get(totalStepsForChartSelector);

  if (values[0] == 0) return null;
  return (100 - ((values[0] / values[1]) * 100)).toStringAsFixed(1);
});
