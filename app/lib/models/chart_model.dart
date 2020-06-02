import 'package:flutter/foundation.dart';
import 'package:mycoronamovement/api.dart' as api;
import 'package:mycoronamovement/models/user_model.dart';
import 'package:mycoronamovement/models/recoil.dart';

var stepsChartAtom = Atom(
  'steps-chart',
  ValueNotifier({
    'from': DateTime.utc(2020, 04, 01),
    'to': DateTime.now().toUtc(),
    'data': [],
  }),
);
var chartOffsetAtom = Atom('chart-offset', ValueNotifier(0));
Selector chartOffsetSelector =
    Selector('steps-chart-offset', (GetStateValue get) {
  var offset = get(chartOffsetAtom);
  return offset;
});

Selector fromDateSelector = Selector('steps-chart-from', (GetStateValue get) {
  var chart = get(stepsChartAtom);
  return chart.value['from'];
});

Selector toDateSelector = Selector('steps-chart-to', (GetStateValue get) {
  var chart = get(stepsChartAtom);
  return chart.value['to'];
});

Selector chartDataSelector = Selector('steps-chart-data', (GetStateValue get) {
  var chart = get(stepsChartAtom);
  return chart.value['data'];
});

Action setFromDate = (get) {
  var chart = get(stepsChartAtom);

  chart.value['from'].value = '';
};

Action setToDate = (get) {
  var chart = get(stepsChartAtom);

  chart.value['to'].value = '';
};

Action getStepsChartAction = (get) async {
  ValueNotifier chart = get(stepsChartAtom);
  ValueNotifier chartOffset = get(chartOffsetSelector);

  var userId = get(userIdSelector);
  DateTime from = get(fromDateSelector);
  DateTime to = get(toDateSelector);
  print(from.add(Duration(days: chartOffset.value)));
  var data = await api.getSteps(
      userId, from.add(Duration(days: chartOffset.value)), to);

  chart.value['data'] = data;
  chart.notifyListeners();
};
