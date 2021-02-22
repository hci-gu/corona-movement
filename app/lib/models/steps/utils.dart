import 'package:wfhmovement/api/responses.dart';

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

class DataBucket {
  List<dynamic> data;
  int period;

  DataBucket(this.data, this.period);
}

DataBucket filterDataIntoBuckets(List data, Filter filter, List<int> weekdays) {
  List dataInFilter = data
      .where(filter)
      .toList()
      .where((o) => weekdays.contains(o.weekday))
      .toList();
  var numDates = dataInFilter.map((o) => o.date).toSet().length;

  return DataBucket(dataInFilter, numDates);
}

List averageDailySteps(DataBucket bucket) {
  List _group = groupByHour(bucket.data);
  return putDataInBuckets(_group.map((o) {
    return {
      'key': o['key'],
      'value': o['values'].fold(0, (sum, x) => sum + x.value) / bucket.period
    };
  }).toList());
}

Filter filterForPeriods(List<DatePeriod> periods) {
  return (o) => periods.fold(
        false,
        (prev, DatePeriod period) {
          if (o.date.compareTo(period.fromAsString) >= 0 &&
              o.date.compareTo(period.toAsString) < 0) {
            return true;
          }
          return prev;
        },
      );
}
