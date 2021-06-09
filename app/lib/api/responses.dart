import 'package:wfhmovement/i18n.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:wfhmovement/api/utils.dart';

class DateEvent {
  final DateTime date;
  final String text;

  DateEvent(this.date, this.text);

  factory DateEvent.fromJson(Map<String, dynamic> json) {
    return DateEvent(
      DateTime.parse(json['date']),
      json['text'],
    );
  }
}

class DatePeriod {
  final DateTime from;
  final DateTime to;

  String get fromAsString {
    return from.toIso8601String().substring(0, 10);
  }

  String get toAsString {
    if (to == null) {
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day)
          .toIso8601String()
          .substring(0, 10);
    }
    return to.toIso8601String().substring(0, 10);
  }

  String toString() {
    var ts = this.to == null
        ? 'ongoing'.i18n
        : DateFormat('yyyy-MM-dd').format(this.to);
    var fs = DateFormat('yyyy-MM-dd').format(this.from);
    return '$fs - $ts';
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from != null ? fromAsString : null,
      'to': to != null ? toAsString : null,
    };
  }

  DatePeriod(this.from, this.to);

  factory DatePeriod.fromJson(Map<String, dynamic> json) {
    return DatePeriod(
      json['from'] != null ? DateTime.parse(json['from']) : null,
      json['to'] != null ? DateTime.parse(json['to']) : null,
    );
  }
}

class UserResponse {
  String id;
  DateTime compareDate;
  DateTime initialDataDate;
  double stepsEstimate;
  String groupId;
  List<DatePeriod> beforePeriods;
  List<DatePeriod> afterPeriods;

  UserResponse(Map<String, dynamic> json) {
    id = json['_id'];
    if (json['compareDate'] != null) {
      compareDate = DateTime.parse(json['compareDate']);
    }
    if (json['initialDataDate'] != null) {
      initialDataDate = DateTime.parse(json['initialDataDate']);
    }
    if (json['stepsEstimate'] != null) {
      stepsEstimate = json['stepsEstimate'] + 0.000000001;
    }
    if (json['group'] != null) {
      groupId = json['group'];
    }
    if (json['beforePeriods'] != null) {
      List<dynamic> beforeData = json['beforePeriods'];
      beforePeriods = beforeData.map((o) => DatePeriod.fromJson(o)).toList();
    }
    if (json['afterPeriods'] != null) {
      List<dynamic> afterData = json['afterPeriods'];
      afterPeriods = afterData.map((o) => DatePeriod.fromJson(o)).toList();
    }
  }

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(json);
  }
}

class ChartResult {
  String from;
  String to;

  List<dynamic> result;

  ChartResult(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];

    result = json['result'];
  }

  factory ChartResult.fromJson(Map<String, dynamic> json) {
    return ChartResult(json);
  }
}

class AllUserData {
  int stepsBefore;
  int stepsAfter;
  List<dynamic> averageHoursBefore;
  List<dynamic> averageHoursAfter;

  List<dynamic> days;
  List<dynamic> wfhDates;

  AllUserData(Map<String, dynamic> json) {
    stepsBefore = json['summary']['before'];
    stepsAfter = json['summary']['after'];
    averageHoursBefore = json['hours']['before'];
    averageHoursAfter = json['hours']['after'];

    days = json['days'];
    wfhDates = json['dates'];
  }

  factory AllUserData.fromJson(Map<String, dynamic> json) {
    return AllUserData(json);
  }

  static empty() {
    return AllUserData({
      'summary': {
        'before': 0,
        'after': 0,
      },
      'hours': {'before': [], 'after': []},
      'days': [],
      'dates': []
    });
  }
}

class HealthData {
  String date;
  int hours;
  int weekday;
  double value;

  HealthData(Map<String, dynamic> json) {
    String timezone = globalApiHandler.timezone ?? 'Europe/Stockholm';
    var _date =
        tz.TZDateTime.parse(tz.getLocation(timezone), '${json['key']}:00');
    date = DateFormat('yyyy-MM-dd').format(_date);
    hours = _date.hour;
    weekday = _date.weekday;
    value = json['value'].toDouble();
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(json);
  }
}

class HealthComparison {
  HealthSummary user;
  HealthSummary others;
  List<HealthSummary> comparisons = [];
  List<HealthSummary> pendingComparisons = [];

  HealthComparison(Map<String, dynamic> json) {
    user = HealthSummary.fromJson('user', json['user']);
    others = HealthSummary.fromJson('others', json['others']);

    json.keys.toList().forEach((key) {
      HealthSummary summary = HealthSummary.fromJson(key, json[key]);
      if (summary.before != null) {
        comparisons.add(summary);
      } else {
        pendingComparisons.add(summary);
      }
    });
  }

  factory HealthComparison.fromJson(Map<String, dynamic> json) {
    return HealthComparison(json);
  }
}

class LatestUpload {
  DateTime date;
  String dataSource;

  LatestUpload(Map<String, dynamic> json) {
    var sthlm = tz.getLocation('Europe/Stockholm');
    date = tz.TZDateTime.parse(sthlm, '${json['date']}');
    dataSource = json['platform_type'];
    if (dataSource == null) {
      dataSource = json['platform'];
    }
  }

  factory LatestUpload.fromJson(Map<String, dynamic> json) {
    return LatestUpload(json);
  }
}

class HealthSummary {
  String name;
  double before;
  double after;

  HealthSummary(String _name, Map<String, dynamic> json) {
    name = _name;
    if (json['before'] != null) before = json['before'].toDouble();
    if (json['after'] != null) after = json['after'].toDouble();
  }

  factory HealthSummary.fromJson(String name, Map<String, dynamic> json) {
    return HealthSummary(name, json);
  }
}

class Group {
  String id;
  String name;

  Group(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(json);
  }
}

class FitbitDay {
  String date;
  int value;

  FitbitDay(Map<String, dynamic> json) {
    date = json['dateTime'];
    String stringValue = json['value'];
    value = int.parse(stringValue, radix: 10);
  }

  factory FitbitDay.fromJson(Map<String, dynamic> json) {
    return FitbitDay(json);
  }
}

class FitbitStep {
  DateTime dateTime;
  int value;

  FitbitStep(String date, Map<String, dynamic> json) {
    String timeString = json['time'];
    dateTime = DateTime.parse('${date}T$timeString');
    value = json['value'];
  }

  factory FitbitStep.fromJson(String date, Map<String, dynamic> json) {
    return FitbitStep(date, json);
  }
}
