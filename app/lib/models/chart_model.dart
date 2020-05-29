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

Action getStepsData = (get) async {
  var userId = get(userIdSelector);
  var from = get(fromDateSelector);
  var to = get(toDateSelector);

  var data = await api.getSteps(userId, from, to);
};
