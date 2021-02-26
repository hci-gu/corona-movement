import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:wfhmovement/api/api.dart' as api;
import 'package:wfhmovement/api/responses.dart';
import 'package:wfhmovement/models/steps/daysFilter.dart';
import 'package:wfhmovement/models/steps/utils.dart';
import 'package:wfhmovement/models/user_model.dart';
import 'package:wfhmovement/models/recoil.dart';

class StepsModel extends ValueNotifier {
  DateTime from = DateTime.parse(StepsModel.fromDate);
  DateTime to;
  List<HealthData> data = [];
  AllUserData aggregatedData = AllUserData.empty();
  HealthComparison comparison;
  bool fetching = true;
  bool refresh = true;

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

  setAggregatedData(AllUserData data) {
    aggregatedData = data;
    fetching = false;
    notifyListeners();
  }

  setComparison(HealthComparison newComparison) {
    comparison = newComparison;
    notifyListeners();
  }

  static String fromDate = '2020-01-01';
}

var stepsAtom = Atom('steps', StepsModel());

var stepsBeforeAndAfterSelector =
    Selector('steps-before-and-after-selector', (GetStateValue get) {
  StepsModel steps = get(stepsAtom);
  DayFilterModel dayFilter = get(dayFilterAtom);
  List<List<DatePeriod>> datePeriods = get(userPeriodsSelector);

  List<DatePeriod> beforePeriods = datePeriods[0];
  List<DatePeriod> afterPeriods = datePeriods[1];

  return [
    filterDataIntoBuckets(
      steps.data,
      filterForPeriods(beforePeriods),
      dayFilter.days,
    ),
    filterDataIntoBuckets(
      steps.data,
      filterForPeriods(afterPeriods),
      dayFilter.days,
    ),
  ];
});

var dailyStepsBeforeAndAfterSelector =
    Selector('daily-steps-before-and-after-selector', (GetStateValue get) {
  User user = get(userAtom);
  StepsModel steps = get(stepsAtom);
  if (user.id == 'all') {
    return [
      steps.aggregatedData.averageHoursBefore,
      steps.aggregatedData.averageHoursAfter,
    ];
  }
  List buckets = get(stepsBeforeAndAfterSelector);
  DataBucket before = buckets[0];
  DataBucket after = buckets[1];

  return [
    averageDailySteps(before),
    averageDailySteps(after),
  ];
});

var totalStepsBeforeAndAfterSelector =
    Selector('total-steps-before-and-after-selector', (GetStateValue get) {
  List buckets = get(stepsBeforeAndAfterSelector);
  StepsModel steps = get(stepsAtom);
  DayFilterModel dayFilter = get(dayFilterAtom);
  User user = get(userAtom);
  HealthComparison comparison = get(stepsComparisonSelector);

  if (user.id == 'all') {
    return [steps.aggregatedData.stepsBefore, steps.aggregatedData.stepsAfter];
  }

  DataBucket before = buckets[0];
  DataBucket after = buckets[1];

  if (dayFilter.days.length == 7 && user.id != 'all') {
    if (comparison == null) {
      return [0, 0];
    }
    return [comparison.user.before.toInt(), comparison.user.after.toInt()];
  }

  var totalStepsBefore = before.data.fold(0, (sum, o) => sum + o.value).toInt();
  var totalStepsAfter = after.data.fold(0, (sum, o) => sum + o.value).toInt();

  return [
    (totalStepsBefore / before.period).toInt(),
    (totalStepsAfter / after.period).toInt()
  ];
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
  StepsModel steps = get(stepsAtom);
  User user = get(userAtom);

  if (user.id == 'all') {
    return steps.aggregatedData.days;
  }

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

  if (user.id == 'all') {
    AllUserData data = await api.getDataForAllUser();
    steps.setAggregatedData(data);
    return;
  }

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
